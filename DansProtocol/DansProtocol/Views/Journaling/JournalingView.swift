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
        }
        .edgeGlow(progress: viewModel.progress, position: .top, mode: .opacity)
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

        // Trigger afterimage effect
        isQuestionExiting = true

        // After transition, update to previous question
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            viewModel.goBack()
            displayedQuestionText = viewModel.questionText
            isQuestionExiting = false
            isTransitioning = false
        }
    }

    /// Handle continuing to next question or completing
    private func handleContinue() {
        // Prevent rapid tapping
        guard !isTransitioning else { return }
        isTransitioning = true

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
