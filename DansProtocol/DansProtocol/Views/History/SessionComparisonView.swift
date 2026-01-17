import SwiftUI

struct SessionComparisonView: View {
    let current: ProtocolSession
    let previous: ProtocolSession

    private var currentDateString: String {
        formatDate(current.completedAt)
    }

    private var previousDateString: String {
        formatDate(previous.completedAt)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    private var language: String {
        current.language
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text("Then vs Now")
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.elementSpacing)

                    ComparisonHeader(
                        previousDate: previousDateString,
                        currentDate: currentDateString
                    )

                    if let currentComponents = current.components,
                       let previousComponents = previous.components {
                        VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                            ComparisonRow(
                                title: language == "ko" ? "안티비전" : "Anti-Vision",
                                previousValue: previousComponents.antiVision,
                                currentValue: currentComponents.antiVision
                            )

                            ComparisonRow(
                                title: language == "ko" ? "비전" : "Vision",
                                previousValue: previousComponents.vision,
                                currentValue: currentComponents.vision
                            )

                            ComparisonRow(
                                title: language == "ko" ? "1년 목표" : "1-Year Goal",
                                previousValue: previousComponents.oneYearGoal,
                                currentValue: currentComponents.oneYearGoal
                            )

                            ComparisonRow(
                                title: language == "ko" ? "1개월 프로젝트" : "1-Month Project",
                                previousValue: previousComponents.oneMonthProject,
                                currentValue: currentComponents.oneMonthProject
                            )

                            ComparisonRow(
                                title: language == "ko" ? "일일 레버" : "Daily Levers",
                                previousValue: previousComponents.dailyLevers.joined(separator: " • "),
                                currentValue: currentComponents.dailyLevers.joined(separator: " • ")
                            )

                            ComparisonRow(
                                title: language == "ko" ? "제약 조건" : "Constraints",
                                previousValue: previousComponents.constraints,
                                currentValue: currentComponents.constraints
                            )
                        }
                    } else {
                        Text(language == "ko" ? "비교 데이터 없음" : "No comparison data available")
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

struct ComparisonHeader: View {
    let previousDate: String
    let currentDate: String

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("THEN")
                    .font(.dpCaption)
                    .foregroundColor(.dpSecondaryText)
                    .tracking(1)
                Text(previousDate)
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(width: 1, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("NOW")
                    .font(.dpCaption)
                    .foregroundColor(.dpPrimaryText)
                    .tracking(1)
                Text(currentDate)
                    .font(.dpBody)
                    .foregroundColor(.dpPrimaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Spacing.elementSpacing)
        }
        .padding(.vertical, Spacing.elementSpacing)
    }
}

struct ComparisonRow: View {
    let title: String
    let previousValue: String
    let currentValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title.uppercased())
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
                .tracking(1)

            HStack(alignment: .top, spacing: 0) {
                Text(previousValue.isEmpty ? "—" : previousValue)
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.dpSeparator)
                    .frame(width: 1)
                    .padding(.horizontal, Spacing.lineSpacing)

                Text(currentValue.isEmpty ? "—" : currentValue)
                    .font(.dpBody)
                    .foregroundColor(.dpPrimaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
                .padding(.top, Spacing.lineSpacing)
        }
    }
}

#Preview {
    NavigationStack {
        SessionComparisonView(
            current: ProtocolSession(
                startDate: Date(),
                wakeUpTime: Date(),
                language: "en",
                status: .completed
            ),
            previous: ProtocolSession(
                startDate: Date().addingTimeInterval(-86400 * 30),
                wakeUpTime: Date(),
                language: "en",
                status: .completed
            )
        )
    }
}
