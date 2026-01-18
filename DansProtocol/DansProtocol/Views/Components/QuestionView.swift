import SwiftUI

struct QuestionView: View {
    let text: String
    var language: String = "en"
    var isExiting: Bool = false

    /// Calculate adaptive font size based on text length
    /// - > 150 chars: 24pt
    /// - > 100 chars: 26pt
    /// - Otherwise: 28pt
    private var adaptiveFontSize: CGFloat {
        if text.count > 150 {
            return 24
        } else if text.count > 100 {
            return 26
        } else {
            return 28
        }
    }

    var body: some View {
        WeightCascadeText(
            text: text,
            language: language,
            fontSize: adaptiveFontSize,
            breatheAfterCascade: true
        )
        .foregroundColor(.dpPrimaryText)
        .lineSpacing(Spacing.lineSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.questionTopPadding)
        .padding(.horizontal, Spacing.screenPadding)
        .afterimage(isActive: isExiting)
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

#Preview("Question - Afterimage") {
    QuestionViewAfterimagePreview()
}

/// Helper view for interactive afterimage preview
private struct QuestionViewAfterimagePreview: View {
    @State private var isExiting = false

    var body: some View {
        VStack(spacing: 40) {
            QuestionView(
                text: "What is the dull and persistent dissatisfaction you've learned to live with?",
                isExiting: isExiting
            )

            Spacer()

            Button(isExiting ? "Reset" : "Trigger Exit") {
                isExiting.toggle()
            }
            .padding()
        }
        .background(Color.dpBackground)
    }
}
