import SwiftUI
import UIKit

/// A ViewModifier that creates a dramatic "breathing" effect by oscillating
/// font weight between Light (300) and Bold (700) over a 5-second cycle.
///
/// Inspired by kinetic typography in film title sequences (Se7en, etc.)
/// The effect should be VISIBLE and FELT - text that feels alive and watching.
///
/// Only works with variable fonts (Playfair Display, Noto Serif KR).
/// System fonts are not supported.
///
/// Usage:
/// ```
/// Text("Question text")
///     .breathingText(fontName: "Playfair Display", fontSize: 28)
/// ```
struct BreathingText: ViewModifier {
    @State private var isActive: Bool = false

    let fontName: String
    let fontSize: CGFloat
    let duration: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Animation update interval (~10fps) - TimelineView only updates when view is visible
    private static let animationInterval: Double = 0.1

    // MARK: - Weight Range Constants (Dramatic, visible range)

    /// Minimum weight: Light (300) - creates contrast and "exhale" feeling
    private static let minWeight: CGFloat = 300

    /// Maximum weight: Bold (700) - creates presence and "inhale" feeling
    private static let maxWeight: CGFloat = 700

    init(fontName: String, fontSize: CGFloat, duration: Double = 5.0) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.duration = duration
    }

    // MARK: - Animation Value Calculation

    /// Calculate weight for a given phase: oscillates between 300 and 700
    /// Formula: 500 + sin(phase * 2 * pi) * 200
    private func weight(for phase: Double) -> CGFloat {
        let centerWeight = (Self.minWeight + Self.maxWeight) / 2  // 500
        let amplitude = (Self.maxWeight - Self.minWeight) / 2      // 200
        return centerWeight + sin(phase * 2 * .pi) * amplitude
    }

    /// Create font with specified weight
    private func font(for weight: CGFloat) -> Font {
        guard let uiFont = VariableFontCache.shared.font(
            family: fontName,
            size: fontSize,
            weight: weight
        ) else {
            // Fallback to static font if variable font creation fails
            return Font.custom(fontName, size: fontSize)
        }
        return Font(uiFont)
    }

    func body(content: Content) -> some View {
        // TimelineView automatically pauses when view is not visible (battery efficient)
        // No timer accumulation issues - each update is based on absolute time
        TimelineView(.animation(minimumInterval: Self.animationInterval, paused: !isActive || reduceMotion)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let phase = elapsed.truncatingRemainder(dividingBy: duration) / duration
            let currentWeight = weight(for: phase)

            content
                .font(font(for: currentWeight))
        }
        .onAppear { isActive = !reduceMotion }
        .onDisappear { isActive = false }
    }

}

// MARK: - Convenience Extension

extension View {
    /// Applies a dramatic breathing animation to text, oscillating font weight
    /// between Light (300) and Bold (700) over 5 seconds.
    ///
    /// Inspired by kinetic typography in film title sequences.
    /// The effect should be VISIBLE and FELT - text that feels alive.
    ///
    /// Only works with variable fonts (Playfair Display, Noto Serif KR).
    /// Do not combine with `.font()` modifier - this modifier sets the font.
    ///
    /// - Parameters:
    ///   - fontName: The variable font family name (default: "Playfair Display")
    ///   - fontSize: The font size in points (default: 28)
    ///   - duration: The animation cycle duration in seconds (default: 5.0)
    /// - Returns: A view with breathing text animation applied
    func breathingText(
        fontName: String = FontFamily.playfairDisplay,
        fontSize: CGFloat = 28,
        duration: Double = 5.0
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
    ///   - duration: The animation cycle duration in seconds (default: 5.0)
    /// - Returns: A view with breathing text animation applied
    func breathingText(
        for language: String,
        fontSize: CGFloat = 28,
        duration: Double = 5.0
    ) -> some View {
        let fontName = language == "ko" ? FontFamily.notoSerifKR : FontFamily.playfairDisplay
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
            .font(.custom("Playfair Display", size: 28))
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
