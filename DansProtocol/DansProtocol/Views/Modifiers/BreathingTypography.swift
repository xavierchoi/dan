import SwiftUI
import UIKit

/// A ViewModifier that creates a dramatic "breathing" effect by animating
/// font weight between Light (300) and Bold (700) over a 5-second cycle.
///
/// Inspired by kinetic typography in film title sequences (Se7en, etc.)
/// The effect should be VISIBLE and FELT - text that feels alive and watching.
///
/// Optionally includes a subtle scale pulse synchronized with the weight animation.
///
/// Only works with variable fonts (PlayfairDisplay-VariableFont_wght.ttf).
///
/// Usage:
/// ```swift
/// Text("Question text")
///     .breathingTypography()
///
/// // With custom duration and scale effect
/// Text("Question text")
///     .breathingTypography(duration: 4.0, includeScale: true)
/// ```
struct BreathingTypography: ViewModifier {
    @State private var isActive: Bool = false

    let fontFamilyName: String
    let fontSize: CGFloat
    let duration: Double
    let includeScale: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Weight Range Constants (Dramatic, visible range)

    // NOTE: Playfair Display variable font weight range is 400-900
    // Using numeric axis key 2003265652 (FourCC for 'wght') is REQUIRED for iOS

    /// Minimum weight: Regular (400) - creates contrast and "exhale" feeling
    private static let minWeight: CGFloat = 400

    /// Maximum weight: Black (900) - creates presence and "inhale" feeling
    private static let maxWeight: CGFloat = 900

    /// Center weight for oscillation calculation
    private static var centerWeight: CGFloat { (minWeight + maxWeight) / 2 }  // 650

    /// Amplitude of weight oscillation
    private static var weightAmplitude: CGFloat { (maxWeight - minWeight) / 2 }  // 250

    // MARK: - Scale Constants

    /// Subtle scale pulse synchronized with weight (1.0 → 1.01)
    private static let minScale: CGFloat = 1.0
    private static let maxScale: CGFloat = 1.01

    /// Animation update interval (~30fps) - TimelineView only updates when view is visible
    private static let animationInterval: Double = 0.033

    init(
        fontFamilyName: String = FontFamily.playfairDisplay,
        fontSize: CGFloat = 28,
        duration: Double = 5.0,
        includeScale: Bool = true
    ) {
        self.fontFamilyName = fontFamilyName
        self.fontSize = fontSize
        self.duration = duration
        self.includeScale = includeScale
    }

    // MARK: - Animation Value Calculation

    /// Calculate weight for a given phase: oscillates between 400 and 900
    /// Formula: 650 + sin(phase * 2 * pi) * 250
    private func weight(for phase: Double) -> CGFloat {
        Self.centerWeight + sin(phase * 2 * .pi) * Self.weightAmplitude
    }

    /// Calculate scale for a given phase: subtle pulse synchronized with weight
    /// Formula: 1.0 + (sin(phase * 2 * pi) + 1) / 2 * 0.01
    /// When weight is at max (900), scale is at max (1.01)
    private func scale(for phase: Double) -> CGFloat {
        guard includeScale else { return 1.0 }
        let normalizedSin = (sin(phase * 2 * .pi) + 1) / 2  // 0 to 1
        return Self.minScale + normalizedSin * (Self.maxScale - Self.minScale)
    }

    /// Create font with specified weight (uses cached UIFont)
    private func font(for weight: CGFloat) -> Font {
        guard let uiFont = VariableFontCache.shared.font(
            family: fontFamilyName,
            size: fontSize,
            weight: weight
        ) else {
            // Fallback to static font if variable font creation fails
            return Font.custom(fontFamilyName, size: fontSize)
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
            let currentScale = scale(for: phase)

            content
                .font(font(for: currentWeight))
                .scaleEffect(currentScale)
        }
        .onAppear {
            isActive = !reduceMotion
        }
        .onDisappear {
            isActive = false
        }
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
    ///   - fontFamilyName: The variable font family name (default: "Playfair Display")
    ///   - fontSize: The font size in points (default: 28)
    ///   - duration: The animation cycle duration in seconds (default: 5.0)
    ///   - includeScale: Whether to include subtle scale pulse (default: true)
    /// - Returns: A view with breathing typography animation applied
    func breathingTypography(
        fontFamilyName: String = FontFamily.playfairDisplay,
        fontSize: CGFloat = 28,
        duration: Double = 5.0,
        includeScale: Bool = true
    ) -> some View {
        modifier(BreathingTypography(
            fontFamilyName: fontFamilyName,
            fontSize: fontSize,
            duration: duration,
            includeScale: includeScale
        ))
    }

    /// Applies breathing animation using the appropriate font for the given language.
    ///
    /// - Parameters:
    ///   - language: The language code ("en" for English, "ko" for Korean)
    ///   - fontSize: The font size in points (default: 28)
    ///   - duration: The animation cycle duration in seconds (default: 5.0)
    ///   - includeScale: Whether to include subtle scale pulse (default: true)
    /// - Returns: A view with breathing typography animation applied
    func breathingTypography(
        for language: String,
        fontSize: CGFloat = 28,
        duration: Double = 5.0,
        includeScale: Bool = true
    ) -> some View {
        let fontFamilyName = language == "ko" ? FontFamily.notoSerifKR : FontFamily.playfairDisplay
        return modifier(BreathingTypography(
            fontFamilyName: fontFamilyName,
            fontSize: fontSize,
            duration: duration,
            includeScale: includeScale
        ))
    }
}

// MARK: - Preview

#Preview("Breathing Typography - Dramatic") {
    VStack(spacing: 60) {
        Text("What is the dull and persistent dissatisfaction you've learned to live with?")
            .breathingTypography()
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 24)

        Divider()
            .background(Color.gray)

        Text("Static comparison (no breathing)")
            .font(.custom("Playfair Display", size: 28))
            .foregroundColor(.gray)
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#Preview("Breathing Typography - Korean") {
    Text("당신이 살면서 당연하게 받아들이게 된, 둔하고 지속적인 불만족은 무엇인가요?")
        .breathingTypography(for: "ko")
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}

#Preview("Breathing Typography - Fast Cycle") {
    Text("Faster breathing creates urgency")
        .breathingTypography(duration: 3.0)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}

#Preview("Breathing Typography - No Scale") {
    Text("Weight only, no scale effect")
        .breathingTypography(includeScale: false)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
