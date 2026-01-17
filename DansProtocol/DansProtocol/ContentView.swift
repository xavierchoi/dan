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
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Dan's Protocol")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text("Fix Your Entire Life in 1 Day")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [], inMemory: true)
}
