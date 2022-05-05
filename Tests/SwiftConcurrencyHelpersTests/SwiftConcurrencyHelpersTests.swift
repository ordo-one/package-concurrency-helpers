@testable import SwiftConcurrencyHelpers
import XCTest

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

        lock.withLock {}

        lock.withLockVoid {}
    }
}
