import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text("Choose your language")
                    .font(.dpQuestionLarge)
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: Spacing.elementSpacing) {
                    LanguageOption(
                        title: "English",
                        code: "en",
                        isSelected: selectedLanguage == "en",
                        onSelect: { selectedLanguage = "en" }
                    )

                    LanguageOption(
                        title: "\u{D55C}\u{AD6D}\u{C5B4}",
                        code: "ko",
                        isSelected: selectedLanguage == "ko",
                        onSelect: { selectedLanguage = "ko" }
                    )
                }
            }

            Spacer()

            HStack {
                TextButton(title: "\u{2190} Back", action: onBack)
                Spacer()
                TextButton(title: "Continue \u{2192}", action: onContinue)
            }
            .padding(.bottom, Spacing.sectionSpacing)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }
}

// MARK: - LanguageOption

struct LanguageOption: View {
    let title: String
    let code: String
    let isSelected: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(title)
                    .font(.dpBody)
                    .foregroundColor(.dpPrimaryText)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.dpPrimaryText)
                }
            }
            .padding(.vertical, Spacing.elementSpacing)
            .padding(.horizontal, Spacing.screenPadding)
            .overlay(
                Rectangle()
                    .stroke(isSelected ? Color.dpPrimaryText : Color.dpSeparator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguageSelectionView(
        selectedLanguage: .constant("en"),
        onBack: {},
        onContinue: {}
    )
}
