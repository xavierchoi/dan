import SwiftUI

struct SessionDetailView: View {
    let session: ProtocolSession

    private var dateString: String {
        session.completedAt?.longDateString ?? ""
    }

    private var language: String {
        session.language
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
                                title: ComponentLabels.antiVision(for: language),
                                value: components.antiVision
                            )

                            ComponentSection(
                                title: ComponentLabels.vision(for: language),
                                value: components.vision
                            )

                            ComponentSection(
                                title: ComponentLabels.oneYearGoal(for: language),
                                value: components.oneYearGoal
                            )

                            ComponentSection(
                                title: ComponentLabels.oneMonthProject(for: language),
                                value: components.oneMonthProject
                            )

                            ComponentSection(
                                title: ComponentLabels.dailyLevers(for: language),
                                value: components.dailyLevers.joined(separator: " • ")
                            )

                            ComponentSection(
                                title: ComponentLabels.constraints(for: language),
                                value: components.constraints,
                                showSeparator: false
                            )
                        }
                    } else {
                        Text(ComponentLabels.noData(for: language))
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
