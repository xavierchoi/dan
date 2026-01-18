import SwiftUI
import UIKit

enum FontFamily {
    static let playfairDisplay = "Playfair Display"
    static let notoSerifKR = "Noto Serif KR"
}

extension Font {

    private static func variableFont(familyName: String, size: CGFloat) -> Font {
        let descriptor = UIFontDescriptor(fontAttributes: [
            .family: familyName
        ])
        return Font(UIFont(descriptor: descriptor, size: size))
    }

    // Questions - Serif for philosophical weight
    // English: Playfair Display, Korean: Noto Serif Korean
    static func dpQuestion(for language: String) -> Font {
        language == "ko"
            ? variableFont(familyName: FontFamily.notoSerifKR, size: 28)
            : variableFont(familyName: FontFamily.playfairDisplay, size: 28)
    }

    static func dpQuestionLarge(for language: String) -> Font {
        language == "ko"
            ? variableFont(familyName: FontFamily.notoSerifKR, size: 32)
            : variableFont(familyName: FontFamily.playfairDisplay, size: 32)
    }

    // Static variants for non-language-specific contexts (defaults to English)
    static let dpQuestion = variableFont(familyName: FontFamily.playfairDisplay, size: 28)
    static let dpQuestionLarge = variableFont(familyName: FontFamily.playfairDisplay, size: 32)

    // UI Elements - System font for accessibility
    static let dpBody = Font.body
    static let dpCaption = Font.caption
    static let dpButton = Font.body.weight(.medium)

    // Dynamic question font based on text length (auto-size for long questions)
    static func dpQuestionAdaptive(for language: String, textLength: Int) -> Font {
        let baseSize: CGFloat = textLength > 150 ? 24 : (textLength > 100 ? 26 : 28)
        return language == "ko"
            ? variableFont(familyName: FontFamily.notoSerifKR, size: baseSize)
            : variableFont(familyName: FontFamily.playfairDisplay, size: baseSize)
    }
}
