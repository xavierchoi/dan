import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ProtocolSession]
    @State private var viewModel = AppViewModel()

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            switch viewModel.appState {
            case .loading:
                ProgressView()
                    .tint(.dpPrimaryText)

            case .onboarding:
                OnboardingView { session in
                    viewModel.currentSession = session
                    session.status = .part1
                    viewModel.appState = .part1
                    // Schedule notifications
                    NotificationService.shared.scheduleInterrupts(
                        wakeUpTime: session.wakeUpTime,
                        language: session.language
                    )
                    NotificationService.shared.scheduleEveningReminder(
                        wakeUpTime: session.wakeUpTime,
                        language: session.language
                    )
                }

            case .part1:
                if let session = viewModel.currentSession {
                    JournalingView(session: session, part: 1) {
                        session.status = .part2
                        viewModel.appState = .part2Waiting
                    }
                }

            case .part2Waiting:
                if let session = viewModel.currentSession {
                    Part2WaitingView(session: session) {
                        session.status = .part3
                        viewModel.appState = .part3Synthesis
                    }
                }

            case .part3Synthesis:
                if let session = viewModel.currentSession {
                    SynthesisView(session: session) {
                        viewModel.appState = .part3Components
                    }
                }

            case .part3Components:
                if let session = viewModel.currentSession {
                    ComponentsInputView(session: session) {
                        session.status = .completed
                        session.completedAt = Date()
                        viewModel.appState = .completed
                    }
                }

            case .completed:
                if let session = viewModel.currentSession {
                    CompletionView(session: session) {
                        viewModel.appState = .history
                    }
                }

            case .history:
                HistoryView(sessions: sessions) {
                    viewModel.startNewSession()
                }
            }
        }
        .onAppear {
            viewModel.determineState(sessions: sessions)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ProtocolSession.self, JournalEntry.self, LifeGameComponents.self], inMemory: true)
}
