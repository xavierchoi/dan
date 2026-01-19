import SwiftUI

struct QuestionView: View {
    let text: String
    var language: String = "en"
    var isExiting: Bool = false

    /// Calculate adaptive font size based on text length
    /// More aggressive scaling for longer questions to prevent truncation
    /// - > 200 chars: 20pt
    /// - > 150 chars: 22pt
    /// - > 100 chars: 24pt
    /// - > 60 chars: 26pt
    /// - Otherwise: 28pt
    private var adaptiveFontSize: CGFloat {
        if text.count > 200 {
            return 20
        } else if text.count > 150 {
            return 22
        } else if text.count > 100 {
            return 24
        } else if text.count > 60 {
            return 26
        } else {
            return 28
        }
    }

    var body: some View {
        let parsed = EmphasisParser.parse(text, language: language)
        WeightCascadeText(
            text: parsed.plainText,
            language: language,
            fontSize: adaptiveFontSize,
            breatheAfterCascade: true,
            emphasisRanges: parsed.ranges.map(\.range)
        )
        .foregroundColor(.dpPrimaryText)
        .lineSpacing(Spacing.lineSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.questionTopPadding)
        .padding(.horizontal, Spacing.screenPadding)
        // Dramatic entrance: converges from edges like film title sequence
        .edgeConvergence(isExiting: isExiting)
        // Exit effect: afterimage ghost when transitioning out
        .afterimage(isActive: isExiting)
        // Chromatic aberration flash during exit
        .chromaticAberration(isActive: isExiting, offset: 4)
    }
}

#Preview("Question - Normal") {
    QuestionView(text: "What is the dull and persistent dissatisfaction you've learned to live with?")
        .background(Color.dpBackground)
}

#Preview("Question - Long Text") {
    QuestionView(
        text: "What do you complain about repeatedly but never actually change? Write down the three complaints you've voiced most often in the past year."
    )
    .background(Color.dpBackground)
}

#Preview("Question - Korean") {
    QuestionView(
        text: "당신이 삶의 일부로 받아들인, 희미하지만 끊이지 않는 불만족은 무엇인가요?",
        language: "ko"
    )
    .background(Color.dpBackground)
}

#Preview("Question - Convergence Entrance") {
    QuestionConvergencePreview()
}

#Preview("Question - Full Transition") {
    QuestionFullTransitionPreview()
}

/// Helper view for testing the convergence entrance effect
private struct QuestionConvergencePreview: View {
    @State private var showQuestion = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Tap to trigger entrance animation")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            if showQuestion {
                QuestionView(
                    text: "What is the dull and persistent dissatisfaction you've learned to live with?"
                )
            }

            Spacer()

            Button(showQuestion ? "Hide & Reset" : "Show Question") {
                if showQuestion {
                    showQuestion = false
                } else {
                    showQuestion = true
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.dpBackground)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.dpPrimaryText)
            .cornerRadius(8)
            .padding(.bottom, 40)
        }
        .background(Color.dpBackground)
    }
}

/// Helper view for testing full question transitions (entrance + exit)
private struct QuestionFullTransitionPreview: View {
    @State private var isExiting = false
    @State private var questionIndex = 0
    @State private var showQuestion = true

    private let questions = [
        "What is the dull and persistent dissatisfaction you've learned to live with?",
        "What truth have you been avoiding?",
        "What would you do if you knew you could not fail?"
    ]

    var body: some View {
        VStack(spacing: 40) {
            Text("Question \(questionIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)
                .padding(.top, 20)

            if showQuestion {
                QuestionView(
                    text: questions[questionIndex],
                    isExiting: isExiting
                )
                .id(questionIndex)
            }

            Spacer()

            HStack(spacing: 16) {
                Button("Exit Only") {
                    triggerExit()
                }
                .disabled(isExiting)

                Button("Next Question") {
                    cycleToNextQuestion()
                }
                .disabled(isExiting)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.dpBackground)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.dpPrimaryText)
            .cornerRadius(8)
            .padding(.bottom, 40)
        }
        .background(Color.dpBackground)
    }

    private func triggerExit() {
        isExiting = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            isExiting = false
        }
    }

    private func cycleToNextQuestion() {
        isExiting = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            showQuestion = false
            questionIndex = (questionIndex + 1) % questions.count

            try? await Task.sleep(nanoseconds: 100_000_000)
            isExiting = false
            showQuestion = true
        }
    }
}
