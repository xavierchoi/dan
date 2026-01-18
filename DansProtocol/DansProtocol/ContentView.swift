import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - FetchDescriptor for Query Optimization
    /// Fetch only recent 10 sessions sorted by startDate descending
    /// This reduces memory footprint and improves initial load time
    static var recentSessionsDescriptor: FetchDescriptor<ProtocolSession> {
        var descriptor = FetchDescriptor<ProtocolSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        return descriptor
    }

    @Environment(\.modelContext) private var modelContext
    @Query(ContentView.recentSessionsDescriptor) private var sessions: [ProtocolSession]
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = AppViewModel()
    @State private var showingHistorySheet = false

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            // Check for critical Questions.json load failure
            if let error = QuestionService.shared.loadError {
                questionsLoadErrorView(error: error)
            } else {
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
                        sessionId: session.id,
                        wakeUpTime: session.wakeUpTime,
                        language: session.language
                    )
                    NotificationService.shared.scheduleEveningReminder(
                        wakeUpTime: session.wakeUpTime,
                        language: session.language
                    )
                    NotificationService.shared.scheduleMissedQuestionsReminder(
                        wakeUpTime: session.wakeUpTime,
                        language: session.language
                    )
                }

            case .part1:
                if let session = viewModel.currentSession {
                    JournalingView(session: session, part: 1) {
                        session.status = .part2
                        viewModel.appState = .part2Waiting
                        viewModel.presentPendingIfPossible()
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
                } // end switch
            } // end else

            // History button overlay (only in part2Waiting or completed states)
            if viewModel.appState == .part2Waiting || viewModel.appState == .completed {
                Button {
                    showingHistorySheet = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.dpSecondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                try? modelContext.save()
            }
        }
        .onAppear {
            viewModel.determineState(sessions: sessions)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showingInterrupt) {
            if let session = viewModel.currentSession,
               let questionId = viewModel.currentInterruptQuestionId {
                InterruptView(
                    session: session,
                    questionId: questionId,
                    onDismiss: {
                        viewModel.dismissInterrupt()
                    },
                    onSkip: { skippedQuestionId in
                        viewModel.skipInterrupt(questionId: skippedQuestionId)
                    }
                )
            }
        }
        .sheet(isPresented: $showingHistorySheet) {
            HistoryView(sessions: sessions, onStartNew: {}, isModal: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didTapNotification)) { notification in
            if let questionId = notification.userInfo?["questionId"] as? String {
                let sessionIdString = notification.userInfo?["sessionId"] as? String
                let sessionId = sessionIdString.flatMap(UUID.init(uuidString:))
                viewModel.handleNotificationTap(questionId: questionId, sessionId: sessionId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didAnswerInterrupt)) { notification in
            guard let questionId = notification.userInfo?["questionId"] as? String,
                  let sessionIdString = notification.userInfo?["sessionId"] as? String,
                  let sessionId = UUID(uuidString: sessionIdString) else { return }
            viewModel.handleInterruptAnswered(questionId: questionId, sessionId: sessionId)
        }
    }
}

// MARK: - Error View

extension ContentView {
    /// Error view displayed when Questions.json fails to load
    @ViewBuilder
    func questionsLoadErrorView(error: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Critical Error")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.dpPrimaryText)

            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.dpSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("Please reinstall the app or contact support.")
                .font(.system(size: 12))
                .foregroundColor(.dpSecondaryText.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension Notification.Name {
    static let didTapNotification = Notification.Name("didTapNotification")
    static let didAnswerInterrupt = Notification.Name("didAnswerInterrupt")
}

#Preview {
    ContentView()
        .modelContainer(for: [ProtocolSession.self, JournalEntry.self, LifeGameComponents.self], inMemory: true)
}
