import SwiftUI

struct HistoryView: View {
    let sessions: [ProtocolSession]
    var onStartNew: () -> Void

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    Text("History")
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.questionTopPadding)

                    if sessions.isEmpty {
                        Text("No completed sessions yet.")
                            .font(.dpBody)
                            .foregroundColor(.dpSecondaryText)
                    } else {
                        ForEach(sessions.sorted(by: { $0.startDate > $1.startDate })) { session in
                            SessionRow(session: session)
                        }
                    }

                    Spacer(minLength: Spacing.sectionSpacing)

                    TextButton(title: "Start New Protocol", action: onStartNew)
                }
                .padding(Spacing.screenPadding)
            }
        }
    }
}

struct SessionRow: View {
    let session: ProtocolSession

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(dateFormatter.string(from: session.startDate))
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            Text(session.status == .completed ? "Completed" : "In Progress")
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HistoryView(sessions: [], onStartNew: {})
}
