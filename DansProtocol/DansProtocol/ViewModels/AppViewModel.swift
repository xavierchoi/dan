import Foundation
import SwiftData

@Observable
class AppViewModel {
    var currentSession: ProtocolSession?
    var appState: AppState = .loading
    var showingInterrupt: Bool = false
    var currentInterruptQuestionId: String?
    private var pendingNotificationIds: [String] = []

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
        refreshPendingNotifications(for: latest)

        switch latest.status {
        case .notStarted, .part1:
            appState = .part1
        case .part2:
            appState = .part2Waiting
        case .part3Synthesis:
            appState = .part3Synthesis
        case .part3Components:
            appState = .part3Components
        case .completed:
            appState = .history
        }

        presentPendingIfPossible()
    }

    func startNewSession() {
        NotificationService.shared.cancelAll()
        PendingInterruptStore.clear()
        SnoozeStore.clear()
        pendingNotificationIds = []
        currentSession = nil
        appState = .onboarding
    }

    func handleNotificationTap(questionId: String, sessionId: UUID?) {
        guard let session = currentSession else { return }
        if let sessionId, sessionId != session.id {
            return
        }
        PendingInterruptStore.add(questionId, sessionId: session.id)
        refreshPendingNotifications(for: session)
        presentPendingIfPossible()
    }

    func presentPendingIfPossible() {
        guard appState == .part2Waiting, !showingInterrupt, let session = currentSession else { return }
        refreshPendingNotifications(for: session)

        let validIds = validPendingIds(for: session)
        if validIds.isEmpty {
            PendingInterruptStore.save([], for: session.id)
            pendingNotificationIds = []
            return
        }

        currentInterruptQuestionId = validIds[0]
        showingInterrupt = true
    }

    func dismissInterrupt() {
        showingInterrupt = false
        currentInterruptQuestionId = nil
        DispatchQueue.main.async { [weak self] in
            self?.presentPendingIfPossible()
        }
    }

    /// Handle skip with snooze logic: schedule reminder if under max snooze count
    func skipInterrupt(questionId: String) {
        guard let session = currentSession else {
            dismissInterrupt()
            return
        }

        // Increment snooze count
        let newCount = SnoozeStore.incrementSnooze(for: questionId, sessionId: session.id)

        // If under max snooze, schedule a 30-minute reminder
        if newCount < SnoozeStore.maxSnoozeCount {
            NotificationService.shared.scheduleSnoozeReminder(
                questionId: questionId,
                sessionId: session.id,
                language: session.language
            )
        }
        // If max snooze reached, no notification - user must answer in-app

        // Remove from pending and dismiss
        PendingInterruptStore.remove(questionId, sessionId: session.id)
        dismissInterrupt()
    }

    func handleInterruptAnswered(questionId: String, sessionId: UUID) {
        guard let session = currentSession, session.id == sessionId else { return }
        PendingInterruptStore.remove(questionId, sessionId: sessionId)
        refreshPendingNotifications(for: session)
        presentPendingIfPossible()
    }

    private func refreshPendingNotifications(for session: ProtocolSession) {
        pendingNotificationIds = PendingInterruptStore.load(for: session.id)
        let prunedIds = validPendingIds(for: session)
        if prunedIds != pendingNotificationIds {
            pendingNotificationIds = prunedIds
            PendingInterruptStore.save(prunedIds, for: session.id)
        }
    }

    private func validPendingIds(for session: ProtocolSession) -> [String] {
        let validIds = Set(
            QuestionService.shared.questions(for: 2, type: .interrupt).map(\.id)
        )
        let answeredIds = Set(
            session.entries
                .filter { !$0.response.isEmpty }
                .map(\.questionKey)
        )
        if !validIds.isEmpty, validIds.subtracting(answeredIds).isEmpty {
            return []
        }
        return pendingNotificationIds.filter { validIds.contains($0) && !answeredIds.contains($0) }
    }
}
