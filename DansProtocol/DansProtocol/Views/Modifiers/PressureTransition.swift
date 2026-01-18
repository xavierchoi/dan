import SwiftUI

/// A ViewModifier that creates a "pressure pulse" effect during transitions.
/// The view compresses slightly then springs back, like breathing under pressure.
///
/// When `isActive` becomes true:
/// 1. First 40% of duration: Compress to `compressionScale` (easeIn)
/// 2. Remaining 60%: Spring back to 1.0 (spring animation)
///
/// The effect creates a sense of "pressure" during state changes,
/// reinforcing the psychological weight of transitions.
///
/// Usage:
/// ```
/// CardView()
///     .pressureTransition(isActive: isChanging)
/// ```
struct PressureTransition: ViewModifier {
    let isActive: Bool
    let compressionScale: CGFloat
    let duration: Double

    /// Current scale of the view (animated)
    @State private var scale: CGFloat = 1.0

    /// Tracks whether we're in the middle of an animation sequence
    @State private var isAnimating: Bool = false

    init(isActive: Bool, compressionScale: CGFloat = 0.98, duration: Double = 0.3) {
        self.isActive = isActive
        self.compressionScale = compressionScale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { oldValue, newValue in
                if newValue && !oldValue {
                    // Trigger pressure pulse
                    startPressurePulse()
                }
            }
    }

    // MARK: - Animation Sequence

    /// Starts the pressure pulse animation sequence
    private func startPressurePulse() {
        guard !isAnimating else { return }
        isAnimating = true

        // Calculate phase durations
        let compressionDuration = duration * 0.4
        let releaseDuration = duration * 0.6

        // Phase 1: Compress with easeIn
        withAnimation(.easeIn(duration: compressionDuration)) {
            scale = compressionScale
        }

        // Phase 2: Spring back to normal after compression completes
        DispatchQueue.main.asyncAfter(deadline: .now() + compressionDuration) {
            withAnimation(.spring(
                response: releaseDuration,
                dampingFraction: 0.6,
                blendDuration: 0
            )) {
                scale = 1.0
            }

            // Reset animation flag after spring completes
            DispatchQueue.main.asyncAfter(deadline: .now() + releaseDuration) {
                isAnimating = false
            }
        }
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a pressure pulse effect that compresses and releases the view.
    ///
    /// When `isActive` becomes true:
    /// - View compresses to the specified scale (40% of duration)
    /// - Springs back to normal size (60% of duration)
    ///
    /// Creates a "breathing under pressure" feel for transitions.
    ///
    /// - Parameters:
    ///   - isActive: When true, triggers the pressure pulse effect
    ///   - compression: How much to compress (default: 0.98, meaning 2% smaller)
    ///   - duration: Total animation duration in seconds (default: 0.3)
    /// - Returns: A view with the pressure transition effect applied
    func pressureTransition(
        isActive: Bool,
        compression: CGFloat = 0.98,
        duration: Double = 0.3
    ) -> some View {
        modifier(PressureTransition(
            isActive: isActive,
            compressionScale: compression,
            duration: duration
        ))
    }
}

// MARK: - Preview

#Preview("Pressure Transition - Interactive") {
    PressureTransitionPreview()
}

#Preview("Pressure Transition - Card Example") {
    PressureTransitionCardPreview()
}

/// Interactive preview helper for testing the pressure transition effect
private struct PressureTransitionPreview: View {
    @State private var triggerPulse = false

    var body: some View {
        VStack(spacing: 40) {
            Text("Tap the button to trigger pressure pulse")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Spacer()

            Text("What truth have you been avoiding?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.center)
                .padding(32)
                .pressureTransition(isActive: triggerPulse)

            Spacer()

            Button(action: {
                triggerPulse = true
                // Reset after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    triggerPulse = false
                }
            }) {
                Text("Trigger Pressure")
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
}

/// Card-based preview showing the pressure effect on a card element
private struct PressureTransitionCardPreview: View {
    @State private var triggerPulse = false
    @State private var pulseCount = 0

    var body: some View {
        VStack(spacing: 40) {
            Text("Pressure Transition on Card")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Spacer()

            // Card element
            VStack(spacing: 16) {
                Text("Question \(pulseCount + 1)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.dpSecondaryText)

                Text("The card compresses slightly, then springs back—like taking a breath under pressure.")
                    .font(.custom("PlayfairDisplay-Regular", size: 20))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dpBackground)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.dpSecondaryText.opacity(0.2), lineWidth: 1)
            )
            .pressureTransition(isActive: triggerPulse, compression: 0.96, duration: 0.4)
            .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    triggerPulse = true
                    pulseCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerPulse = false
                    }
                }) {
                    Text("Subtle (0.98)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.dpPrimaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.dpPrimaryText, lineWidth: 1)
                        )
                }

                Button(action: {
                    triggerPulse = true
                    pulseCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerPulse = false
                    }
                }) {
                    Text("Trigger Pulse")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.dpBackground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.dpPrimaryText)
                        .cornerRadius(8)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBackground.opacity(0.95))
    }
}
