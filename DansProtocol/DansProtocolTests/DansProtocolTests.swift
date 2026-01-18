import XCTest
@testable import DansProtocol

final class DansProtocolTests: XCTestCase {

    override func setUpWithError() throws {
        PendingInterruptStore.clear()
    }

    override func tearDownWithError() throws {
        PendingInterruptStore.clear()
    }

    func testPendingInterruptStoreIsSessionScoped() {
        let firstSession = UUID()
        let secondSession = UUID()

        PendingInterruptStore.add("p2_interrupt_1", sessionId: firstSession)
        XCTAssertEqual(PendingInterruptStore.load(for: firstSession), ["p2_interrupt_1"])
        XCTAssertTrue(PendingInterruptStore.load(for: secondSession).isEmpty)
    }

    func testLegacyPendingMerge() {
        let sessionId = UUID()

        PendingInterruptStore.addLegacy("p2_interrupt_2")
        XCTAssertEqual(PendingInterruptStore.load(for: sessionId), ["p2_interrupt_2"])
    }
}
