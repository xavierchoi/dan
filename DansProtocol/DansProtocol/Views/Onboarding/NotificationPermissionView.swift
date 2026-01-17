import SwiftUI

struct NotificationPermissionView: View {
    @State private var permissionDenied: Bool = false
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text("Enable notifications")
                    .font(.dpQuestionLarge)
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                if permissionDenied {
                    VStack(spacing: Spacing.elementSpacing) {
                        Text("Notifications are disabled")
                            .font(.dpBody)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)

                        Text("You can enable them later in Settings to receive Part 2 interruptions.")
                            .font(.dpCaption)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Part 2 requires random interruptions throughout the day. We'll send you notifications to prompt reflection at unexpected moments.")
                        .font(.dpBody)
                        .foregroundColor(.dpSecondaryText)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                if !permissionDenied {
                    TextButton(title: "Enable Notifications", action: requestPermission)
                }

                HStack {
                    TextButton(title: "\u{2190} Back", action: onBack)
                    Spacer()
                    TextButton(
                        title: permissionDenied ? "Continue anyway \u{2192}" : "Skip \u{2192}",
                        action: onContinue
                    )
                }
            }
            .padding(.bottom, Spacing.sectionSpacing)
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
}

#Preview("Permission Pending") {
    NotificationPermissionView(
        onBack: {},
        onContinue: {}
    )
}

#Preview("Permission Denied") {
    struct DeniedPreview: View {
        @State private var view = NotificationPermissionView(
            onBack: {},
            onContinue: {}
        )

        var body: some View {
            NotificationPermissionView(
                onBack: {},
                onContinue: {}
            )
        }
    }
    return DeniedPreview()
}
