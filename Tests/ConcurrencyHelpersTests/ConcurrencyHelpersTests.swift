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

        lock.withLock { let _ = 1 }

        lock.withLockVoid { let _ = 4 }
    }
}
