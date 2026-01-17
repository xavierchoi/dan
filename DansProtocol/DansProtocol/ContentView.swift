import SwiftUI
import SwiftData

/// Main content view following Brutalist Typography design
/// - Pure black background
/// - White text
/// - Minimal UI
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            // Brutalist black background
            Color.dpBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.screenPadding) {
                Text("Dan's Protocol")
                    .font(.dpQuestionLarge)
                    .foregroundStyle(Color.dpPrimaryText)

                Text("Fix Your Entire Life in 1 Day")
                    .font(.dpBody)
                    .foregroundStyle(Color.dpSecondaryText)
            }
            .padding(.horizontal, Spacing.screenPadding)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [], inMemory: true)
}
