import SwiftUI

/// A ViewModifier that creates a subtle "afterimage" or "burn-in" effect when content
/// transitions out. The effect simulates a brief visual "memory" of the text.
///
/// When `isActive` becomes true:
/// 1. Original content fades to 0 opacity
/// 2. A "ghost" copy appears at 0.15 opacity
/// 3. Ghost scales slightly (1.02x) and fades to 0 over 0.5 seconds
///
/// The effect is intentionally subtle - users should notice it subliminally,
/// reinforcing the psychological weight of the content that just disappeared.
///
/// Usage:
/// ```
/// QuestionView(text: question)
///     .afterimage(isActive: isTransitioningOut)
/// ```
struct Afterimage: ViewModifier {
    let isActive: Bool

    /// Duration for original content to fade out
    private let contentFadeDuration: Double = 0.1

    /// Duration for the ghost to fade out completely
    private let ghostFadeDuration: Double = 0.5

    /// Initial opacity of the ghost after original content fades
    private let ghostInitialOpacity: Double = 0.15

    /// Scale factor for the ghost as it fades
    private let ghostTargetScale: CGFloat = 1.02

    /// Opacity of the original content (animated to 0 when active)
    @State private var contentOpacity: Double = 1.0

    /// Opacity of the ghost overlay
    @State private var ghostOpacity: Double = 0.0

    /// Scale of the ghost overlay
    @State private var ghostScale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .opacity(contentOpacity)
            .overlay {
                // Ghost copy - only visible during the afterimage effect
                content
                    .opacity(ghostOpacity)
                    .scaleEffect(ghostScale)
            }
            .onChange(of: isActive) { oldValue, newValue in
                if newValue && !oldValue {
                    // Transitioning out - start afterimage sequence
                    startAfterimageSequence()
                } else if !newValue && oldValue {
                    // Reset to initial state
                    resetState()
                }
            }
    }

    /// Starts the afterimage animation sequence
    private func startAfterimageSequence() {
        // Step 1: Quickly fade out original content while showing ghost
        withAnimation(.easeOut(duration: contentFadeDuration)) {
            contentOpacity = 0.0
            ghostOpacity = ghostInitialOpacity
        }

        // Step 2: After content fade completes, animate ghost scaling up and fading out
        DispatchQueue.main.asyncAfter(deadline: .now() + contentFadeDuration) {
            withAnimation(.easeOut(duration: ghostFadeDuration)) {
                ghostOpacity = 0.0
                ghostScale = ghostTargetScale
            }
        }
    }

    /// Resets state to initial values (for when effect is deactivated)
    private func resetState() {
        withAnimation(.easeIn(duration: 0.15)) {
            contentOpacity = 1.0
            ghostOpacity = 0.0
            ghostScale = 1.0
        }
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies an afterimage effect that creates a visual "echo" when the content
    /// transitions out.
    ///
    /// When `isActive` becomes true:
    /// - Original content fades to transparent
    /// - A faint "ghost" copy (0.15 opacity) remains briefly
    /// - Ghost scales slightly (1.02x) and fades over 0.5 seconds
    ///
    /// - Parameter isActive: When true, triggers the afterimage transition effect
    /// - Returns: A view with the afterimage effect applied
    func afterimage(isActive: Bool) -> some View {
        modifier(Afterimage(isActive: isActive))
    }
}

// MARK: - Preview

#Preview("Afterimage Effect - Interactive") {
    AfterimagePreview()
}

#Preview("Afterimage Effect - Static Comparison") {
    VStack(spacing: 60) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Normal (no effect)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What is the dull and persistent dissatisfaction you've learned to live with?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Ghost preview (0.15 opacity, 1.02 scale)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What is the dull and persistent dissatisfaction you've learned to live with?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .opacity(0.15)
                .scaleEffect(1.02)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

/// Interactive preview helper for testing the afterimage effect
private struct AfterimagePreview: View {
    @State private var isTransitioningOut = false
    @State private var questionIndex = 0

    private let questions = [
        "What is the dull and persistent dissatisfaction you've learned to live with?",
        "What truth have you been avoiding?",
        "What would you do if you knew you could not fail?"
    ]

    var body: some View {
        VStack(spacing: 40) {
            Text("Tap to trigger afterimage effect")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text(questions[questionIndex])
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.leading)
                .afterimage(isActive: isTransitioningOut)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button(action: triggerTransition) {
                Text(isTransitioningOut ? "Reset" : "Trigger Afterimage")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.dpBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.dpPrimaryText)
                    .cornerRadius(8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBackground)
    }

    private func triggerTransition() {
        if isTransitioningOut {
            // Reset and move to next question
            isTransitioningOut = false
            questionIndex = (questionIndex + 1) % questions.count
        } else {
            // Trigger the afterimage effect
            isTransitioningOut = true
        }
    }
}
