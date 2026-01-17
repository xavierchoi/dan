import SwiftUI
import SwiftData

struct Part2WaitingView: View {
    let session: ProtocolSession
    var onStartPart3: () -> Void

    @Query private var entries: [JournalEntry]

    init(session: ProtocolSession, onStartPart3: @escaping () -> Void) {
        self.session = session
        self.onStartPart3 = onStartPart3

        let sessionId = session.id
        _entries = Query(filter: #Predicate<JournalEntry> { entry in
            entry.part == 2 && entry.session?.id == sessionId
        })
    }

    private var interruptQuestions: [Question] {
        QuestionService.shared.questions(for: 2, type: .interrupt)
    }

    private func isAnswered(_ question: Question) -> Bool {
        entries.contains { $0.questionKey == question.id && !$0.response.isEmpty }
    }

    private var answeredCount: Int {
        interruptQuestions.filter { isAnswered($0) }.count
    }

    private var allAnswered: Bool {
        answeredCount == interruptQuestions.count
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text(Part2Labels.title(for: session.language))
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.questionTopPadding)

                    Text(Part2Labels.reflectionsCompleted(for: session.language, answered: answeredCount, total: interruptQuestions.count))
                        .font(.dpCaption)
                        .foregroundColor(.dpSecondaryText)

                    VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                        ForEach(interruptQuestions) { question in
                            InterruptStatusRow(
                                question: question,
                                language: session.language,
                                isAnswered: isAnswered(question)
                            )
                        }
                    }

                    if !allAnswered {
                        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
                            Rectangle()
                                .fill(Color.dpSeparator)
                                .frame(height: 1)

                            Text(Part2Labels.waitingForNotifications(for: session.language))
                                .font(.dpCaption)
                                .foregroundColor(.dpSecondaryText)

                            Text(Part2Labels.tapNotificationInstruction(for: session.language))
                                .font(.dpCaption)
                                .foregroundColor(.dpSecondaryText)
                        }
                    }

                    Spacer(minLength: Spacing.sectionSpacing)

                    VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                        if !allAnswered {
                            Text(Part2Labels.startPart3Recommendation(for: session.language))
                                .font(.dpCaption)
                                .foregroundColor(.dpSecondaryText)
                        }

                        TextButton(
                            title: Part2Labels.startPart3(for: session.language),
                            action: onStartPart3
                        )
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
    }
}

struct InterruptStatusRow: View {
    let question: Question
    let language: String
    let isAnswered: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(isAnswered ? "✓" : "○")
                .font(.dpBody)
                .foregroundColor(isAnswered ? .dpPrimaryText : .dpSecondaryText)
                .frame(width: 20)

            Text(question.text(for: language))
                .font(.dpBody)
                .foregroundColor(isAnswered ? .dpPrimaryText : .dpSecondaryText)
                .lineLimit(2)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
