import SwiftUI

struct SessionDetailView: View {
    let session: ProtocolSession

    private var dateString: String {
        guard let completedAt = session.completedAt else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: completedAt)
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text(dateString)
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.elementSpacing)

                    if let components = session.components {
                        VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                            ComponentSection(
                                title: session.language == "ko" ? "안티비전" : "Anti-Vision",
                                value: components.antiVision
                            )

                            ComponentSection(
                                title: session.language == "ko" ? "비전" : "Vision",
                                value: components.vision
                            )

                            ComponentSection(
                                title: session.language == "ko" ? "1년 목표" : "1-Year Goal",
                                value: components.oneYearGoal
                            )

                            ComponentSection(
                                title: session.language == "ko" ? "1개월 프로젝트" : "1-Month Project",
                                value: components.oneMonthProject
                            )

                            ComponentSection(
                                title: session.language == "ko" ? "일일 레버" : "Daily Levers",
                                value: components.dailyLevers.joined(separator: " • ")
                            )

                            ComponentSection(
                                title: session.language == "ko" ? "제약 조건" : "Constraints",
                                value: components.constraints,
                                showSeparator: false
                            )
                        }
                    } else {
                        Text(session.language == "ko" ? "데이터 없음" : "No data available")
                            .font(.dpBody)
                            .foregroundColor(.dpSecondaryText)
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ComponentSection: View {
    let title: String
    let value: String
    var showSeparator: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title.uppercased())
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
                .tracking(1)

            Text(value.isEmpty ? "—" : value)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            if showSeparator {
                Rectangle()
                    .fill(Color.dpSeparator)
                    .frame(height: 1)
                    .padding(.top, Spacing.lineSpacing)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(
            session: ProtocolSession(
                startDate: Date(),
                wakeUpTime: Date(),
                language: "en",
                status: .completed
            )
        )
    }
}
