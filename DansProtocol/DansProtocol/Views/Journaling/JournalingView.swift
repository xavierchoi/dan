import SwiftUI
import SwiftData

struct JournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: JournalingViewModel
    var onComplete: () -> Void

    init(session: ProtocolSession, part: Int, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: JournalingViewModel(session: session, part: part))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                QuestionView(text: viewModel.questionText, language: viewModel.session.language)

                Spacer()

                MinimalTextField(
                    placeholder: viewModel.placeholder,
                    text: $viewModel.currentResponse
                )

                Spacer()

                HStack {
                    if viewModel.currentQuestionIndex > 0 {
                        TextButton(title: NavLabels.back(for: viewModel.session.language), action: viewModel.goBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLastQuestion ? NavLabels.complete(for: viewModel.session.language) : NavLabels.continueButton(for: viewModel.session.language),
                        action: {
                            viewModel.saveAndNext(modelContext: modelContext)
                            if viewModel.currentQuestion == nil {
                                onComplete()
                            }
                        },
                        isEnabled: !viewModel.currentResponse.isEmpty
                    )
                }
                .padding(Spacing.screenPadding)
                .padding(.bottom, Spacing.screenPadding)
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
