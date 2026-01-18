import SwiftUI

struct ReadyStepView: View {
    let language: String
    var onBack: () -> Void
    var onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing * 1.5) {
                Text(OnboardingLabels.youAreReady(for: language))
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: Spacing.elementSpacing) {
                    ReadyItem(
                        title: OnboardingLabels.part1Title(for: language),
                        description: OnboardingLabels.part1Description(for: language)
                    )

                    ReadyItem(
                        title: OnboardingLabels.part2Title(for: language),
                        description: OnboardingLabels.notificationExplanation(for: language)
                    )

                    ReadyItem(
                        title: OnboardingLabels.part3Title(for: language),
                        description: OnboardingLabels.part3Description(for: language)
                    )
                }
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                TextButton(
                    title: OnboardingLabels.startPart1(for: language),
                    action: onStart
                )

                TextButton(
                    title: NavLabels.back(for: language),
                    action: onBack
                )
            }
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }
}

// MARK: - ReadyItem

struct ReadyItem: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title)
                .font(.dpButton)
                .foregroundColor(.dpPrimaryText)

            Text(description)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.elementSpacing)
        .padding(.horizontal, Spacing.screenPadding)
        .overlay(
            Rectangle()
                .stroke(Color.dpSeparator, lineWidth: 1)
        )
    }
}

#Preview("English") {
    ReadyStepView(
        language: "en",
        onBack: {},
        onStart: {}
    )
}

#Preview("Korean") {
    ReadyStepView(
        language: "ko",
        onBack: {},
        onStart: {}
    )
}
