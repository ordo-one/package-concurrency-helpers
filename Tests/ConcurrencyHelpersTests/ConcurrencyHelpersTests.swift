// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Atomics
import ConcurrencyHelpers
import XCTest

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

    struct Data {
        @Protected var valueA: Int = 1
        @Protected var valueB: Int? = nil

        public mutating func setA(_ a: Int) {
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

    private func doTestLockable<Mutex: Lockable>(_: Mutex.Type) async {
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

    func testEvent() async {
        await withTaskGroup(of: Int.self) { group in
            let value = ManagedAtomic<Int>(0)

            let ready = Event()
            XCTAssertFalse(ready.isSignaled)

            for _ in 1 ... 20 {
                group.addTask {
                    await ready.wait()
                    return value.load(ordering: .relaxed)
                }
            }

            try? await Task.sleep(nanoseconds: 10_000_000) // let all tasks to run

            value.store(10, ordering: .relaxed)
            ready.signal()

            XCTAssertTrue(ready.isSignaled)

            let sum = await group.reduce(0, +)

            XCTAssertEqual(sum, 10 * 20)
        }
    }

    func testEventReset() async {
        await withTaskGroup(of: Int.self) { group in
            let value = ManagedAtomic<Int>(0)

            let ready = Event(signaled: true)
            XCTAssertTrue(ready.isSignaled)

            ready.reset()
            XCTAssertFalse(ready.isSignaled)

            for _ in 1 ... 20 {
                group.addTask {
                    await ready.wait()
                    return value.load(ordering: .relaxed)
                }
            }

            try? await Task.sleep(nanoseconds: 10_000_000) // let all tasks to run

            value.store(10, ordering: .relaxed)
            ready.signal()

            XCTAssertTrue(ready.isSignaled)

            let sum = await group.reduce(0, +)

            XCTAssertEqual(sum, 10 * 20)
        }
    }
}
