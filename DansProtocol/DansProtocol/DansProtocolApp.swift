import SwiftUI
import SwiftData
import UserNotifications
import UIKit

/// Dan's Protocol - A journaling app based on Dan Koe's "How to Fix Your Entire Life in 1 Day"
///
/// Design Philosophy: Brutalist Typography
/// - Pure black background (#000000)
/// - White text (#FFFFFF)
/// - Minimal UI elements
/// - Focus on typography and content
@main
struct DansProtocolApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProtocolSession.self,
            JournalEntry.self,
            LifeGameComponents.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // 스토어 손상 시 기존 데이터 삭제 후 재생성 시도
            print("⚠️ ModelContainer creation failed: \(error)")
            print("⚠️ Attempting recovery by removing corrupted store...")

            // 기존 스토어 파일 삭제
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            // WAL, SHM 파일도 삭제
            let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                // 최후의 수단: 인메모리 컨테이너로 부팅
                print("⚠️ Recovery failed. Using in-memory container.")
                let inMemoryConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                do {
                    return try ModelContainer(for: schema, configurations: [inMemoryConfig])
                } catch {
                    fatalError("Could not create even in-memory ModelContainer: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle notification tap when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let questionId = userInfo["questionId"] as? String {
            let sessionIdString = userInfo["sessionId"] as? String
            if let sessionIdString,
               let sessionId = UUID(uuidString: sessionIdString) {
                PendingInterruptStore.add(questionId, sessionId: sessionId)
            } else {
                PendingInterruptStore.addLegacy(questionId)
            }
            var payload: [AnyHashable: Any] = ["questionId": questionId]
            if let sessionIdString {
                payload["sessionId"] = sessionIdString
            }
            NotificationCenter.default.post(
                name: .didTapNotification,
                object: nil,
                userInfo: payload
            )
        }
        completionHandler()
    }
}
