import SwiftUI

struct SessionComparisonView: View {
    let current: ProtocolSession
    let previous: ProtocolSession

    private var currentDateString: String {
        current.completedAt?.monthYearString ?? ""
    }

    private var previousDateString: String {
        previous.completedAt?.monthYearString ?? ""
    }

    private var language: String {
        current.language
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text(HistoryLabels.thenVsNow(for: language))
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.elementSpacing)

                    ComparisonHeader(
                        previousDate: previousDateString,
                        currentDate: currentDateString,
                        language: language
                    )

                    if let currentComponents = current.components,
                       let previousComponents = previous.components {
                        VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                            ComparisonRow(
                                title: ComponentLabels.antiVision(for: language),
                                previousValue: previousComponents.antiVision,
                                currentValue: currentComponents.antiVision
                            )

                            ComparisonRow(
                                title: ComponentLabels.vision(for: language),
                                previousValue: previousComponents.vision,
                                currentValue: currentComponents.vision
                            )

                            ComparisonRow(
                                title: ComponentLabels.oneYearGoal(for: language),
                                previousValue: previousComponents.oneYearGoal,
                                currentValue: currentComponents.oneYearGoal
                            )

                            ComparisonRow(
                                title: ComponentLabels.oneMonthProject(for: language),
                                previousValue: previousComponents.oneMonthProject,
                                currentValue: currentComponents.oneMonthProject
                            )

                            ComparisonRow(
                                title: ComponentLabels.dailyLevers(for: language),
                                previousValue: previousComponents.dailyLevers.joined(separator: " • "),
                                currentValue: currentComponents.dailyLevers.joined(separator: " • ")
                            )

                            ComparisonRow(
                                title: ComponentLabels.constraints(for: language),
                                previousValue: previousComponents.constraints,
                                currentValue: currentComponents.constraints
                            )
                        }
                    } else {
                        Text(ComponentLabels.noComparisonData(for: language))
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
    let language: String

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.smallSpacing) {
                Text(ComponentLabels.then(for: language))
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

            VStack(alignment: .leading, spacing: Spacing.smallSpacing) {
                Text(ComponentLabels.now(for: language))
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
