import SwiftUI

struct NotificationPermissionView: View {
    let language: String
    @State private var permissionDenied: Bool = false
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text(language == "ko" ? "알림을 활성화하세요" : "Enable notifications")
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                if permissionDenied {
                    VStack(spacing: Spacing.elementSpacing) {
                        Text(language == "ko" ? "알림이 비활성화되어 있습니다" : "Notifications are disabled")
                            .font(.dpBody)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)

                        Text(language == "ko"
                             ? "Part 2 중단 알림을 받으려면 나중에 설정에서 활성화할 수 있습니다."
                             : "You can enable them later in Settings to receive Part 2 interruptions.")
                            .font(.dpCaption)
                            .foregroundColor(.dpSecondaryText)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text(language == "ko"
                         ? "Part 2에서는 하루 종일 무작위 알림이 필요합니다. 예상치 못한 순간에 성찰을 유도하는 알림을 보내드립니다."
                         : "Part 2 requires random interruptions throughout the day. We'll send you notifications to prompt reflection at unexpected moments.")
                        .font(.dpBody)
                        .foregroundColor(.dpSecondaryText)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                if !permissionDenied {
                    TextButton(
                        title: language == "ko" ? "알림 활성화" : "Enable Notifications",
                        action: requestPermission
                    )
                }

                HStack {
                    TextButton(title: language == "ko" ? "← 이전" : "← Back", action: onBack)
                    Spacer()
                    TextButton(
                        title: permissionDenied
                            ? (language == "ko" ? "그냥 계속 →" : "Continue anyway →")
                            : (language == "ko" ? "건너뛰기 →" : "Skip →"),
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
