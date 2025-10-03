// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import PackageConcurrencyHelpers
import XCTest
#if os(OSX) && DEBUG
import CwlPreconditionTesting
#endif

private final class Counter<Mutex: Lockable>: @unchecked Sendable {
    private let lock = Mutex()
    private var count = 0

    init() {}

    var value: Int {
        lock.withLock { count }
    }

    func increment() {
        lock.withLockVoid {
            count += 1
        }
    }
}

final class ConcurrencyHelpersTests: XCTestCase {
    func testLock() async {
        await doTestLockable(Lock.self)
    }

    private struct Data {
        @Protected var valueA: Int = 1
        @Protected var valueB: Int?

        mutating func setA(_ a: Int) {
            _valueA.write {
                $0 = a
            }
        }
    }

    func testProtected() {
        let data = Data()

        XCTAssertEqual(data.valueA, 1)
        XCTAssertEqual(data.valueB, nil)

        data.valueA = 2
        data.valueB = 3

        XCTAssertEqual(data.valueA, 2)
        XCTAssertEqual(data.valueB, 3)

        let valueAis2 = data.$valueA.read { value in
            value == 2
        }
        XCTAssertEqual(valueAis2, true)

        data.$valueB.write {
            $0 = nil
        }
        XCTAssertEqual(data.valueB, nil)

        struct MyError: Error {}

        XCTAssertThrowsError(try data.$valueA.read { _ in throw MyError() })
        XCTAssertThrowsError(try data.$valueB.write { _ in throw MyError() })
    }

    func testSpinlock() async {
        await doTestLockable(Spinlock.self)
    }

    private func doTestLockable<Mutex: Lockable & Sendable>(_: Mutex.Type) async {
        let taskCount = 10
        let iterationCount = 10_000

        let counter = Counter<Mutex>()

        await withTaskGroup(of: Void.self, returning: Void.self) { group in
            for _ in 0 ..< taskCount {
                group.addTask {
                    for _ in 0 ..< iterationCount {
                        counter.increment()
                    }
                }
            }

            await group.waitForAll()
        }

        XCTAssertEqual(counter.value, taskCount * iterationCount)
    }

    private func someAsyncMethod(argument: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 10_000)
        return argument * 2
    }

    func testRunSync() {
        let result = runSync { await self.someAsyncMethod(argument: 34) }
        XCTAssertEqual(result, 34 * 2)
    }

    @available(macOS 26, iOS 26, *)
    func testRunSyncInRunSync() {
        func runSyncRec(recursion: Int) -> Int {
            if recursion <= 0 {
                return runSync {
                    await self.someAsyncMethod(argument: 34)
                }
            }
            return runSync {
                runSyncRec(recursion: recursion - 1)
            }
        }
        let result = runSyncRec(recursion: 100)
        XCTAssertEqual(result, 34 * 2)
    }

    func testRunSyncWithPriority() {
        let result = runSync(priority: .userInitiated) { await self.someAsyncMethod(argument: 34) }
        XCTAssertEqual(result, 34 * 2)
    }

    private struct InvalidArgumentError: Error {}

    private func someThrowingAsyncMethod(argument: Int?) async throws -> Int {
        try? await Task.sleep(nanoseconds: 10_000)
        guard let argument else {
            throw InvalidArgumentError()
        }
        return argument * 2
    }

    func testRunSyncThrowable() {
        let result = try? runSync { try await self.someThrowingAsyncMethod(argument: 34) }
        XCTAssertEqual(result, 34 * 2)

        XCTAssertThrowsError(try runSync { try await self.someThrowingAsyncMethod(argument: nil) })
    }

    func testRunSyncThrowableWithPriority() {
        let result = try? runSync(priority: .userInitiated) { try await self.someThrowingAsyncMethod(argument: 34) }
        XCTAssertEqual(result, 34 * 2)

        XCTAssertThrowsError(try runSync { try await self.someThrowingAsyncMethod(argument: nil) })
    }

#if os(OSX) && DEBUG
    func testForBlockingCallProvidedQueueUsed() async {
        let queue = DispatchQueue(label: "com.test.queue")

        final class UnsafeWrapper: @unchecked Sendable {
            @Protected
            var exception: BadInstructionException?
        }
        let wrapper = UnsafeWrapper()

        await forBlockingFunc(queue: queue) {
            // NB! BadInstruction will occur due
            // to sync dispatch to the same queue
            let exception = catchBadInstruction {
                queue.sync {
                    print("Never")
                }
            }

            wrapper.exception = exception
        }
        let exception = wrapper.exception
        XCTAssertNotNil(exception)
        XCTAssert(exception?.description.contains("BadInstruction") ?? false)
    }
#endif

    func testTaskCancellationInYieldWithBackPressure() async throws {
        typealias Stream = AsyncStream<Int>

        let (stream, continuation) = {
            var continuation: Stream.Continuation?
            let stream = Stream(bufferingPolicy: .bufferingOldest(1)) { continuation = $0 }
            return (stream, continuation!)
        }()

        _ = stream // silent "never used" warning

        // make stream buffer "full"
        XCTAssertEqual(continuation.yield(5), .enqueued(remaining: 0))

        // start a task that tries to add another element to the stream
        let producerTask = Task {
            // will loop here
            await yieldWithBackPressure(message: 10, to: continuation)
        }

        producerTask.cancel()

        // wait for task to finish
        _ = await producerTask.value
    }
}

extension AsyncStream.Continuation.YieldResult: @retroactive Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .enqueued(let lhsRemaining):
            if case .enqueued(let rhsRemaining) = rhs {
                return lhsRemaining == rhsRemaining
            }
            return false
        case .dropped(let lhsElement):
            if case .dropped(let rhsElement) = rhs {
                return lhsElement == rhsElement
            }
            return false
        case .terminated:
            return rhs == .terminated
        default:
            fatalError("unknown yield result: \(lhs)")
        }
    }
}
