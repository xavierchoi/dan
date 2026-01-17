import Foundation
import SwiftData

@Observable
class OnboardingViewModel {
    var selectedLanguage: String = "en"
    var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var currentStep: OnboardingStep = .welcome

    enum OnboardingStep: Int, CaseIterable {
        case welcome, language, date, wakeTime, notifications, ready
    }

    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else { return }
        currentStep = OnboardingStep.allCases[currentIndex + 1]
    }

    func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        currentStep = OnboardingStep.allCases[currentIndex - 1]
    }

    func createSession(modelContext: ModelContext) -> ProtocolSession {
        let session = ProtocolSession(
            startDate: selectedDate,
            wakeUpTime: wakeUpTime,
            language: selectedLanguage
        )
        modelContext.insert(session)
        return session
    }
}
