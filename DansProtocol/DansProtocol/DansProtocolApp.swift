import SwiftUI
import SwiftData
import UserNotifications
import UIKit
import CoreText

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

        // DEBUG: Print all available font families and test variable font creation
        #if DEBUG
        debugFontAvailability()
        #endif

        return true
    }

    #if DEBUG
    private func debugFontAvailability() {
        var log = "=== FONT DEBUG START ===\n"

        // 1. List all font families containing "Playfair" or "Noto"
        let families = UIFont.familyNames.sorted()
        let relevantFamilies = families.filter {
            $0.lowercased().contains("playfair") || $0.lowercased().contains("noto")
        }

        log += "Relevant font families found: \(relevantFamilies)\n"

        for family in relevantFamilies {
            let fontNames = UIFont.fontNames(forFamilyName: family)
            log += "  Family '\(family)' has fonts: \(fontNames)\n"
        }

        // 2. Test creating font with family name "Playfair Display"
        let testFamilies = ["Playfair Display", "PlayfairDisplay", "Playfair Display Regular"]
        for familyName in testFamilies {
            let descriptor = UIFontDescriptor(fontAttributes: [.family: familyName])
            let font = UIFont(descriptor: descriptor, size: 28)
            log += "UIFont with family '\(familyName)': fontName=\(font.fontName), familyName=\(font.familyName)\n"
        }

        // 3. Test variable font weight axis
        log += "--- Variable Font Weight Test ---\n"
        let testDescriptor = UIFontDescriptor(fontAttributes: [.family: "Playfair Display"])

        // wght axis tag as FourCC number: 0x77676874 = 2003265652
        let wghtAxisTag: Int = 0x77676874  // 'wght' as FourCC

        // Test different weights with STRING key "wght"
        log += "Testing with STRING key 'wght':\n"
        for weight in [300, 700] as [CGFloat] {
            let variationDescriptor = testDescriptor.addingAttributes([
                UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [
                    "wght": weight
                ]
            ])
            let font = UIFont(descriptor: variationDescriptor, size: 28)
            log += "  Weight \(Int(weight)): font=\(font.fontName)\n"
        }

        // Test different weights with NUMERIC key (FourCC)
        log += "Testing with NUMERIC key \(wghtAxisTag):\n"
        for weight in [300, 700] as [CGFloat] {
            let variationDescriptor = testDescriptor.addingAttributes([
                UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [
                    wghtAxisTag: weight
                ]
            ])
            let font = UIFont(descriptor: variationDescriptor, size: 28)
            let actualVariation = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)]
            log += "  Weight \(Int(weight)): font=\(font.fontName), variation=\(String(describing: actualVariation))\n"
        }

        // Test with kCTFontVariationAxisIdentifierKey approach
        log += "Testing with CTFont approach:\n"
        let psName = testDescriptor.postscriptName
        if let cgFont = CGFont(psName as CFString) {
            let ctFont = CTFontCreateWithGraphicsFont(cgFont, 28, nil, nil)
            if let axes = CTFontCopyVariationAxes(ctFont) as? [[String: Any]] {
                log += "  Available axes: \(axes.map { $0[kCTFontVariationAxisNameKey as String] ?? "?" })\n"
                for axis in axes {
                    let name = axis[kCTFontVariationAxisNameKey as String] as? String ?? "?"
                    let id = axis[kCTFontVariationAxisIdentifierKey as String] as? Int ?? 0
                    let min = axis[kCTFontVariationAxisMinimumValueKey as String] as? CGFloat ?? 0
                    let max = axis[kCTFontVariationAxisMaximumValueKey as String] as? CGFloat ?? 0
                    log += "    Axis '\(name)': id=\(id), range=\(min)-\(max)\n"
                }
            } else {
                log += "  No variation axes found!\n"
            }
        } else {
            log += "  Failed to create CGFont\n"
        }

        log += "=== FONT DEBUG END ===\n"

        // Write to file in Documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logPath = documentsPath.appendingPathComponent("font_debug.txt")
            try? log.write(to: logPath, atomically: true, encoding: .utf8)
            print("Font debug log written to: \(logPath.path)")
        }

        // Also print to console
        print(log)
    }
    #endif

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
