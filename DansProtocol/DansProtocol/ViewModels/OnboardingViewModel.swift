import Foundation
import SwiftData
import UserNotifications

@Observable
class OnboardingViewModel {
    static let userLanguageKey = "userLanguage"

    var selectedLanguage: String {
        didSet {
            userDefaults.set(selectedLanguage, forKey: Self.userLanguageKey)
        }
    }
    var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var currentStep: OnboardingStep = .welcome

    /// Tracks whether a language was already stored when the ViewModel was initialized
    private let hadStoredLanguage: Bool
    private let userDefaults: UserDefaults
    private let notificationPermissionChecker: (@escaping (UNAuthorizationStatus) -> Void) -> Void

    enum OnboardingStep: Int, CaseIterable {
        case welcome, language, date, wakeTime, notifications, ready
    }

    convenience init() {
        self.init(
            userDefaults: .standard,
            notificationPermissionChecker: { completion in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    completion(settings.authorizationStatus)
                }
            }
        )
    }

    init(
        userDefaults: UserDefaults,
        notificationPermissionChecker: @escaping (@escaping (UNAuthorizationStatus) -> Void) -> Void
    ) {
        self.userDefaults = userDefaults
        self.notificationPermissionChecker = notificationPermissionChecker

        if let storedLanguage = userDefaults.string(forKey: Self.userLanguageKey) {
            self.selectedLanguage = storedLanguage
            self.hadStoredLanguage = true
        } else {
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            self.selectedLanguage = preferredLanguage.hasPrefix("ko") ? "ko" : "en"
            self.hadStoredLanguage = false
        }
    }

    func nextStep() {
        switch currentStep {
        case .welcome:
            // Skip language step if user already has a stored language preference
            currentStep = hadStoredLanguage ? .date : .language
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
        case .date:
            // Go back to language only if we didn't skip it
            currentStep = hadStoredLanguage ? .welcome : .language
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
