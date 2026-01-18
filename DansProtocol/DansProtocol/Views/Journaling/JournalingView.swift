import SwiftUI
import SwiftData

struct JournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: JournalingViewModel
    @State private var isQuestionExiting: Bool = false
    @State private var isTransitioning: Bool = false
    @State private var displayedQuestionText: String = ""
    var onComplete: () -> Void

    /// Duration for the afterimage effect to complete before showing new question
    private let transitionDuration: Double = 0.6

    init(session: ProtocolSession, part: Int, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: JournalingViewModel(session: session, part: part))
        self.onComplete = onComplete
    }

    /// Dithering intensity based on progress (activates > 0.7)
    private var ditheringIntensity: Double {
        max(0, (viewModel.progress - 0.7) / 0.3) * 0.4
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                QuestionView(
                    text: displayedQuestionText,
                    language: viewModel.session.language,
                    isExiting: isQuestionExiting
                )
                .id(displayedQuestionText)  // Force view recreation to restart cascade animation

                Spacer()

                MinimalTextField(
                    placeholder: viewModel.placeholder,
                    text: $viewModel.currentResponse
                )

                Spacer()

                HStack {
                    if viewModel.currentQuestionIndex > 0 {
                        TextButton(title: NavLabels.back(for: viewModel.session.language), action: handleGoBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLastQuestion ? NavLabels.complete(for: viewModel.session.language) : NavLabels.continueButton(for: viewModel.session.language),
                        action: handleContinue,
                        isEnabled: !viewModel.currentResponse.isEmpty
                    )
                }
                .padding(Spacing.screenPadding)
                .padding(.bottom, Spacing.screenPadding)
            }

            // Progress indicator overlay in top-right
            VStack {
                HStack {
                    Spacer()
                    Text(String(format: "%02d / %02d", viewModel.currentQuestionIndex + 1, viewModel.totalQuestions))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.dpSecondaryText)
                        .padding(.trailing, Spacing.screenPadding)
                        .padding(.top, Spacing.screenPadding)
                }
                Spacer()
            }
        }
        .edgeGlow(progress: viewModel.progress, position: .frame, mode: .opacity, pulsing: viewModel.progress > 0.8)
        .pressureTransition(isActive: isTransitioning)
        .chromaticAberration(isActive: isQuestionExiting)
        .ditheringOverlay(intensity: ditheringIntensity, animated: viewModel.progress > 0.7)
        .onAppear {
            // Initialize displayed text on first appear
            displayedQuestionText = viewModel.questionText
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

        // Trigger afterimage effect
        isQuestionExiting = true

        // After transition, save and move to next
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            viewModel.saveAndNext(modelContext: modelContext)

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

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return JournalingView(session: session, part: 1, onComplete: {})
}
