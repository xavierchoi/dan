import SwiftUI
import SwiftData

struct Part2WaitingView: View {
    let session: ProtocolSession
    var onStartPart3: () -> Void

    @Query private var entries: [JournalEntry]
    @State private var selectedContemplationQuestionId: String?
    @State private var showUnansweredAlert = false

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

    private var contemplationQuestions: [Question] {
        QuestionService.shared.questions(for: 2, type: .contemplation)
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

    private var unansweredCount: Int {
        interruptQuestions.count - answeredCount
    }

    private var hasExhaustedSnoozeQuestions: Bool {
        !SnoozeStore.maxSnoozedQuestionIds(sessionId: session.id).isEmpty
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
                            QuestionStatusRow(
                                question: question,
                                language: session.language,
                                isAnswered: isAnswered(question)
                            )
                        }
                    }

                    // 스누즈 소진된 질문이 있을 때 안내 메시지 표시
                    if hasExhaustedSnoozeQuestions {
                        Text(Part2Labels.snoozeExhausted(for: session.language))
                            .font(.dpCaption)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.screenPadding)
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

                            Text(Part2Labels.safeToClose(for: session.language))
                                .font(.dpCaption)
                                .foregroundColor(.dpSecondaryText)
                                .padding(.top, Spacing.elementSpacing)
                        }
                    }

                    // Contemplation Questions Section
                    if !contemplationQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                            Rectangle()
                                .fill(Color.dpSeparator)
                                .frame(height: 1)
                                .padding(.top, Spacing.elementSpacing)

                            Text(Part2Labels.additionalReflection(for: session.language))
                                .font(.dpCaption)
                                .foregroundColor(.dpSecondaryText)

                            ForEach(contemplationQuestions) { question in
                                QuestionStatusRow(
                                    question: question,
                                    language: session.language,
                                    isAnswered: isAnswered(question),
                                    showArrow: true,
                                    onTap: { selectedContemplationQuestionId = question.id }
                                )
                            }
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
                            action: {
                                if allAnswered {
                                    onStartPart3()
                                } else {
                                    showUnansweredAlert = true
                                }
                            },
                            prominence: allAnswered ? .primary : .secondary
                        )
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .sheet(item: Binding(
                get: { selectedContemplationQuestionId.map { ContemplationQuestionId(id: $0) } },
                set: { selectedContemplationQuestionId = $0?.id }
            )) { item in
                InterruptView(
                    session: session,
                    questionId: item.id,
                    questionType: .contemplation
                ) {
                    selectedContemplationQuestionId = nil
                }
            }
            .alert(
                AlertLabels.unansweredQuestionsTitle(for: session.language),
                isPresented: $showUnansweredAlert
            ) {
                Button(AlertLabels.goBack(for: session.language), role: .cancel) { }
                Button(AlertLabels.continueAnyway(for: session.language)) {
                    onStartPart3()
                }
            } message: {
                Text(AlertLabels.unansweredQuestionsMessage(count: unansweredCount, for: session.language))
            }
        }
    }
}

// Helper for sheet presentation
private struct ContemplationQuestionId: Identifiable {
    let id: String
}

struct QuestionStatusRow: View {
    let question: Question
    let language: String
    let isAnswered: Bool
    var showArrow: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        let content = HStack(alignment: .top, spacing: Spacing.rowPadding) {
            Text(isAnswered ? "✓" : "○")
                .font(.dpBody)
                .foregroundColor(isAnswered ? .dpPrimaryText : .dpSecondaryText)
                .frame(width: 20)

            Text(question.text(for: language))
                .font(.dpBody)
                .foregroundColor(isAnswered ? .dpPrimaryText : .dpSecondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            if showArrow {
                Text("→")
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
            }
        }
        .padding(.vertical, Spacing.elementSpacing)
        .contentShape(Rectangle())

        if let onTap = onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}
