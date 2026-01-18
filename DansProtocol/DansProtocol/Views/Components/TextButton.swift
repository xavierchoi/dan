import SwiftUI

enum ButtonProminence {
    case primary
    case secondary
}

struct TextButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var prominence: ButtonProminence = .primary

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(prominence == .primary ? .dpButton : .dpCaption)
                .foregroundColor(foregroundColor)
                .underline(prominence == .primary && isEnabled)
        }
        .disabled(!isEnabled)
    }

    private var foregroundColor: Color {
        if !isEnabled {
            return .dpSecondaryText.opacity(0.5)
        }
        return prominence == .primary ? .dpPrimaryText : .dpSecondaryText
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
