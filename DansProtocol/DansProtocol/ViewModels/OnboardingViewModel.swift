import Foundation
import SwiftData
import UserNotifications

@Observable
class OnboardingViewModel {
    /// Language is now determined by iOS per-app language settings (Settings > Apps > Dan's Protocol > Language)
    var selectedLanguage: String {
        LanguageHelper.currentLanguage
    }
    var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var currentStep: OnboardingStep = .welcome

    private let notificationPermissionChecker: (@escaping (UNAuthorizationStatus) -> Void) -> Void

    enum OnboardingStep: Int, CaseIterable {
        case welcome, date, wakeTime, notifications, ready
    }

    convenience init() {
        self.init(
            notificationPermissionChecker: { completion in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    completion(settings.authorizationStatus)
                }
            }
        )
    }

    init(
        notificationPermissionChecker: @escaping (@escaping (UNAuthorizationStatus) -> Void) -> Void
    ) {
        self.notificationPermissionChecker = notificationPermissionChecker
    }

    func nextStep() {
        switch currentStep {
        case .wakeTime:
            // Check notification permission and skip if already determined
            checkNotificationPermissionAndAdvance()
        default:
            advanceToNextStep()
        }
    }

    private func advanceToNextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else { return }
        currentStep = OnboardingStep.allCases[currentIndex + 1]
    }

    private func checkNotificationPermissionAndAdvance() {
        notificationPermissionChecker { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .authorized, .denied, .provisional, .ephemeral:
                    // Permission already determined, skip to ready
                    self.currentStep = .ready
                case .notDetermined:
                    // Need to ask for permission
                    self.currentStep = .notifications
                @unknown default:
                    self.currentStep = .notifications
                }
            }
        }
    }

    func previousStep() {
        switch currentStep {
        case .ready:
            // Go back to wakeTime (skip notifications since we may have skipped it going forward)
            currentStep = .wakeTime
        default:
            guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
                  currentIndex > 0 else { return }
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }

    func createSession(modelContext: ModelContext) -> ProtocolSession {
        let time = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
        let combinedWakeTime = Calendar.current.date(
            bySettingHour: time.hour ?? 7,
            minute: time.minute ?? 0,
            second: 0,
            of: selectedDate
        ) ?? selectedDate

        let session = ProtocolSession(
            startDate: selectedDate,
            wakeUpTime: combinedWakeTime,
            language: selectedLanguage
        )
        modelContext.insert(session)
        return session
    }
}
