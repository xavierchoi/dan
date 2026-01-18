import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleInterrupts(sessionId: UUID, wakeUpTime: Date, language: String) {
        // Clear any existing notifications before scheduling new ones
        cancelAll()

        let questions = QuestionService.shared.questions(for: 2, type: .interrupt)
        let offsets: [Int] = [3, 5, 7, 9, 11, 13] // hours from wake

        for (index, question) in questions.enumerated() {
            guard index < offsets.count else { break }

            let triggerDate = Calendar.current.date(
                byAdding: .hour,
                value: offsets[index],
                to: wakeUpTime
            ) ?? Date()

            scheduleNotification(
                id: question.id,
                sessionId: sessionId,
                title: NotificationLabels.timeToReflect(for: language),
                body: question.text(for: language),
                date: triggerDate
            )
        }
    }

    private func scheduleNotification(id: String, sessionId: UUID, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [
            "questionId": id,
            "sessionId": sessionId.uuidString
        ]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Schedule a snooze reminder for a skipped interrupt question
    /// - Parameters:
    ///   - questionId: The question ID to remind about
    ///   - sessionId: Current session ID
    ///   - language: Language for notification text
    ///   - delayMinutes: Delay before reminder (default: 30 minutes)
    func scheduleSnoozeReminder(
        questionId: String,
        sessionId: UUID,
        language: String,
        delayMinutes: Int = SnoozeStore.snoozeDelayMinutes
    ) {
        guard let question = QuestionService.shared.questions(for: 2, type: .interrupt)
            .first(where: { $0.id == questionId }) else { return }

        let triggerDate = Date().addingTimeInterval(TimeInterval(delayMinutes * 60))

        let content = UNMutableNotificationContent()
        content.title = NotificationLabels.reminderTitle(for: language)
        content.body = question.text(for: language)
        content.sound = .default
        content.userInfo = [
            "questionId": questionId,
            "sessionId": sessionId.uuidString,
            "isSnoozeReminder": true
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Use unique ID for snooze reminders to not conflict with original schedule
        let reminderId = "snooze_\(questionId)_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    /// Cancel snooze reminders for a specific question
    func cancelSnoozeReminders(for questionId: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let snoozeIds = requests
                .filter { $0.identifier.hasPrefix("snooze_\(questionId)_") }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: snoozeIds)
        }
    }

    func scheduleEveningReminder(wakeUpTime: Date, language: String) {
        // 14 hours after wake = evening
        guard let eveningTime = Calendar.current.date(
            byAdding: .hour,
            value: 14,
            to: wakeUpTime
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = language == "ko" ? "Part 3 준비됨" : "Part 3 Ready"
        content.body = language == "ko"
            ? "오늘의 성찰을 종합할 시간입니다. 미응답 질문도 확인해주세요."
            : "Time to synthesize today's reflections. Check any unanswered questions."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: eveningTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "part3_reminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleMissedQuestionsReminder(wakeUpTime: Date, language: String) {
        // 30 minutes before Part 3 (13.5 hours after wake)
        guard let reminderTime = Calendar.current.date(
            byAdding: .minute,
            value: 13 * 60 + 30,
            to: wakeUpTime
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = language == "ko" ? "미응답 질문 확인" : "Unanswered Questions"
        content.body = language == "ko"
            ? "Part 3 시작 전 답하지 않은 인터럽트 질문을 확인하세요."
            : "Review your unanswered interrupt questions before Part 3."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "missed_questions_reminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
