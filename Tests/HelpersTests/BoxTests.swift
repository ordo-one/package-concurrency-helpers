import Helpers
import XCTest

final class BoxTests: XCTestCase {
    func testBox() {
        let a = Box<Int>(10)
        XCTAssertEqual(a.value, 10)

        let b = a
        XCTAssertEqual(b.value, 10)

        a.value = 13
        XCTAssertEqual(b.value, 13)
    }

    func testEquatable() {
        let a = Box<Int>(10)
        let b = a

        XCTAssertEqual(a, b)

        let c = Box<Int>(10)
        XCTAssertEqual(a, c)
        XCTAssertEqual(b, c)

        a.value = 5
        XCTAssertNotEqual(a, c)
    }

    func testComparable() {
        let a = Box<Int>(10)
        let b = Box<Int>(13)

        XCTAssertTrue(a < b)
        XCTAssertTrue(a <= a)
        XCTAssertTrue(a <= b)
        XCTAssertFalse(a > b)
        XCTAssertFalse(a >= b)
    }

    func testStringConvertible() {
        let a = Box<Int>(10)
        XCTAssertEqual("\(a)", "10")
    }

    func testDebugStringConvertible() {
        let a = Box<Int>(10)
        XCTAssertEqual(String(reflecting: a), "Box(10)")
    }
}
