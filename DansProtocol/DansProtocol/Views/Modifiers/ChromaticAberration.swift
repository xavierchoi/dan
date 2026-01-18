import SwiftUI

/// A ViewModifier that creates a subtle RGB split "glitch" effect during transitions.
///
/// The chromatic aberration effect simulates the color fringing seen in old film
/// and CRT displays, creating a brief visual disruption that enhances the
/// psychological tension of transitions.
///
/// When `isActive` becomes true:
/// 1. RGB channels quickly separate (red shifts left, cyan shifts right)
/// 2. Channels immediately converge back together
/// 3. Total effect duration is ~0.1 seconds
///
/// The effect uses subtle tinted overlays rather than full-saturation colors
/// to avoid a cheesy appearance.
///
/// Usage:
/// ```
/// Text("Confronting question")
///     .chromaticAberration(isActive: isTransitioning)
/// ```
struct ChromaticAberration: ViewModifier {
    let isActive: Bool
    let targetOffset: CGFloat

    /// Duration for the split to expand
    private let splitDuration: Double = 0.05

    /// Duration for the split to converge back
    private let convergeDuration: Double = 0.05

    /// Current offset for the chromatic split (animated)
    @State private var currentOffset: CGFloat = 0

    /// Opacity of the color overlays
    @State private var overlayOpacity: Double = 0

    /// Subtle red tint for left channel (desaturated for taste)
    private let redTint = Color(red: 1.0, green: 0.3, blue: 0.3)

    /// Subtle cyan tint for right channel (desaturated for taste)
    private let cyanTint = Color(red: 0.3, green: 1.0, blue: 1.0)

    /// Maximum overlay opacity (kept low for subtlety)
    private let maxOverlayOpacity: Double = 0.4

    init(isActive: Bool, offset: CGFloat = 3) {
        self.isActive = isActive
        self.targetOffset = offset
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                // Red channel - shifts left
                content
                    .colorMultiply(redTint)
                    .offset(x: -currentOffset)
                    .opacity(overlayOpacity)
                    .blendMode(.plusLighter)
            }
            .overlay {
                // Cyan channel - shifts right
                content
                    .colorMultiply(cyanTint)
                    .offset(x: currentOffset)
                    .opacity(overlayOpacity)
                    .blendMode(.plusLighter)
            }
            .onChange(of: isActive) { oldValue, newValue in
                if newValue && !oldValue {
                    // Trigger the glitch effect
                    triggerGlitch()
                }
            }
    }

    /// Triggers the brief chromatic aberration glitch sequence
    private func triggerGlitch() {
        // Phase 1: Quick split outward
        withAnimation(.easeOut(duration: splitDuration)) {
            currentOffset = targetOffset
            overlayOpacity = maxOverlayOpacity
        }

        // Phase 2: Quick converge back
        DispatchQueue.main.asyncAfter(deadline: .now() + splitDuration) {
            withAnimation(.easeIn(duration: convergeDuration)) {
                currentOffset = 0
                overlayOpacity = 0
            }
        }
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a chromatic aberration (RGB split) glitch effect during transitions.
    ///
    /// When `isActive` becomes true, the view briefly splits into red and cyan
    /// color channels that shift apart and then converge back together, creating
    /// a subtle "glitch" effect reminiscent of film title sequences.
    ///
    /// - Parameters:
    ///   - isActive: When true, triggers the glitch effect
    ///   - offset: Maximum pixel distance for the RGB split (default: 3)
    /// - Returns: A view with the chromatic aberration effect applied
    func chromaticAberration(isActive: Bool, offset: CGFloat = 3) -> some View {
        modifier(ChromaticAberration(isActive: isActive, offset: offset))
    }
}

// MARK: - Previews

#Preview("Chromatic Aberration - Interactive") {
    ChromaticAberrationPreview()
}

#Preview("Chromatic Aberration - Offset Comparison") {
    VStack(spacing: 40) {
        VStack(spacing: 8) {
            Text("Offset: 2px (subtle)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("PRESSURE CHAMBER")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
                .tracking(4)
        }

        VStack(spacing: 8) {
            Text("Offset: 4px (moderate)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("PRESSURE CHAMBER")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
                .tracking(4)
        }

        VStack(spacing: 8) {
            Text("Offset: 6px (pronounced)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("PRESSURE CHAMBER")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
                .tracking(4)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Chromatic Aberration - Static Effect Preview") {
    VStack(spacing: 40) {
        VStack(spacing: 8) {
            Text("Normal")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("CONFRONTING")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
        }

        VStack(spacing: 8) {
            Text("With chromatic split (static preview)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            ZStack {
                // Red channel - left
                Text("CONFRONTING")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.dpPrimaryText)
                    .colorMultiply(Color(red: 1.0, green: 0.3, blue: 0.3))
                    .offset(x: -3)
                    .opacity(0.4)
                    .blendMode(.plusLighter)

                // Cyan channel - right
                Text("CONFRONTING")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.dpPrimaryText)
                    .colorMultiply(Color(red: 0.3, green: 1.0, blue: 1.0))
                    .offset(x: 3)
                    .opacity(0.4)
                    .blendMode(.plusLighter)

                // Base content
                Text("CONFRONTING")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.dpPrimaryText)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

// MARK: - Preview Helpers

/// Interactive preview helper for testing the chromatic aberration effect
private struct ChromaticAberrationPreview: View {
    @State private var triggerEffect = false
    @State private var selectedOffset: CGFloat = 3

    var body: some View {
        VStack(spacing: 40) {
            Text("Tap the button to trigger the glitch effect")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Spacer()

            Text("PRESSURE CHAMBER")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
                .tracking(4)
                .chromaticAberration(isActive: triggerEffect, offset: selectedOffset)

            Text("What truth have you been avoiding?")
                .font(.custom("PlayfairDisplay-Regular", size: 22))
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.center)
                .chromaticAberration(isActive: triggerEffect, offset: selectedOffset)

            Spacer()

            // Offset selector
            VStack(spacing: 12) {
                Text("Offset: \(Int(selectedOffset))px")
                    .font(.caption)
                    .foregroundColor(.dpSecondaryText)

                Slider(value: $selectedOffset, in: 1...8, step: 1)
                    .tint(.dpPrimaryText)
                    .padding(.horizontal)
            }

            Button(action: {
                // Toggle to trigger the effect
                triggerEffect = true

                // Reset after effect completes so it can be triggered again
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    triggerEffect = false
                }
            }) {
                Text("Trigger Glitch")
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
