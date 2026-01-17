import SwiftUI

extension Font {
    // Questions - Serif for philosophical weight
    // English: Playfair Display, Korean: Noto Serif Korean
    static func dpQuestion(for language: String) -> Font {
        language == "ko"
            ? Font.custom("NotoSerifKR-Regular", size: 28)
            : Font.custom("PlayfairDisplay-Regular", size: 28)
    }

    static func dpQuestionLarge(for language: String) -> Font {
        language == "ko"
            ? Font.custom("NotoSerifKR-Regular", size: 32)
            : Font.custom("PlayfairDisplay-Regular", size: 32)
    }

    // Static variants for non-language-specific contexts
    static let dpQuestion = Font.custom("PlayfairDisplay-Regular", size: 28)
    static let dpQuestionLarge = Font.custom("PlayfairDisplay-Regular", size: 32)
    static let dpQuestionKo = Font.custom("NotoSerifKR-Regular", size: 28)
    static let dpQuestionLargeKo = Font.custom("NotoSerifKR-Regular", size: 32)

    // Fallback if custom font not available
    static let dpQuestionFallback = Font.system(size: 28, weight: .regular, design: .serif)

    // UI Elements - System font with Dynamic Type support for accessibility
    static let dpBody = Font.body
    static let dpCaption = Font.caption
    static let dpButton = Font.body.weight(.medium)

    // Dynamic question font based on text length (auto-size for long questions)
    static func dpQuestionAdaptive(for language: String, textLength: Int) -> Font {
        let baseSize: CGFloat = textLength > 150 ? 24 : (textLength > 100 ? 26 : 28)
        return language == "ko"
            ? Font.custom("NotoSerifKR-Regular", size: baseSize)
            : Font.custom("PlayfairDisplay-Regular", size: baseSize)
    }
}
