import Foundation

// MARK: - Navigation Buttons

enum NavLabels {
    static func back(for language: String) -> String {
        language == "ko" ? "← 뒤로" : "← Back"
    }

    static func continueButton(for language: String) -> String {
        language == "ko" ? "계속 →" : "Continue →"
    }

    static func complete(for language: String) -> String {
        language == "ko" ? "완료 →" : "Complete →"
    }

    static func skip(for language: String) -> String {
        language == "ko" ? "건너뛰기" : "Skip"
    }

    static func save(for language: String) -> String {
        language == "ko" ? "저장 →" : "Save →"
    }

    static func begin(for language: String) -> String {
        language == "ko" ? "시작하기 →" : "Begin →"
    }
}

// MARK: - Onboarding

enum OnboardingLabels {
    static let appTitle = "Dan's Protocol"

    static func tagline(for language: String) -> String {
        language == "ko" ? "하루 만에 인생 전체를 정비하세요." : "Fix your entire life in 1 day."
    }

    static func chooseLanguage(for language: String) -> String {
        language == "ko" ? "언어를 선택하세요" : "Choose your language"
    }

    static func whenIsProtocolDay(for language: String) -> String {
        language == "ko" ? "프로토콜 데이는 언제인가요?" : "When is your Protocol Day?"
    }

    static func whatTimeWakeUp(for language: String) -> String {
        language == "ko" ? "몇 시에 일어나실 건가요?" : "What time will you wake up?"
    }

    static func enableNotifications(for language: String) -> String {
        language == "ko" ? "알림 활성화" : "Enable notifications"
    }

    static func notificationsDisabled(for language: String) -> String {
        language == "ko" ? "알림이 비활성화되었습니다" : "Notifications are disabled"
    }

    static func enableLaterInSettings(for language: String) -> String {
        language == "ko"
            ? "설정에서 나중에 활성화하여 Part 2 인터럽트를 받을 수 있습니다."
            : "You can enable them later in Settings to receive Part 2 interruptions."
    }

    static func notificationExplanation(for language: String) -> String {
        language == "ko"
            ? "Part 2는 하루 종일 무작위 인터럽트가 필요합니다. 예상치 못한 순간에 성찰을 유도하는 알림을 보내드립니다."
            : "Part 2 requires random interruptions throughout the day. We'll send you notifications to prompt reflection at unexpected moments."
    }

    static func enableNotificationsButton(for language: String) -> String {
        language == "ko" ? "알림 활성화" : "Enable Notifications"
    }

    static func continueAnyway(for language: String) -> String {
        language == "ko" ? "그래도 계속 →" : "Continue anyway →"
    }

    static func skipButton(for language: String) -> String {
        language == "ko" ? "건너뛰기 →" : "Skip →"
    }
}

// MARK: - Part 2

enum Part2Labels {
    static func title(for language: String) -> String {
        language == "ko" ? "Part 2: 자동 모드 방해하기" : "Part 2: Interrupting Autopilot"
    }

    static func reflectionsCompleted(for language: String, answered: Int, total: Int) -> String {
        language == "ko"
            ? "\(total)개 중 \(answered)개 성찰 완료"
            : "\(answered) of \(total) reflections completed"
    }

    static func waitingForNotifications(for language: String) -> String {
        language == "ko" ? "알림을 기다리는 중..." : "Waiting for notifications..."
    }

    static func tapNotificationInstruction(for language: String) -> String {
        language == "ko"
            ? "알림을 받으면 탭하여 질문에 대해 성찰하세요."
            : "When you receive a notification, tap it to reflect on the question."
    }

    static func startPart3Recommendation(for language: String) -> String {
        language == "ko"
            ? "미응답 질문이 있어도 Part 3를 시작할 수 있지만, 모든 성찰을 완료하는 것이 권장됩니다."
            : "You can start Part 3 with unanswered questions, but completing all reflections is recommended."
    }

    static func startPart3(for language: String) -> String {
        language == "ko" ? "Part 3 시작 →" : "Start Part 3 →"
    }

    static func additionalReflection(for language: String) -> String {
        language == "ko" ? "추가 성찰 (선택)" : "Additional Reflection (Optional)"
    }
}

// MARK: - History

enum HistoryLabels {
    static func yourJourney(for language: String) -> String {
        language == "ko" ? "당신의 여정" : "Your Journey"
    }

    static func noCompletedSessions(for language: String) -> String {
        language == "ko" ? "완료된 세션이 없습니다" : "No completed sessions yet"
    }

    static func compareWithPrevious(for language: String) -> String {
        language == "ko" ? "이전과 비교하기" : "Compare with previous"
    }

    static func startNewProtocol(for language: String) -> String {
        language == "ko" ? "새 프로토콜 시작" : "Start New Protocol"
    }

    static func thenVsNow(for language: String) -> String {
        language == "ko" ? "과거 vs 현재" : "Then vs Now"
    }
}

// MARK: - Notifications

enum NotificationLabels {
    static func timeToReflect(for language: String) -> String {
        language == "ko" ? "성찰 시간" : "Time to reflect"
    }
}

// MARK: - Life Game Components

enum ComponentLabels {
    static func antiVision(for language: String) -> String {
        language == "ko" ? "안티비전" : "Anti-Vision"
    }

    static func vision(for language: String) -> String {
        language == "ko" ? "비전" : "Vision"
    }

    static func oneYearGoal(for language: String) -> String {
        language == "ko" ? "1년 목표" : "1-Year Goal"
    }

    static func oneMonthProject(for language: String) -> String {
        language == "ko" ? "1개월 프로젝트" : "1-Month Project"
    }

    static func dailyLevers(for language: String) -> String {
        language == "ko" ? "일일 레버" : "Daily Levers"
    }

    static func constraints(for language: String) -> String {
        language == "ko" ? "제약 조건" : "Constraints"
    }

    static func noData(for language: String) -> String {
        language == "ko" ? "데이터 없음" : "No data available"
    }

    static func noComparisonData(for language: String) -> String {
        language == "ko" ? "비교 데이터 없음" : "No comparison data available"
    }

    static func then(for language: String) -> String {
        language == "ko" ? "과거" : "THEN"
    }

    static func now(for language: String) -> String {
        language == "ko" ? "현재" : "NOW"
    }
}
