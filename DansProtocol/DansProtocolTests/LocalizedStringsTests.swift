import XCTest
@testable import DansProtocol

final class LocalizedStringsTests: XCTestCase {

    // MARK: - NavLabels Tests

    func testNavLabelsEnglish() {
        XCTAssertEqual(NavLabels.back(for: "en"), "← Back")
        XCTAssertEqual(NavLabels.continueButton(for: "en"), "Continue →")
        XCTAssertEqual(NavLabels.complete(for: "en"), "Complete →")
        XCTAssertEqual(NavLabels.skip(for: "en"), "Skip")
        XCTAssertEqual(NavLabels.save(for: "en"), "Save →")
        XCTAssertEqual(NavLabels.begin(for: "en"), "Begin →")
    }

    func testNavLabelsKorean() {
        XCTAssertEqual(NavLabels.back(for: "ko"), "← 뒤로")
        XCTAssertEqual(NavLabels.continueButton(for: "ko"), "계속 →")
        XCTAssertEqual(NavLabels.complete(for: "ko"), "완료 →")
        XCTAssertEqual(NavLabels.skip(for: "ko"), "건너뛰기")
        XCTAssertEqual(NavLabels.save(for: "ko"), "저장 →")
        XCTAssertEqual(NavLabels.begin(for: "ko"), "시작하기 →")
    }

    // MARK: - ComponentLabels Tests

    func testComponentLabelsEnglish() {
        XCTAssertEqual(ComponentLabels.antiVision(for: "en"), "Anti-Vision")
        XCTAssertEqual(ComponentLabels.vision(for: "en"), "Vision")
        XCTAssertEqual(ComponentLabels.oneYearGoal(for: "en"), "1-Year Goal")
        XCTAssertEqual(ComponentLabels.oneMonthProject(for: "en"), "1-Month Project")
        XCTAssertEqual(ComponentLabels.dailyLevers(for: "en"), "Daily Levers")
        XCTAssertEqual(ComponentLabels.constraints(for: "en"), "Constraints")
    }

    func testComponentLabelsKorean() {
        XCTAssertEqual(ComponentLabels.antiVision(for: "ko"), "안티비전")
        XCTAssertEqual(ComponentLabels.vision(for: "ko"), "비전")
        XCTAssertEqual(ComponentLabels.oneYearGoal(for: "ko"), "1년 목표")
        XCTAssertEqual(ComponentLabels.oneMonthProject(for: "ko"), "1개월 프로젝트")
        XCTAssertEqual(ComponentLabels.dailyLevers(for: "ko"), "일일 레버")
        XCTAssertEqual(ComponentLabels.constraints(for: "ko"), "제약 조건")
    }

    // MARK: - Part2Labels Tests

    func testPart2LabelsReflectionsCompleted() {
        let enResult = Part2Labels.reflectionsCompleted(for: "en", answered: 3, total: 6)
        XCTAssertEqual(enResult, "3 of 6 reflections completed")

        let koResult = Part2Labels.reflectionsCompleted(for: "ko", answered: 3, total: 6)
        XCTAssertEqual(koResult, "6개 중 3개 성찰 완료")
    }

    // MARK: - HistoryLabels Tests

    func testHistoryLabelsEnglish() {
        XCTAssertEqual(HistoryLabels.yourJourney(for: "en"), "Your Journey")
        XCTAssertEqual(HistoryLabels.noCompletedSessions(for: "en"), "No completed sessions yet")
        XCTAssertEqual(HistoryLabels.compareWithPrevious(for: "en"), "Compare with previous")
        XCTAssertEqual(HistoryLabels.startNewProtocol(for: "en"), "Start New Protocol")
        XCTAssertEqual(HistoryLabels.thenVsNow(for: "en"), "Then vs Now")
    }

    func testHistoryLabelsKorean() {
        XCTAssertEqual(HistoryLabels.yourJourney(for: "ko"), "당신의 여정")
        XCTAssertEqual(HistoryLabels.noCompletedSessions(for: "ko"), "완료된 세션이 없습니다")
        XCTAssertEqual(HistoryLabels.compareWithPrevious(for: "ko"), "이전과 비교하기")
        XCTAssertEqual(HistoryLabels.startNewProtocol(for: "ko"), "새 프로토콜 시작")
        XCTAssertEqual(HistoryLabels.thenVsNow(for: "ko"), "과거 vs 현재")
    }

    // MARK: - Default Language Behavior

    func testUnknownLanguageDefaultsToEnglish() {
        // Unknown languages should return English as fallback
        XCTAssertEqual(NavLabels.back(for: "fr"), "← Back")
        XCTAssertEqual(ComponentLabels.vision(for: "de"), "Vision")
        XCTAssertEqual(HistoryLabels.yourJourney(for: "ja"), "Your Journey")
    }
}
