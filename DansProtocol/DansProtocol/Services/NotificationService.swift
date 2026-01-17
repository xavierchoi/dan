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

    func scheduleInterrupts(wakeUpTime: Date, language: String) {
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
                title: NotificationLabels.timeToReflect(for: language),
                body: question.text(for: language),
                date: triggerDate
            )
        }
    }

    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
