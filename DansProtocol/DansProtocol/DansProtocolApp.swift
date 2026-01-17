import SwiftUI
import SwiftData

/// Dan's Protocol - A journaling app based on Dan Koe's "How to Fix Your Entire Life in 1 Day"
///
/// Design Philosophy: Brutalist Typography
/// - Pure black background (#000000)
/// - White text (#FFFFFF)
/// - Minimal UI elements
/// - Focus on typography and content
@main
struct DansProtocolApp: App {
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
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
