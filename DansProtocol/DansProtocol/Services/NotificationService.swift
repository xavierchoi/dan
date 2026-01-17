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
                title: "Time to reflect",
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

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
