import SwiftUI

struct CompletionView: View {
    let session: ProtocolSession
    var onContinue: () -> Void

    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text(session.language == "ko" ? "당신의 라이프 게임" : "Your Life Game")
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.questionTopPadding)

                    if let components = session.components {
                        ComponentRow(
                            title: session.language == "ko" ? "안티비전" : "Anti-Vision",
                            value: components.antiVision
                        )
                        ComponentRow(
                            title: session.language == "ko" ? "비전" : "Vision",
                            value: components.vision
                        )
                        ComponentRow(
                            title: session.language == "ko" ? "1년 목표" : "1-Year Goal",
                            value: components.oneYearGoal
                        )
                        ComponentRow(
                            title: session.language == "ko" ? "1달 프로젝트" : "1-Month Project",
                            value: components.oneMonthProject
                        )
                        ComponentRow(
                            title: session.language == "ko" ? "일일 레버" : "Daily Levers",
                            value: components.dailyLevers.joined(separator: "\n")
                        )
                        ComponentRow(
                            title: session.language == "ko" ? "제약" : "Constraints",
                            value: components.constraints
                        )
                    }

                    Spacer(minLength: Spacing.sectionSpacing)

                    HStack {
                        TextButton(
                            title: session.language == "ko" ? "공유" : "Share",
                            action: generateAndShare
                        )

                        Spacer()

                        TextButton(
                            title: session.language == "ko" ? "완료 →" : "Finish →",
                            action: onContinue
                        )
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func generateAndShare() {
        guard let components = session.components else { return }
        shareImage = ShareImageGenerator.generate(components: components, language: session.language)
        showingShareSheet = true
    }
}

struct ComponentRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)

            Text(value)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
    }
}
