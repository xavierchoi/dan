import SwiftUI
import SwiftData

struct JournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: JournalingViewModel
    @State private var isQuestionExiting: Bool = false
    @State private var isTransitioning: Bool = false
    @State private var displayedQuestionText: String = ""
    var onComplete: () -> Void

    /// Duration for the afterimage effect to complete before showing new question
    private let transitionDuration: Double = 0.6

    // MARK: - Animation Thresholds

    /// Minimum intensity for micro-tremor effect to be visible (performance optimization)
    private let microTremorThreshold: Double = 0.15
    /// Minimum intensity for dithering overlay to be visible (performance optimization)
    private let ditheringThreshold: Double = 0.08

    init(session: ProtocolSession, part: Int, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: JournalingViewModel(session: session, part: part))
        self.onComplete = onComplete
    }

    /// Dithering intensity based on progress - always visible, scales with tension
    /// Base 0.15 ensures film grain is visible from start, scales to 0.5 at completion
    private var ditheringIntensity: Double {
        0.15 + (viewModel.progress * 0.35)  // 0.15 -> 0.5
    }

    /// Micro-tremor intensity based on progress
    private var microTremorIntensity: Double {
        0.2 + viewModel.progress * 0.3
    }

    // MARK: - Animation Enabled Flags (Performance Optimization)

    /// Whether micro-tremor effect should be active
    /// Skipped when: reduceMotion enabled OR intensity below threshold
    private var isMicroTremorEnabled: Bool {
        !reduceMotion && microTremorIntensity >= microTremorThreshold
    }

    /// Whether edge glow should be active
    /// Always active but pulsing respects reduceMotion (handled internally)
    private var isEdgeGlowEnabled: Bool {
        viewModel.progress > 0
    }

    /// Whether dithering overlay should be active
    /// Skipped when intensity below threshold (reduceMotion handled internally)
    private var isDitheringEnabled: Bool {
        ditheringIntensity >= ditheringThreshold
    }

    /// Whether pulsing should be active for edge glow
    /// Respects reduceMotion setting
    private var isPulsingEnabled: Bool {
        !reduceMotion && viewModel.progress > 0.8
    }

    var body: some View {
        GeometryReader { geometry in
            // Question area: 40% of available height, minimum 200pt for readability
            let questionAreaHeight = max(geometry.size.height * 0.40, 200)
            let buttonAreaHeight: CGFloat = 80
            let inputAreaHeight = max(geometry.size.height - questionAreaHeight - buttonAreaHeight - geometry.safeAreaInsets.bottom, 120)

            ZStack {
                // MARK: - Background Layer with Effects (drawingGroup compatible)
                // This layer contains all visual effects and can use Metal offscreen rendering
                effectsLayer(
                    questionAreaHeight: questionAreaHeight,
                    inputAreaHeight: inputAreaHeight,
                    buttonAreaHeight: buttonAreaHeight
                )
                .modifier(OptionalMicroTremor(
                    intensity: microTremorIntensity,
                    enabled: isMicroTremorEnabled
                ))
                .modifier(OptionalEdgeGlow(
                    progress: viewModel.progress,
                    pulsing: isPulsingEnabled,
                    enabled: isEdgeGlowEnabled
                ))
                .modifier(OptionalPressureTransition(
                    isActive: isTransitioning,
                    enabled: !reduceMotion
                ))
                .modifier(OptionalChromaticAberration(
                    isActive: isQuestionExiting,
                    enabled: !reduceMotion
                ))
                .modifier(OptionalDithering(
                    intensity: ditheringIntensity,
                    animated: !reduceMotion,
                    enabled: isDitheringEnabled
                ))
                .drawingGroup()  // Metal offscreen rendering for effects layer only

                // MARK: - TextField Layer (outside drawingGroup)
                // UIKit-based TextField cannot be flattened by Metal rendering
                textFieldLayer(
                    questionAreaHeight: questionAreaHeight,
                    inputAreaHeight: inputAreaHeight,
                    buttonAreaHeight: buttonAreaHeight
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            displayedQuestionText = viewModel.questionText
        }
    }

    // MARK: - View Components

    /// Effects layer: background, question, buttons, progress indicator
    /// This layer is compatible with .drawingGroup() Metal rendering
    private func effectsLayer(
        questionAreaHeight: CGFloat,
        inputAreaHeight: CGFloat,
        buttonAreaHeight: CGFloat
    ) -> some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // MARK: Question Area (fixed height, top-aligned, clipped if overflow)
                QuestionView(
                    text: displayedQuestionText,
                    language: viewModel.session.language,
                    isExiting: isQuestionExiting
                )
                .id(displayedQuestionText)
                .frame(height: questionAreaHeight, alignment: .top)
                .clipped()

                // MARK: Input Area (placeholder - actual TextField in separate layer)
                Color.clear
                    .frame(height: inputAreaHeight)

                // MARK: Button Area
                HStack {
                    if viewModel.currentQuestionIndex > 0 {
                        TextButton(title: NavLabels.back(for: viewModel.session.language), action: handleGoBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLastQuestion ? NavLabels.complete(for: viewModel.session.language) : NavLabels.continueButton(for: viewModel.session.language),
                        action: handleContinue,
                        isEnabled: viewModel.canProceed
                    )
                }
                .frame(height: buttonAreaHeight)
                .padding(.horizontal, Spacing.screenPadding)
            }

            // Progress indicator overlay in top-right
            VStack {
                HStack {
                    Spacer()
                    let totalQuestions = viewModel.totalQuestions
                    let currentNumber = totalQuestions == 0
                        ? 0
                        : min(viewModel.currentQuestionIndex + 1, totalQuestions)
                    Text(String(format: "%02d / %02d", currentNumber, totalQuestions))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.dpSecondaryText)
                        .padding(.trailing, Spacing.screenPadding)
                        .padding(.top, Spacing.elementSpacing)
                }
                Spacer()
            }
        }
    }

    /// TextField layer: positioned to match the placeholder in effects layer
    /// Kept outside drawingGroup to avoid Metal rendering incompatibility
    private func textFieldLayer(
        questionAreaHeight: CGFloat,
        inputAreaHeight: CGFloat,
        buttonAreaHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Question area spacer
            Color.clear
                .frame(height: questionAreaHeight)

            // MARK: Input Area with visual separator
            VStack(spacing: 0) {
                // Top separator line
                Rectangle()
                    .fill(Color.dpSeparator.opacity(0.5))
                    .frame(height: 1)
                    .padding(.horizontal, Spacing.screenPadding)

                Spacer()
                    .frame(height: Spacing.elementSpacing)

                MinimalTextField(
                    placeholder: viewModel.placeholder,
                    text: $viewModel.currentResponse
                )

                Spacer()
            }
            .frame(height: inputAreaHeight)

            // Button area spacer
            Color.clear
                .frame(height: buttonAreaHeight)
        }
    }

    /// Handle going back to previous question with transition
    private func handleGoBack() {
        // Prevent rapid tapping
        guard !isTransitioning else { return }
        isTransitioning = true

        // Trigger haptic feedback
        HapticEngine.shared.buttonTap()

        // Trigger afterimage effect
        isQuestionExiting = true

        // After transition, update to previous question
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            viewModel.goBack()
            displayedQuestionText = viewModel.questionText
            isQuestionExiting = false
            isTransitioning = false

            // Haptic feedback for question transition
            HapticEngine.shared.questionTransition(progress: viewModel.progress)
        }
    }

    /// Handle continuing to next question or completing
    private func handleContinue() {
        // Prevent rapid tapping
        guard !isTransitioning else { return }
        isTransitioning = true

        // Trigger haptic feedback
        HapticEngine.shared.buttonTap()

        let wasLastQuestion = viewModel.isLastQuestion

        // Save immediately before animation to prevent data loss
        viewModel.saveAndNext(modelContext: modelContext)

        // Trigger afterimage effect
        isQuestionExiting = true

        // After transition, update UI (save already completed)
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            if wasLastQuestion || viewModel.currentQuestion == nil {
                onComplete()
            } else {
                displayedQuestionText = viewModel.questionText
                isQuestionExiting = false
                isTransitioning = false

                // Haptic feedback for question transition
                HapticEngine.shared.questionTransition(progress: viewModel.progress)
            }
        }
    }
}

// MARK: - Conditional Modifier Wrappers

/// Conditionally applies the micro-tremor effect.
/// When disabled, passes content through unchanged to avoid GPU overhead.
private struct OptionalMicroTremor: ViewModifier {
    let intensity: Double
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.microTremor(intensity: intensity)
        } else {
            content
        }
    }
}

/// Conditionally applies the edge glow effect.
/// When disabled, passes content through unchanged to avoid GPU overhead.
private struct OptionalEdgeGlow: ViewModifier {
    let progress: Double
    let pulsing: Bool
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.edgeGlow(progress: progress, pulsing: pulsing)
        } else {
            content
        }
    }
}

/// Conditionally applies the pressure transition effect.
/// When disabled, passes content through unchanged to avoid GPU overhead.
private struct OptionalPressureTransition: ViewModifier {
    let isActive: Bool
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.pressureTransition(isActive: isActive)
        } else {
            content
        }
    }
}

/// Conditionally applies the chromatic aberration effect.
/// When disabled, passes content through unchanged to avoid GPU overhead.
private struct OptionalChromaticAberration: ViewModifier {
    let isActive: Bool
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.chromaticAberration(isActive: isActive)
        } else {
            content
        }
    }
}

/// Conditionally applies the dithering overlay effect.
/// When disabled, passes content through unchanged to avoid GPU overhead.
private struct OptionalDithering: ViewModifier {
    let intensity: Double
    let animated: Bool
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.ditheringOverlay(intensity: intensity, animated: animated)
        } else {
            content
        }
    }
}

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return JournalingView(session: session, part: 1, onComplete: {})
}
