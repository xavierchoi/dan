import SwiftUI
import SwiftData

struct SynthesisView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SynthesisViewModel
    var onComplete: () -> Void

    init(session: ProtocolSession, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: SynthesisViewModel(session: session))
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
                        TextButton(title: "← Back", action: viewModel.goBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLastQuestion ? "Complete →" : "Continue →",
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

@Observable
class SynthesisViewModel {
    var session: ProtocolSession
    var currentQuestionIndex: Int = 0
    var currentResponse: String = ""

    private let questions: [Question]

    init(session: ProtocolSession) {
        self.session = session
        self.questions = QuestionService.shared.questions(for: 3, type: .synthesis)
    }

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var questionText: String {
        currentQuestion?.text(for: session.language) ?? ""
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }

    var placeholder: String {
        session.language == "ko" ? "여기에 생각을 적어주세요..." : "Your thoughts..."
    }

    func saveAndNext(modelContext: ModelContext) {
        guard let question = currentQuestion else { return }

        if let existingEntry = session.entries.first(where: { $0.questionKey == question.id }) {
            existingEntry.response = currentResponse
        } else {
            let entry = JournalEntry(
                part: question.part,
                questionKey: question.id,
                response: currentResponse
            )
            entry.session = session
            modelContext.insert(entry)
        }

        currentResponse = ""
        currentQuestionIndex += 1
    }

    func goBack() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
        loadResponseForCurrentQuestion()
    }

    private func loadResponseForCurrentQuestion() {
        guard let question = currentQuestion else {
            currentResponse = ""
            return
        }
        if let existingEntry = session.entries.first(where: { $0.questionKey == question.id }) {
            currentResponse = existingEntry.response
        } else {
            currentResponse = ""
        }
    }
}

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return SynthesisView(session: session, onComplete: {})
}
