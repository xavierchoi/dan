import SwiftUI
import UIKit

/// A view that displays text where each word sequentially "gains weight" with a staggered animation.
///
/// When the view appears, words animate from Light (300) to Regular (400) weight
/// one after another, creating a cascade effect that draws attention to the question.
///
/// After the cascade completes, optionally transitions to a subtle "breathing" effect
/// where all words oscillate between weights 350-450 over an 8-second cycle.
///
/// Usage:
/// ```swift
/// WeightCascadeText(text: "What matters most to you?", language: "en")
/// WeightCascadeText(text: "무엇이 가장 중요합니까?", language: "ko")
/// WeightCascadeText(text: "No breathing", language: "en", breatheAfterCascade: false)
/// ```
struct WeightCascadeText: View {
    let text: String
    let language: String
    let fontSize: CGFloat
    let breatheAfterCascade: Bool
    let emphasisRanges: [Range<String.Index>]

    /// Animation start time - all timing is calculated from this reference
    @State private var startTime: Date?
    @State private var isActive: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Animation Constants

    /// Animation update interval (~30fps) - TimelineView only updates when view is visible
    private static let animationInterval: Double = 0.033

    // NOTE: Playfair Display variable font weight range is 400-900
    // Using numeric axis key 2003265652 (FourCC for 'wght') is REQUIRED for iOS
    private static let startWeight: CGFloat = 400
    private static let endWeight: CGFloat = 500
    private static let baseDelayPerWord: Double = 0.1
    private static let weightTransitionDuration: Double = 0.3
    private static let maxTotalDuration: Double = 3.0

    // Breathing constants - DRAMATIC range for visible, felt effect
    // Inspired by kinetic typography (Se7en title sequence)
    // Weight oscillates between Regular (400) and Black (900) - full range!
    private static let breathingMinWeight: CGFloat = 400
    private static let breathingMaxWeight: CGFloat = 900
    private static let breathingDuration: Double = 5.0  // 5 second breathing cycle

    // Subtle scale pulse synchronized with weight breathing
    private static let breathingMinScale: CGFloat = 1.0
    private static let breathingMaxScale: CGFloat = 1.01

    init(
        text: String,
        language: String,
        fontSize: CGFloat = 28,
        breatheAfterCascade: Bool = true,
        emphasisRanges: [Range<String.Index>] = []
    ) {
        self.text = text
        self.language = language
        self.fontSize = fontSize
        self.breatheAfterCascade = breatheAfterCascade
        self.emphasisRanges = emphasisRanges
    }

    /// Split text into words preserving spacing information
    private var words: [String] {
        text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
    }

    /// Calculate the delay between each word's animation start
    private var delayPerWord: Double {
        let wordCount = words.count
        guard wordCount > 0 else { return Self.baseDelayPerWord }

        // For >30 words, cap total animation at 3 seconds
        // Total duration = (wordCount - 1) * delay + transitionDuration
        // For 30+ words: 3.0 = (wordCount - 1) * delay + 0.3
        // delay = (3.0 - 0.3) / (wordCount - 1)
        if wordCount > 30 {
            return (Self.maxTotalDuration - Self.weightTransitionDuration) / Double(wordCount - 1)
        }
        return Self.baseDelayPerWord
    }

    /// Total animation duration in seconds
    private var totalDuration: Double {
        let wordCount = words.count
        guard wordCount > 0 else { return Self.weightTransitionDuration }

        // Total = (wordCount - 1) * delay + transitionDuration
        return Double(wordCount - 1) * delayPerWord + Self.weightTransitionDuration
    }

    /// Font family name based on language (must use family name for variable font weight axis)
    private var fontFamilyName: String {
        language == "ko" ? FontFamily.notoSerifKR : FontFamily.playfairDisplay
    }

    /// Map words to ranges in the original text for emphasis lookup
    private var wordRanges: [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var start = text.startIndex

        for (index, word) in words.enumerated() {
            let end = text.index(start, offsetBy: word.count)
            ranges.append(start..<end)

            if index < words.count - 1, end < text.endIndex {
                start = text.index(after: end)
            }
        }

        return ranges
    }

    /// Calculate breathing weight for a given phase: oscillates between 400 and 900
    /// Formula: 650 + sin(phase * 2 * pi) * 250
    private func breathingWeight(for phase: Double) -> CGFloat {
        let centerWeight = (Self.breathingMinWeight + Self.breathingMaxWeight) / 2  // 650
        let amplitude = (Self.breathingMaxWeight - Self.breathingMinWeight) / 2      // 250
        return centerWeight + sin(phase * 2 * .pi) * amplitude
    }

    /// Calculate breathing scale for a given phase: subtle pulse synchronized with weight
    /// When weight is at max (900), scale is at max (1.01)
    private func breathingScale(for phase: Double) -> CGFloat {
        let normalizedSin = (sin(phase * 2 * .pi) + 1) / 2  // 0 to 1
        return Self.breathingMinScale + normalizedSin * (Self.breathingMaxScale - Self.breathingMinScale)
    }

    /// Calculate the weight for a word at a given index based on cascade progress and breathing state
    private func weightForWord(at index: Int, cascadeProgress: Double, breathingPhase: Double, isBreathing: Bool) -> CGFloat {
        // If breathing mode is active, all words breathe together
        if isBreathing {
            return breathingWeight(for: breathingPhase)
        }

        let currentTime = cascadeProgress * totalDuration
        let wordStartTime = Double(index) * delayPerWord
        let wordEndTime = wordStartTime + Self.weightTransitionDuration

        if currentTime < wordStartTime {
            // Animation hasn't reached this word yet
            return Self.startWeight
        } else if currentTime >= wordEndTime {
            // Animation for this word is complete
            return Self.endWeight
        } else {
            // Word is currently animating
            let wordProgress = (currentTime - wordStartTime) / Self.weightTransitionDuration
            // Use ease-out for natural feel: progress^0.5 gives faster start, slower end
            let easedProgress = sqrt(wordProgress)
            return Self.startWeight + (Self.endWeight - Self.startWeight) * CGFloat(easedProgress)
        }
    }

    /// Create a font with the specified weight and optional italic style
    private func font(weight: CGFloat, italic: Bool = false) -> Font {
        guard let uiFont = VariableFontCache.shared.font(
            family: fontFamilyName,
            size: fontSize,
            weight: weight,
            italic: italic
        ) else {
            // Fallback to static font
            return Font.custom(fontFamilyName, size: fontSize)
        }
        return Font(uiFont)
    }

    var body: some View {
        // TimelineView automatically pauses when view is not visible (battery efficient)
        // No timer accumulation issues - all timing is calculated from startTime
        TimelineView(.animation(minimumInterval: Self.animationInterval, paused: !isActive || reduceMotion)) { timeline in
            let now = timeline.date

            // Calculate animation state from elapsed time
            if let start = startTime {
                let elapsed = now.timeIntervalSince(start)

                // Cascade progress (0 to 1, clamped)
                let cascadeProgress = min(elapsed / totalDuration, 1.0)
                let cascadeComplete = cascadeProgress >= 1.0

                // Breathing phase (starts after cascade completes)
                let breathingElapsed = max(0, elapsed - totalDuration)
                let breathingPhase = breathingElapsed.truncatingRemainder(dividingBy: Self.breathingDuration) / Self.breathingDuration

                // Determine if in breathing mode
                let isBreathing = cascadeComplete && breatheAfterCascade

                // Build text content with calculated animation values
                textContent(cascadeProgress: cascadeProgress, breathingPhase: breathingPhase, isBreathing: isBreathing)
                    // Apply subtle scale pulse during breathing mode
                    .scaleEffect(isBreathing ? breathingScale(for: breathingPhase) : 1.0)
            } else {
                // Static content when reduceMotion is enabled
                textContent(cascadeProgress: 1.0, breathingPhase: 0, isBreathing: false)
            }
        }
        .onAppear {
            isActive = !reduceMotion
            // Set start time only if animation should run
            startTime = reduceMotion ? nil : Date()
        }
        .onDisappear {
            isActive = false
        }
    }

    /// Build the text content with per-word font weights
    @ViewBuilder
    private func textContent(cascadeProgress: Double, breathingPhase: Double, isBreathing: Bool) -> some View {
        let ranges = wordRanges

        // Use Text concatenation to apply different fonts per word
        words.enumerated().reduce(Text("")) { result, item in
            let (index, word) = item
            let weight = weightForWord(at: index, cascadeProgress: cascadeProgress, breathingPhase: breathingPhase, isBreathing: isBreathing)
            let wordRange = index < ranges.count ? ranges[index] : text.startIndex..<text.startIndex
            let isEmphasized = emphasisRanges.contains { $0.overlaps(wordRange) }

            // Apply italic font directly for emphasized words (synthesized oblique)
            let wordText = Text(word).font(font(weight: weight, italic: isEmphasized))

            // Add space after each word except the last
            if index < words.count - 1 {
                return result + wordText + Text(" ").font(font(weight: Self.endWeight))
            } else {
                return result + wordText
            }
        }
    }

}

// MARK: - Preview

#Preview("Weight Cascade - English") {
    VStack(spacing: 40) {
        WeightCascadeText(
            text: "What is the dull and persistent dissatisfaction you've learned to live with?",
            language: "en"
        )
        .foregroundColor(.white)
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#Preview("Weight Cascade - Korean") {
    WeightCascadeText(
        text: "당신이 살면서 당연하게 받아들이게 된, 둔하고 지속적인 불만족은 무엇인가요?",
        language: "ko"
    )
    .foregroundColor(.white)
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#Preview("Weight Cascade - Many Words") {
    WeightCascadeText(
        text: "This is a very long question with many many words to test the maximum animation duration constraint which should cap the total animation time at three seconds for better user experience when dealing with verbose text content",
        language: "en",
        fontSize: 20
    )
    .foregroundColor(.white)
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
