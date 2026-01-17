import Foundation
import SwiftData

@Observable
class AppViewModel {
    var currentSession: ProtocolSession?
    var appState: AppState = .loading
    var showingInterrupt: Bool = false
    var currentInterruptQuestionId: String?
    var pendingNotificationId: String?

    enum AppState {
        case loading
        case onboarding
        case part1
        case part2Waiting
        case part3Synthesis
        case part3Components
        case completed
        case history
    }

    func determineState(sessions: [ProtocolSession]) {
        guard let latest = sessions.sorted(by: { $0.startDate > $1.startDate }).first else {
            appState = .onboarding
            return
        }

        currentSession = latest

        switch latest.status {
        case .notStarted, .part1:
            appState = .part1
        case .part2:
            appState = .part2Waiting
        case .part3:
            appState = .part3Synthesis
        case .completed:
            appState = .history
        }
    }

    func startNewSession() {
        currentSession = nil
        appState = .onboarding
    }

    func handleNotificationTap(questionId: String) {
        pendingNotificationId = questionId
        presentPendingIfPossible()
    }

    func presentPendingIfPossible() {
        guard appState == .part2Waiting, let id = pendingNotificationId else { return }
        currentInterruptQuestionId = id
        showingInterrupt = true
        pendingNotificationId = nil
    }

    func dismissInterrupt() {
        showingInterrupt = false
        currentInterruptQuestionId = nil
    }
}
