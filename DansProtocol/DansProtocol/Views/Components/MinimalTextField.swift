import SwiftUI

struct MinimalTextField: View {
    let placeholder: String
    @Binding var text: String
    var lineRange: ClosedRange<Int> = 5...10
    var isFocused: FocusState<Bool>.Binding?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            textField

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
        .padding(.horizontal, Spacing.screenPadding)
    }

    @ViewBuilder
    private var textField: some View {
        let field = TextField(placeholder, text: $text, axis: .vertical)
            .font(.dpBody)
            .foregroundColor(.dpPrimaryText)
            .lineLimit(lineRange)

        if let isFocused = isFocused {
            field.focused(isFocused)
        } else {
            field
        }
    }
}

#Preview {
    MinimalTextField(placeholder: "Your thoughts...", text: .constant(""))
        .background(Color.dpBackground)
}
