import Foundation
import SwiftUI

/// Parses markup-based emphasis in question text.
///
/// Supports `*text*` syntax for italic emphasis. Designed to work with
/// Questions.json where key words are marked up for typographic tension.
///
/// Example:
/// ```swift
/// let result = EmphasisParser.parse("What is the *dull* dissatisfaction?")
/// // result.plainText == "What is the dull dissatisfaction?"
/// // result.ranges contains one range for "dull" with .italic type
/// ```
struct EmphasisParser {

    // MARK: - Types

    /// The type of emphasis to apply
    enum EmphasisType {
        case italic
    }

    /// A range in the cleaned text that should be emphasized
    struct EmphasisRange: Equatable {
        let range: Range<String.Index>
        let type: EmphasisType

        /// The emphasized substring
        func text(in string: String) -> String {
            String(string[range])
        }
    }

    /// Result of parsing, containing cleaned text and emphasis ranges
    struct ParseResult: Equatable {
        let plainText: String
        let ranges: [EmphasisRange]

        /// Returns true if any emphasis was found
        var hasEmphasis: Bool {
            !ranges.isEmpty
        }
    }

    // MARK: - Parsing

    /// Parses text with `*emphasis*` markup and returns clean text with emphasis ranges.
    ///
    /// - Parameters:
    ///   - text: The input text potentially containing `*emphasis*` markup
    ///   - language: Language code (reserved for future language-specific handling)
    /// - Returns: ParseResult with cleaned text and emphasis ranges
    static func parse(_ text: String, language: String = "en") -> ParseResult {
        var plainText = ""
        var ranges: [EmphasisRange] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            // Look for opening asterisk
            guard let openingAsterisk = text[currentIndex...].firstIndex(of: "*") else {
                // No more asterisks, append rest of string
                plainText.append(contentsOf: text[currentIndex...])
                break
            }

            // Append text before the asterisk
            plainText.append(contentsOf: text[currentIndex..<openingAsterisk])

            // Look for closing asterisk
            let afterOpening = text.index(after: openingAsterisk)
            guard afterOpening < text.endIndex,
                  let closingAsterisk = text[afterOpening...].firstIndex(of: "*") else {
                // No closing asterisk found - treat as literal
                plainText.append("*")
                currentIndex = afterOpening
                continue
            }

            // Extract emphasized text (between asterisks)
            let emphasizedText = String(text[afterOpening..<closingAsterisk])

            // Don't allow empty emphasis
            guard !emphasizedText.isEmpty else {
                // Empty emphasis (**) - treat as literal asterisks
                plainText.append("**")
                currentIndex = text.index(after: closingAsterisk)
                continue
            }

            // Record the range in the plain text
            let rangeStart = plainText.endIndex
            plainText.append(emphasizedText)
            let rangeEnd = plainText.endIndex

            ranges.append(EmphasisRange(
                range: rangeStart..<rangeEnd,
                type: .italic
            ))

            // Move past the closing asterisk
            currentIndex = text.index(after: closingAsterisk)
        }

        return ParseResult(plainText: plainText, ranges: ranges)
    }

    // MARK: - AttributedString Convenience

    /// Creates an AttributedString with italic emphasis applied.
    ///
    /// - Parameters:
    ///   - text: The input text with `*emphasis*` markup
    ///   - language: Language code for font selection
    ///   - baseFont: The base font to use (emphasis will use italic variant)
    /// - Returns: An AttributedString with emphasis applied
    static func attributedString(
        from text: String,
        language: String = "en",
        baseFont: Font? = nil
    ) -> AttributedString {
        let result = parse(text, language: language)
        var attributed = AttributedString(result.plainText)

        // Apply base font if provided
        if let font = baseFont {
            attributed.font = font
        }

        // Apply italic to emphasized ranges
        for emphasisRange in result.ranges {
            // Convert String.Index range to AttributedString range
            if let attributedRange = Range(emphasisRange.range, in: attributed) {
                attributed[attributedRange].font = (baseFont ?? .body).italic()
            }
        }

        return attributed
    }

    /// Creates an AttributedString using the app's typography system.
    ///
    /// - Parameters:
    ///   - text: The input text with `*emphasis*` markup
    ///   - language: Language code for font selection
    /// - Returns: An AttributedString styled for questions with emphasis
    static func questionAttributedString(
        from text: String,
        language: String = "en"
    ) -> AttributedString {
        let result = parse(text, language: language)
        var attributed = AttributedString(result.plainText)

        // Apply italic to emphasized ranges
        // Note: The base font should be set by the Text view; we only mark italics
        for emphasisRange in result.ranges {
            if let attributedRange = Range(emphasisRange.range, in: attributed) {
                // Use the italic text style - the container view sets the actual font
                attributed[attributedRange].inlinePresentationIntent = .emphasized
            }
        }

        return attributed
    }
}

// MARK: - SwiftUI Text Extension

extension Text {
    /// Creates a Text view from markup text with emphasis applied.
    ///
    /// - Parameters:
    ///   - markup: Text containing `*emphasis*` markup
    ///   - language: Language code for parsing
    init(markup: String, language: String = "en") {
        let attributed = EmphasisParser.attributedString(from: markup, language: language)
        self.init(attributed)
    }
}
