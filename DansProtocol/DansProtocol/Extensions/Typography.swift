import SwiftUI

extension Font {
    // Variable Font Names
    private static let playfairDisplay = "PlayfairDisplay-Regular"
    private static let notoSerifKR = "NotoSerifKR-Regular"

    // Questions - Serif for philosophical weight
    // English: Playfair Display, Korean: Noto Serif Korean
    static func dpQuestion(for language: String) -> Font {
        language == "ko"
            ? Font.custom(notoSerifKR, size: 28)
            : Font.custom(playfairDisplay, size: 28)
    }

    static func dpQuestionLarge(for language: String) -> Font {
        language == "ko"
            ? Font.custom(notoSerifKR, size: 32)
            : Font.custom(playfairDisplay, size: 32)
    }

    // Static variants for non-language-specific contexts (defaults to English)
    static let dpQuestion = Font.custom(playfairDisplay, size: 28)
    static let dpQuestionLarge = Font.custom(playfairDisplay, size: 32)

    // UI Elements - System font for accessibility
    static let dpBody = Font.body
    static let dpCaption = Font.caption
    static let dpButton = Font.body.weight(.medium)

    // Dynamic question font based on text length (auto-size for long questions)
    static func dpQuestionAdaptive(for language: String, textLength: Int) -> Font {
        let baseSize: CGFloat = textLength > 150 ? 24 : (textLength > 100 ? 26 : 28)
        return language == "ko"
            ? Font.custom(notoSerifKR, size: baseSize)
            : Font.custom(playfairDisplay, size: baseSize)
    }
}
