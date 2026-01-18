import SwiftUI

/// A ViewModifier that applies a subtle noise/dithering texture overlay to create visual tension.
///
/// The dithering effect adds a film-grain aesthetic reminiscent of title sequences,
/// creating subliminal visual texture without overwhelming the content.
///
/// Parameters:
/// - `intensity`: Controls the visibility of the noise (0.0 to 1.0). Even at 1.0, max opacity is ~15%.
/// - `animated`: When true, the pattern shifts subtly over time for a more organic feel.
///
/// Usage:
/// ```
/// Text("Confronting question")
///     .ditheringOverlay(intensity: 0.3)
/// ```
struct DitheringOverlay: ViewModifier {
    let intensity: Double
    let animated: Bool

    /// Seed for static noise pattern (used when animated is false)
    @State private var seed: UInt64 = 0

    /// Maximum opacity for the overlay (keeps effect subtle)
    private let maxOpacity: Double = 0.15

    /// Calculated opacity based on intensity
    private var effectiveOpacity: Double {
        min(max(intensity, 0), 1) * maxOpacity
    }

    init(intensity: Double = 0.3, animated: Bool = false) {
        self.intensity = min(max(intensity, 0.0), 1.0) // Clamp to 0.0-1.0
        self.animated = animated
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                Group {
                    if animated {
                        // Use TimelineView for efficient animation - only runs when view is visible
                        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                            DitheringPattern(seed: UInt64(timeline.date.timeIntervalSince1970 * 10))
                                .opacity(effectiveOpacity)
                                .blendMode(.overlay)
                        }
                    } else {
                        // Static pattern with fixed seed
                        DitheringPattern(seed: seed)
                            .opacity(effectiveOpacity)
                            .blendMode(.overlay)
                    }
                }
                .allowsHitTesting(false)
            }
            .onAppear {
                // Initialize with a random seed for variety (static mode)
                seed = UInt64.random(in: 0..<UInt64.max)
            }
    }
}

// MARK: - DitheringPattern View

/// A view that draws a pixel-based noise pattern using Canvas for efficient rendering.
///
/// The pattern uses a simple hash function to generate deterministic noise based on
/// pixel position and seed value.
struct DitheringPattern: View {
    let seed: UInt64

    /// Pixel density for the noise pattern (lower = larger pixels, better performance)
    private let pixelSize: CGFloat = 2.0

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / pixelSize) + 1
            let rows = Int(size.height / pixelSize) + 1

            for row in 0..<rows {
                for col in 0..<columns {
                    // Generate noise value using hash function
                    let noiseValue = hashNoise(x: col, y: row, seed: seed)

                    // Only draw white pixels for ~50% of positions based on hash
                    guard noiseValue > 0.5 else { continue }

                    let rect = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )

                    // Use white with varying intensity based on noise
                    let pixelOpacity = (noiseValue - 0.5) * 2.0 // Remap 0.5-1.0 to 0.0-1.0
                    context.fill(
                        Path(rect),
                        with: .color(.white.opacity(pixelOpacity))
                    )
                }
            }
        }
    }

    /// Simple hash function for generating deterministic noise
    /// - Parameters:
    ///   - x: Column position
    ///   - y: Row position
    ///   - seed: Seed for variation
    /// - Returns: A value between 0.0 and 1.0
    private func hashNoise(x: Int, y: Int, seed: UInt64) -> Double {
        // Combine coordinates and seed using bit manipulation for pseudo-randomness
        var hash = UInt64(x) &* 374761393
        hash = hash &+ UInt64(y) &* 668265263
        hash = hash ^ seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        hash = hash ^ (hash >> 16)

        // Normalize to 0.0-1.0 range
        return Double(hash % 1000) / 1000.0
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a subtle dithering/noise texture overlay for visual tension.
    ///
    /// The dithering effect adds a film-grain aesthetic that creates subliminal
    /// visual texture without overwhelming the content.
    ///
    /// - Parameters:
    ///   - intensity: Controls the visibility of the noise (0.0 to 1.0, default: 0.3).
    ///                Even at 1.0, max opacity is capped at ~15%.
    ///   - animated: When true, the pattern shifts subtly over time (default: false).
    /// - Returns: A view with the dithering overlay applied
    func ditheringOverlay(intensity: Double = 0.3, animated: Bool = false) -> some View {
        modifier(DitheringOverlay(intensity: intensity, animated: animated))
    }
}

// MARK: - Previews

#Preview("Dithering Overlay - Intensity Comparison") {
    VStack(spacing: 40) {
        // Low intensity
        VStack(spacing: 8) {
            Text("Intensity: 0.2")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What truth have you been avoiding?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .ditheringOverlay(intensity: 0.2)
        }

        // Medium intensity
        VStack(spacing: 8) {
            Text("Intensity: 0.5")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What truth have you been avoiding?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .ditheringOverlay(intensity: 0.5)
        }

        // High intensity
        VStack(spacing: 8) {
            Text("Intensity: 0.8")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What truth have you been avoiding?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .ditheringOverlay(intensity: 0.8)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Dithering Overlay - Animated vs Static") {
    VStack(spacing: 60) {
        // Static
        VStack(spacing: 8) {
            Text("Static (animated: false)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What is the dull and persistent dissatisfaction you've learned to live with?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .ditheringOverlay(intensity: 0.5, animated: false)
        }

        // Animated
        VStack(spacing: 8) {
            Text("Animated (animated: true)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Text("What is the dull and persistent dissatisfaction you've learned to live with?")
                .font(.custom("PlayfairDisplay-Regular", size: 24))
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .ditheringOverlay(intensity: 0.5, animated: true)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Dithering Overlay - On Black Background") {
    ZStack {
        Color.dpBackground

        VStack(spacing: 20) {
            Text("PRESSURE CHAMBER")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.dpPrimaryText)
                .tracking(8)

            Text("Confronting questions that demand honest answers")
                .font(.custom("PlayfairDisplay-Regular", size: 18))
                .foregroundColor(.dpSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .ditheringOverlay(intensity: 0.4, animated: true)
    }
    .ignoresSafeArea()
}
