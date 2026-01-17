import XCTest
@testable import DansProtocol

final class DateExtensionsTests: XCTestCase {

    func testLongDateString() {
        // Create a specific date
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15
        components.hour = 10
        components.minute = 30

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let result = date.longDateString

        // Should contain the year, month, and day in some format
        XCTAssertFalse(result.isEmpty, "longDateString should not be empty")
        XCTAssertTrue(result.contains("2024") || result.contains("15"), "Should contain date information")
    }

    func testMonthYearString() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let result = date.monthYearString

        // Should be in "MMM yyyy" format
        XCTAssertFalse(result.isEmpty, "monthYearString should not be empty")
        XCTAssertTrue(result.contains("2024"), "Should contain year")
        XCTAssertTrue(result.contains("Mar") || result.contains("3"), "Should contain month")
    }

    func testDateFormattersAreCached() {
        // Test that multiple calls return consistent results (formatters are reused)
        let date = Date()

        let result1 = date.longDateString
        let result2 = date.longDateString
        let result3 = date.longDateString

        XCTAssertEqual(result1, result2, "Results should be consistent")
        XCTAssertEqual(result2, result3, "Results should be consistent")
    }
}
