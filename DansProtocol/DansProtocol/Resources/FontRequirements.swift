// MARK: - Custom Font Requirements for Dan's Protocol
//
// This file documents the custom fonts required for the app.
// Download these fonts and add them to the project:
//
// 1. Playfair Display (English questions)
//    - Source: Google Fonts (https://fonts.google.com/specimen/Playfair+Display)
//    - File needed: PlayfairDisplay-Regular.ttf
//    - License: Open Font License
//
// 2. Noto Serif Korean (Korean questions)
//    - Source: Google Fonts (https://fonts.google.com/noto/specimen/Noto+Serif+KR)
//    - File needed: NotoSerifKR-Regular.otf
//    - License: Open Font License
//
// MARK: - Installation Steps
//
// 1. Download the font files from Google Fonts
// 2. Add font files to this Resources folder
// 3. Add fonts to the Xcode project (drag & drop, ensure "Copy items if needed" is checked)
// 4. Register fonts in Info.plist (add UIAppFonts array):
//
//    <key>UIAppFonts</key>
//    <array>
//        <string>PlayfairDisplay-Regular.ttf</string>
//        <string>NotoSerifKR-Regular.otf</string>
//    </array>
//
// 5. Verify fonts are included in "Copy Bundle Resources" build phase
//
// MARK: - Fallback Behavior
//
// If custom fonts are not available, the app will use system serif fonts
// via Font.dpQuestionFallback (.system(size: 28, weight: .regular, design: .serif))
//
// MARK: - Font Usage
//
// English questions: Font.dpQuestion or Font.dpQuestion(for: "en")
// Korean questions: Font.dpQuestionKo or Font.dpQuestion(for: "ko")
// Adaptive sizing: Font.dpQuestionAdaptive(for: language, textLength: text.count)

import UIKit

/// Placeholder enum for font-related constants
/// This will be expanded when actual fonts are added
enum FontAssets {
    static let playfairDisplayRegular = "PlayfairDisplay-Regular"
    static let notoSerifKRRegular = "NotoSerifKR-Regular"

    /// Check if custom fonts are available
    static var isPlayfairAvailable: Bool {
        UIFont(name: playfairDisplayRegular, size: 12) != nil
    }

    static var isNotoSerifKRAvailable: Bool {
        UIFont(name: notoSerifKRRegular, size: 12) != nil
    }
}
