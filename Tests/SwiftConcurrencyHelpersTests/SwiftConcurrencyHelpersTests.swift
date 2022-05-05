import XCTest
@testable import SwiftConcurrencyHelpers

final class SwiftConcurrencyHelpersTests: XCTestCase {
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
        lock.withLock {

        }
    }
}
