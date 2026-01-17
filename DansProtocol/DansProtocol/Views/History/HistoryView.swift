import SwiftUI

struct HistoryView: View {
    let sessions: [ProtocolSession]
    var onStartNew: () -> Void

    private var completedSessions: [ProtocolSession] {
        sessions
            .filter { $0.status == .completed }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dpBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                        Text("Your Journey")
                            .font(.dpQuestionLarge)
                            .foregroundColor(.dpPrimaryText)
                            .padding(.top, Spacing.questionTopPadding)

                        if completedSessions.isEmpty {
                            Text("No completed sessions yet")
                                .font(.dpBody)
                                .foregroundColor(.dpSecondaryText)
                        } else {
                            VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                                if completedSessions.count >= 2 {
                                    NavigationLink {
                                        SessionComparisonView(
                                            current: completedSessions[0],
                                            previous: completedSessions[1]
                                        )
                                    } label: {
                                        HStack {
                                            Text("Compare with previous")
                                                .font(.dpButton)
                                                .foregroundColor(.dpPrimaryText)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.dpSecondaryText)
                                        }
                                        .padding(.vertical, Spacing.rowPadding)
                                    }

                                    Rectangle()
                                        .fill(Color.dpSeparator)
                                        .frame(height: 1)
                                        .padding(.bottom, Spacing.elementSpacing)
                                }

                                ForEach(completedSessions) { session in
                                    NavigationLink {
                                        SessionDetailView(session: session)
                                    } label: {
                                        SessionRow(session: session)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: Spacing.sectionSpacing)

                        TextButton(title: "Start New Protocol", action: onStartNew)
                    }
                    .padding(Spacing.screenPadding)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SessionRow: View {
    let session: ProtocolSession

    private var dateString: String {
        session.completedAt?.longDateString ?? ""
    }

    private var statusText: String {
        session.language == "ko" ? "완료됨" : "Completed"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(dateString)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            Text(statusText)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
        .padding(.vertical, Spacing.lineSpacing)
    }
}

#Preview {
    HistoryView(sessions: [], onStartNew: {})
}
