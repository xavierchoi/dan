import SwiftUI

struct TextButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.dpButton)
                .foregroundColor(isEnabled ? .dpPrimaryText : .dpSecondaryText)
                .underline(isEnabled)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        TextButton(title: "Continue →", action: {})
        TextButton(title: "← Back", action: {})
        TextButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
    .background(Color.dpBackground)
}
