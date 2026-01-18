import SwiftUI
import UIKit
import CoreText

/// A ViewModifier that creates a subtle "breathing" effect by slowly oscillating
/// font weight between 350 and 450 over an 8-second cycle.
///
/// The effect is intentionally subtle - users should barely notice it,
/// but it gives text a sense of being "alive".
///
/// Only works with variable fonts (PlayfairDisplay, NotoSerifKR).
/// System fonts are not supported.
///
/// Usage:
/// ```
/// Text("Question text")
///     .breathingText(fontName: "PlayfairDisplay-Regular", fontSize: 28)
/// ```
struct BreathingText: ViewModifier {
    @State private var phase: Double = 0
    @State private var isActive: Bool = false

    let fontName: String
    let fontSize: CGFloat
    let duration: Double

    /// Timer fires every 100ms (10 updates per second) for smooth animation with low CPU overhead
    /// Only runs when view is visible (controlled by onAppear/onDisappear)
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(fontName: String, fontSize: CGFloat, duration: Double = 8.0) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.duration = duration
    }

    /// Calculate current weight: oscillates between 350 and 450
    /// Formula: 400 + sin(phase) * 50 where phase is 0 to 2*pi
    private var currentWeight: CGFloat {
        400 + sin(phase * 2 * .pi) * 50
    }

    /// Create font with current interpolated weight
    private var currentFont: Font {
        guard let uiFont = Self.createVariableFont(
            name: fontName,
            size: fontSize,
            weight: currentWeight
        ) else {
            // Fallback to static font if variable font creation fails
            return Font.custom(fontName, size: fontSize)
        }
        return Font(uiFont)
    }

    func body(content: Content) -> some View {
        content
            .font(currentFont)
            .onAppear { isActive = true }
            .onDisappear { isActive = false }
            .onReceive(timer) { _ in
                // Only animate when view is visible
                guard isActive else { return }
                // Advance phase by fraction of cycle
                phase += 0.1 / duration
                // Reset when cycle completes
                if phase >= 1 {
                    phase = 0
                }
            }
    }

    /// Creates a UIFont with a specific weight value for variable fonts
    /// - Parameters:
    ///   - name: The font name (e.g., "PlayfairDisplay-Regular")
    ///   - size: The font size in points
    ///   - weight: The weight value (350-450 for this animation)
    /// - Returns: A UIFont configured with the specified weight, or nil if creation fails
    private static func createVariableFont(name: String, size: CGFloat, weight: CGFloat) -> UIFont? {
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: name
        ])

        // Use Core Text variation attribute to set the weight axis
        // "wght" is the standard axis tag for font weight
        let variationDescriptor = descriptor.addingAttributes([
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [
                "wght": weight
            ]
        ])

        return UIFont(descriptor: variationDescriptor, size: size)
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a subtle breathing animation to text, oscillating font weight
    /// between 350 and 450 over 8 seconds.
    ///
    /// Only works with variable fonts (PlayfairDisplay, NotoSerifKR).
    /// Do not combine with `.font()` modifier - this modifier sets the font.
    ///
    /// - Parameters:
    ///   - fontName: The variable font name (default: "PlayfairDisplay-Regular")
    ///   - fontSize: The font size in points (default: 28)
    ///   - duration: The animation cycle duration in seconds (default: 8.0)
    /// - Returns: A view with breathing text animation applied
    func breathingText(
        fontName: String = "PlayfairDisplay-Regular",
        fontSize: CGFloat = 28,
        duration: Double = 8.0
    ) -> some View {
        modifier(BreathingText(
            fontName: fontName,
            fontSize: fontSize,
            duration: duration
        ))
    }

    /// Applies breathing animation using the appropriate font for the given language.
    ///
    /// - Parameters:
    ///   - language: The language code ("en" for English, "ko" for Korean)
    ///   - fontSize: The font size in points (default: 28)
    ///   - duration: The animation cycle duration in seconds (default: 8.0)
    /// - Returns: A view with breathing text animation applied
    func breathingText(
        for language: String,
        fontSize: CGFloat = 28,
        duration: Double = 8.0
    ) -> some View {
        let fontName = language == "ko" ? "NotoSerifKR-Regular" : "PlayfairDisplay-Regular"
        return modifier(BreathingText(
            fontName: fontName,
            fontSize: fontSize,
            duration: duration
        ))
    }
}

// MARK: - Preview

#Preview("Breathing Text - English") {
    VStack(spacing: 40) {
        Text("What is the dull and persistent dissatisfaction you've learned to live with?")
            .breathingText()
            .foregroundColor(.white)
            .padding()

        Text("Static comparison (no breathing)")
            .font(.custom("PlayfairDisplay-Regular", size: 28))
            .foregroundColor(.gray)
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#Preview("Breathing Text - Korean") {
    Text("당신이 살면서 당연하게 받아들이게 된, 둔하고 지속적인 불만족은 무엇인가요?")
        .breathingText(for: "ko")
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
