import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing * 1.5) {
                Text(OnboardingLabels.chooseLanguage(for: selectedLanguage))
                    .font(.dpQuestionLarge(for: selectedLanguage))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: Spacing.elementSpacing) {
                    LanguageOption(
                        title: "English",
                        code: "en",
                        isSelected: selectedLanguage == "en",
                        onSelect: {
                            HapticEngine.shared.buttonTap()
                            selectedLanguage = "en"
                        }
                    )

                    LanguageOption(
                        title: "한국어",
                        code: "ko",
                        isSelected: selectedLanguage == "ko",
                        onSelect: {
                            HapticEngine.shared.buttonTap()
                            selectedLanguage = "ko"
                        }
                    )
                }
            }

            Spacer()

            HStack {
                TextButton(title: NavLabels.back(for: selectedLanguage), action: onBack)
                Spacer()
                TextButton(title: NavLabels.continueButton(for: selectedLanguage), action: onContinue)
            }
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
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
