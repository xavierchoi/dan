import XCTest
@testable import DansProtocol

final class EmphasisParserTests: XCTestCase {

    // MARK: - Basic Parsing

    func testNoMarkup() {
        let result = EmphasisParser.parse("Hello world")

        XCTAssertEqual(result.plainText, "Hello world")
        XCTAssertTrue(result.ranges.isEmpty)
        XCTAssertFalse(result.hasEmphasis)
    }

    func testSingleEmphasis() {
        let result = EmphasisParser.parse("What is the *dull* dissatisfaction?")

        XCTAssertEqual(result.plainText, "What is the dull dissatisfaction?")
        XCTAssertEqual(result.ranges.count, 1)
        XCTAssertTrue(result.hasEmphasis)

        let emphasized = result.ranges[0].text(in: result.plainText)
        XCTAssertEqual(emphasized, "dull")
        XCTAssertEqual(result.ranges[0].type, .italic)
    }

    func testMultipleEmphasis() {
        let result = EmphasisParser.parse("The *quick* brown *fox* jumps")

        XCTAssertEqual(result.plainText, "The quick brown fox jumps")
        XCTAssertEqual(result.ranges.count, 2)

        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "quick")
        XCTAssertEqual(result.ranges[1].text(in: result.plainText), "fox")
    }

    func testEmphasisAtStart() {
        let result = EmphasisParser.parse("*Start* of sentence")

        XCTAssertEqual(result.plainText, "Start of sentence")
        XCTAssertEqual(result.ranges.count, 1)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "Start")
    }

    func testEmphasisAtEnd() {
        let result = EmphasisParser.parse("End of *sentence*")

        XCTAssertEqual(result.plainText, "End of sentence")
        XCTAssertEqual(result.ranges.count, 1)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "sentence")
    }

    func testMultiWordEmphasis() {
        let result = EmphasisParser.parse("This is *very important* information")

        XCTAssertEqual(result.plainText, "This is very important information")
        XCTAssertEqual(result.ranges.count, 1)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "very important")
    }

    // MARK: - Edge Cases

    func testUnclosedAsteriskTreatedAsLiteral() {
        let result = EmphasisParser.parse("This has an *unclosed asterisk")

        XCTAssertEqual(result.plainText, "This has an *unclosed asterisk")
        XCTAssertTrue(result.ranges.isEmpty)
    }

    func testEmptyEmphasisTreatedAsLiteral() {
        let result = EmphasisParser.parse("Empty ** emphasis")

        XCTAssertEqual(result.plainText, "Empty ** emphasis")
        XCTAssertTrue(result.ranges.isEmpty)
    }

    func testConsecutiveAsterisks() {
        let result = EmphasisParser.parse("Test *** three")

        // First ** is empty (literal), then * is unclosed (literal)
        XCTAssertEqual(result.plainText, "Test *** three")
        XCTAssertTrue(result.ranges.isEmpty)
    }

    func testEmptyString() {
        let result = EmphasisParser.parse("")

        XCTAssertEqual(result.plainText, "")
        XCTAssertTrue(result.ranges.isEmpty)
    }

    func testOnlyAsterisk() {
        let result = EmphasisParser.parse("*")

        XCTAssertEqual(result.plainText, "*")
        XCTAssertTrue(result.ranges.isEmpty)
    }

    func testAdjacentEmphasis() {
        let result = EmphasisParser.parse("*one**two*")

        XCTAssertEqual(result.plainText, "onetwo")
        XCTAssertEqual(result.ranges.count, 2)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "one")
        XCTAssertEqual(result.ranges[1].text(in: result.plainText), "two")
    }

    // MARK: - Korean Text

    func testKoreanEmphasis() {
        let result = EmphasisParser.parse("당신이 *참아온* 불만족은 무엇인가요?", language: "ko")

        XCTAssertEqual(result.plainText, "당신이 참아온 불만족은 무엇인가요?")
        XCTAssertEqual(result.ranges.count, 1)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "참아온")
    }

    // MARK: - AttributedString

    func testAttributedStringCreation() {
        let attributed = EmphasisParser.attributedString(from: "Test *emphasis* here")

        // Verify it creates an attributed string (basic check)
        XCTAssertFalse(String(attributed.characters).isEmpty)
        XCTAssertEqual(String(attributed.characters), "Test emphasis here")
    }

    func testQuestionAttributedString() {
        let attributed = EmphasisParser.questionAttributedString(from: "What *matters*?")

        XCTAssertEqual(String(attributed.characters), "What matters?")
    }

    // MARK: - Real-World Examples

    func testRealQuestionExample() {
        let result = EmphasisParser.parse(
            "What is the *dull* and *persistent* dissatisfaction you've learned to live with?"
        )

        XCTAssertEqual(
            result.plainText,
            "What is the dull and persistent dissatisfaction you've learned to live with?"
        )
        XCTAssertEqual(result.ranges.count, 2)
        XCTAssertEqual(result.ranges[0].text(in: result.plainText), "dull")
        XCTAssertEqual(result.ranges[1].text(in: result.plainText), "persistent")
    }

    // MARK: - ParseResult Equatable

    func testParseResultEquatable() {
        let result1 = EmphasisParser.parse("Test *word*")
        let result2 = EmphasisParser.parse("Test *word*")

        XCTAssertEqual(result1, result2)
    }
}
