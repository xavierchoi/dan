import SwiftUI
import UIKit
import CoreText

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

    /// Current animation progress (0 to 1 for the entire cascade)
    @State private var animationProgress: Double = 0
    @State private var isAnimating: Bool = false

    /// Breathing animation phase (0 to 1 for one complete breathing cycle)
    @State private var breathingPhase: Double = 0
    @State private var isBreathing: Bool = false

    /// Timer fires every 33ms (~30fps) for smooth animation
    private static let timerInterval: Double = 0.033
    private let timer = Timer.publish(every: Self.timerInterval, on: .main, in: .common).autoconnect()

    // MARK: - Animation Constants

    private static let startWeight: CGFloat = 300
    private static let endWeight: CGFloat = 400
    private static let baseDelayPerWord: Double = 0.1
    private static let weightTransitionDuration: Double = 0.3
    private static let maxTotalDuration: Double = 3.0

    // Breathing constants (same as BreathingText)
    private static let breathingMinWeight: CGFloat = 350
    private static let breathingMaxWeight: CGFloat = 450
    private static let breathingDuration: Double = 8.0

    init(text: String, language: String, fontSize: CGFloat = 28, breatheAfterCascade: Bool = true) {
        self.text = text
        self.language = language
        self.fontSize = fontSize
        self.breatheAfterCascade = breatheAfterCascade
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

    /// Font name based on language
    private var fontName: String {
        language == "ko" ? "NotoSerifKR-Regular" : "PlayfairDisplay-Regular"
    }

    /// Current breathing weight: oscillates between 350 and 450
    /// Formula: 400 + sin(phase * 2 * pi) * 50
    private var breathingWeight: CGFloat {
        400 + sin(breathingPhase * 2 * .pi) * 50
    }

    /// Calculate the weight for a word at a given index based on current animation progress
    private func weightForWord(at index: Int) -> CGFloat {
        // If breathing mode is active, all words breathe together
        if isBreathing {
            return breathingWeight
        }

        let currentTime = animationProgress * totalDuration
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

    /// Create a font with the specified weight
    private func font(weight: CGFloat) -> Font {
        guard let uiFont = Self.createVariableFont(
            name: fontName,
            size: fontSize,
            weight: weight
        ) else {
            return Font.custom(fontName, size: fontSize)
        }
        return Font(uiFont)
    }

    var body: some View {
        textContent
            .onAppear {
                // Reset and start animation when view appears
                animationProgress = 0
                breathingPhase = 0
                isAnimating = true
                isBreathing = false
            }
            .onDisappear {
                isAnimating = false
                isBreathing = false
            }
            .onReceive(timer) { _ in
                // Handle breathing mode
                if isBreathing {
                    breathingPhase += Self.timerInterval / Self.breathingDuration
                    if breathingPhase >= 1 {
                        breathingPhase = 0
                    }
                    return
                }

                // Handle cascade animation
                guard isAnimating else { return }
                animationProgress += Self.timerInterval / totalDuration
                if animationProgress >= 1 {
                    animationProgress = 1
                    isAnimating = false

                    // Transition to breathing mode if enabled
                    if breatheAfterCascade {
                        isBreathing = true
                    }
                }
            }
    }

    /// Build the text content with per-word font weights
    @ViewBuilder
    private var textContent: some View {
        // Use Text concatenation to apply different fonts per word
        words.enumerated().reduce(Text("")) { result, item in
            let (index, word) = item
            let weight = weightForWord(at: index)
            let wordText = Text(word).font(font(weight: weight))

            // Add space after each word except the last
            if index < words.count - 1 {
                return result + wordText + Text(" ").font(font(weight: Self.endWeight))
            } else {
                return result + wordText
            }
        }
    }

    // MARK: - Variable Font Creation

    /// Creates a UIFont with a specific weight value for variable fonts.
    ///
    /// Uses Core Text's variation attribute to interpolate the font weight.
    ///
    /// - Parameters:
    ///   - name: The font name (e.g., "PlayfairDisplay-Regular")
    ///   - size: The font size in points
    ///   - weight: The weight value (300-400 for this animation)
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
