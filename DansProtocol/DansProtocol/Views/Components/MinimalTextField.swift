import SwiftUI

struct MinimalTextField: View {
    let placeholder: String
    @Binding var text: String
    var lineRange: ClosedRange<Int> = 5...10

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)
                .lineLimit(lineRange)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
        .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview {
    MinimalTextField(placeholder: "Your thoughts...", text: .constant(""))
        .background(Color.dpBackground)
}
