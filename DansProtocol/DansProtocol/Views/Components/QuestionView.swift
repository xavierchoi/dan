import SwiftUI

struct QuestionView: View {
    let text: String
    var language: String = "en"

    var body: some View {
        Text(text)
            .font(.dpQuestionAdaptive(for: language, textLength: text.count))
            .foregroundColor(.dpPrimaryText)
            .lineSpacing(Spacing.lineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.questionTopPadding)
            .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview {
    QuestionView(text: "What is the dull and persistent dissatisfaction you've learned to live with?")
        .background(Color.dpBackground)
}
