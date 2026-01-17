import XCTest
@testable import DansProtocol

final class QuestionServiceTests: XCTestCase {

    func testPart1QuestionsExist() {
        let questions = QuestionService.shared.questions(for: 1)
        XCTAssertFalse(questions.isEmpty, "Part 1 should have questions")
        XCTAssertEqual(questions.count, 15, "Part 1 should have 15 questions")
    }

    func testPart2InterruptQuestionsExist() {
        let questions = QuestionService.shared.questions(for: 2, type: .interrupt)
        XCTAssertFalse(questions.isEmpty, "Part 2 should have interrupt questions")
        XCTAssertEqual(questions.count, 6, "Part 2 should have 6 interrupt questions")
    }

    func testPart3SynthesisQuestionsExist() {
        let questions = QuestionService.shared.questions(for: 3, type: .synthesis)
        XCTAssertFalse(questions.isEmpty, "Part 3 should have synthesis questions")
    }

    func testPart3ComponentsQuestionsExist() {
        let questions = QuestionService.shared.questions(for: 3, type: .components)
        XCTAssertFalse(questions.isEmpty, "Part 3 should have component questions")
        XCTAssertEqual(questions.count, 6, "Part 3 should have 6 component questions")
    }

    func testQuestionLocalizationEnglish() {
        let questions = QuestionService.shared.questions(for: 1)
        guard let first = questions.first else {
            XCTFail("No questions found")
            return
        }

        XCTAssertFalse(first.en.isEmpty, "English text should not be empty")
        XCTAssertFalse(first.text(for: "en").isEmpty, "text(for: en) should return English")
    }

    func testQuestionLocalizationKorean() {
        let questions = QuestionService.shared.questions(for: 1)
        guard let first = questions.first else {
            XCTFail("No questions found")
            return
        }

        XCTAssertFalse(first.ko.isEmpty, "Korean text should not be empty")
        XCTAssertFalse(first.text(for: "ko").isEmpty, "text(for: ko) should return Korean")
    }

    func testEnglishAndKoreanAreDifferent() {
        let questions = QuestionService.shared.questions(for: 1)
        guard let first = questions.first else {
            XCTFail("No questions found")
            return
        }

        XCTAssertNotEqual(first.en, first.ko, "English and Korean translations should be different")
    }

    func testQuestionIdsAreUnique() {
        let part1 = QuestionService.shared.questions(for: 1)
        let part2Interrupts = QuestionService.shared.questions(for: 2, type: .interrupt)
        let part3Synthesis = QuestionService.shared.questions(for: 3, type: .synthesis)
        let part3Components = QuestionService.shared.questions(for: 3, type: .components)

        var allIds: [String] = []
        allIds.append(contentsOf: part1.map { $0.id })
        allIds.append(contentsOf: part2Interrupts.map { $0.id })
        allIds.append(contentsOf: part3Synthesis.map { $0.id })
        allIds.append(contentsOf: part3Components.map { $0.id })

        let uniqueIds = Set(allIds)
        XCTAssertEqual(allIds.count, uniqueIds.count, "All question IDs should be unique")
    }

    func testInvalidPartReturnsEmpty() {
        let questions = QuestionService.shared.questions(for: 99)
        XCTAssertTrue(questions.isEmpty, "Invalid part should return empty array")
    }
}
