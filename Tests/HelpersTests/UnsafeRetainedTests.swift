// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import PackageConcurrencyHelpers
@testable import Helpers
import XCTest

var lock: Lock = .init()
var checksPassed = 0

final class UnsafeRetainedTests: XCTestCase {
    func testStorage() async {
        // Allocate storage, fill it with some data
        let storage: UnsafeMutablePointer<UInt8> = .allocate(capacity: 256)
        for i in 0 ..< 256 {
            storage[i] = UInt8(i)
        }
        let storagePtr = MyUInt8ArrayPtr(storage, 256)

        // Make storage UnsafeRetained, release policy is to deallocate when no one need this
        var retainedStorage: UnsafeRetained<MyUInt8ArrayPtr>? = .init(storagePtr, .release)

        // Now let's process data simultaneously
        let result = await withTaskGroup(of: Bool.self, returning: Bool.self) { taskGroup in
            for i in 0 ..< 256 {
                // Create UnsafeRetained with release policy 'forsake' and reference to underlying storage
                let ptr = UnsafeRetained<UnsafePointer<UInt8>>(&storage[i], .forsake, retainedStorage)
                taskGroup.addTask {
                    // This function checks that 'ptr' points to memory with value 'i'
                    // See this function below
                    await self.checkValue(value: UInt8(i), ptr: ptr)
                }
            }

            // No need to keep explicit reference to storage,
            // but it's not deallocated since it is referenced from data pointers
            retainedStorage = nil

            // But, let's check that data is not cleaned
            for i in 0 ..< 256 {
                XCTAssertTrue(storage[i] == UInt8(i))
            }

            // Then let's collect the result
            var result = true
            for await childResult in taskGroup {
                result = result && childResult
            }
            return result
        }
        // Check result
        XCTAssertTrue(result)
        lock.withLockVoid {
            XCTAssertTrue(checksPassed == 256)
        }
    }

    // Function checks that 'ptr' points to memory with value 'value'
    func checkValue(value: UInt8, ptr: UnsafeRetained<UnsafePointer<UInt8>>) async -> Bool {
        do {
            // Sleep to bring some randomness and handle tasks in different order then created
            try await Task.sleep(nanoseconds: UInt64.random(in: 1_000 ... 5_000))
            if value == ptr.data[0] {
                lock.withLockVoid {
                    checksPassed += 1
                }
                return true
            }
            return false
        } catch {
            return false
        }
    }

    // Helper struct which is not only deallocate memory, but also set it to all 0's
    struct MyUInt8ArrayPtr: Releasable {
        var ptr: UnsafeMutablePointer<UInt8>
        var size: Int

        public init(_ ptr: UnsafeMutablePointer<UInt8>, _ size: Int) {
            self.ptr = ptr
            self.size = size
        }

        public func release() {
            // Make sure we release memory only after all tasks are done, so all references are dropped
            lock.withLockVoid {
                XCTAssertTrue(checksPassed == 256)
            }
            // Clean memory
            for i in 0 ..< size {
                ptr[i] = 0
            }
            // Deallocate memory
            ptr.deallocate()
        }
    }
}
