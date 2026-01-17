import SwiftUI
import SwiftData

struct InterruptView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: ProtocolSession
    let questionId: String
    var questionType: QuestionService.QuestionType = .interrupt
    var onDismiss: (() -> Void)?
    @State private var response: String = ""

    private var question: Question? {
        QuestionService.shared.questions(for: 2, type: questionType)
            .first { $0.id == questionId }
    }

    private var placeholder: String {
        session.language == "ko" ? "짧은 생각..." : "A brief thought..."
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                QuestionView(text: question?.text(for: session.language) ?? "", language: session.language)

                Spacer()

                MinimalTextField(
                    placeholder: placeholder,
                    text: $response
                )

                Spacer()

                HStack {
                    TextButton(title: NavLabels.skip(for: session.language), action: dismissView)

                    Spacer()

                    TextButton(
                        title: NavLabels.save(for: session.language),
                        action: saveAndDismiss,
                        isEnabled: !response.isEmpty
                    )
                }
                .padding(Spacing.screenPadding)
                .padding(.bottom, Spacing.screenPadding)
            }
        }
    }

    private func dismissView() {
        dismiss()
        onDismiss?()
    }

    private func saveAndDismiss() {
        guard let question = question else { return }

        let entry = JournalEntry(
            part: 2,
            questionKey: question.id,
            response: response
        )
        entry.session = session
        modelContext.insert(entry)

        dismissView()
    }
}

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return InterruptView(session: session, questionId: "p2_interrupt_1")
}
