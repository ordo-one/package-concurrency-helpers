// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import ConcurrencyHelpers
import XCTest

final class ConcurrencyHelpersTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() throws {
        let lock = Lock()

        lock.lock()
        lock.unlock()

        lock.withLock { _ = 1 }

        lock.withLockVoid { _ = 4 }
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
    }
}
