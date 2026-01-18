import SwiftUI

struct NotificationPermissionView: View {
    let language: String
    @State private var permissionDenied: Bool = false
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing * 1.5) {
                Text(OnboardingLabels.enableNotificationsTitle(for: language))
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                if permissionDenied {
                    VStack(spacing: Spacing.elementSpacing) {
                        Text(OnboardingLabels.notificationsDisabled(for: language))
                            .font(.dpBody)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)

                        Text(OnboardingLabels.enableLaterInSettings(for: language))
                            .font(.dpCaption)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)

                        TextButton(
                            title: OnboardingLabels.openSettings(for: language),
                            action: openSettings
                        )
                        .padding(.top, Spacing.elementSpacing)
                    }
                } else {
                    Text(OnboardingLabels.notificationExplanation(for: language))
                        .font(.dpBody)
                        .foregroundColor(.dpSecondaryText)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                if !permissionDenied {
                    TextButton(
                        title: OnboardingLabels.enableNotificationsButton(for: language),
                        action: requestPermission
                    )
                }

                HStack {
                    TextButton(title: NavLabels.back(for: language), action: onBack)
                    Spacer()
                    TextButton(
                        title: permissionDenied
                            ? OnboardingLabels.continueAnyway(for: language)
                            : OnboardingLabels.skipButton(for: language),
                        action: onContinue
                    )
                }
            }
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }

    private func requestPermission() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            await MainActor.run {
                if granted {
                    onContinue()
                } else {
                    permissionDenied = true
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview("Permission Pending") {
    NotificationPermissionView(
        language: "en",
        onBack: {},
        onContinue: {}
    )
}

#Preview("Permission Denied - Korean") {
    NotificationPermissionView(
        language: "ko",
        onBack: {},
        onContinue: {}
    )
}
