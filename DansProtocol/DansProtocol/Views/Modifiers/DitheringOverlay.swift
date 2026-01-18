import SwiftUI

/// A ViewModifier that applies a noise/dithering texture overlay to create visual tension.
///
/// The dithering effect adds a film-grain aesthetic reminiscent of Se7en title sequences
/// and old CRT monitors, creating palpable visual texture throughout the experience.
///
/// **Performance Optimized**: Uses a pre-generated noise texture that tiles across the view,
/// reducing O(n²) per-frame computation to a single static image render.
///
/// Parameters:
/// - `intensity`: Controls the visibility of the noise (0.0 to 1.0). At 1.0, max opacity is 40%.
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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Pre-generated noise texture - created once at app launch for optimal performance.
    /// 128x128 pixels tiles seamlessly across any view size.
    private static let noiseImage: UIImage = generateNoiseTexture()

    /// Animation offset for subtle movement effect
    @State private var animationOffset: CGFloat = 0

    /// Random offset for static pattern variety between instances
    @State private var staticOffset: CGPoint = .zero

    /// Maximum opacity for the overlay - 0.4 creates visible film grain texture
    private let maxOpacity: Double = 0.4

    /// Texture size for animation cycle
    private static let textureSize: CGFloat = 128

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
                if intensity > 0.01 {
                    Image(uiImage: Self.noiseImage)
                        .resizable(resizingMode: .tile)
                        .opacity(effectiveOpacity)
                        .blendMode(.overlay)
                        .offset(
                            x: animated && !reduceMotion ? animationOffset : staticOffset.x,
                            y: animated && !reduceMotion ? 0 : staticOffset.y
                        )
                        .allowsHitTesting(false)
                }
            }
            .onAppear {
                // Initialize random offset for static pattern variety
                staticOffset = CGPoint(
                    x: CGFloat.random(in: 0..<Self.textureSize),
                    y: CGFloat.random(in: 0..<Self.textureSize)
                )

                // Start animation if enabled
                if animated && !reduceMotion {
                    startAnimation()
                }
            }
            .onChange(of: animated) { _, newValue in
                if newValue && !reduceMotion {
                    startAnimation()
                }
            }
    }

    /// Starts the continuous offset animation for organic movement
    private func startAnimation() {
        // Reset offset to ensure smooth start
        animationOffset = 0

        // Animate offset across one full texture cycle, then repeat
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            animationOffset = Self.textureSize
        }
    }

    /// Generates a tileable noise texture at app launch.
    ///
    /// Performance: This runs once and creates a 128x128 pixel noise pattern.
    /// The texture is then reused across all DitheringOverlay instances.
    ///
    /// - Returns: A UIImage containing the noise pattern
    private static func generateNoiseTexture() -> UIImage {
        let size = CGSize(width: textureSize, height: textureSize)
        let pixelSize: CGFloat = 2.0

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Fill background with transparent
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Generate noise pixels using deterministic hash for consistency
            let columns = Int(size.width / pixelSize)
            let rows = Int(size.height / pixelSize)

            for row in 0..<rows {
                for col in 0..<columns {
                    // Generate noise value using hash function
                    let noiseValue = hashNoise(x: col, y: row, seed: 42)

                    // Only draw white pixels for ~50% of positions based on hash
                    guard noiseValue > 0.5 else { continue }

                    let rect = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )

                    // Use white with varying intensity based on noise (remap 0.5-1.0 to 0.0-1.0)
                    let pixelOpacity = (noiseValue - 0.5) * 2.0
                    UIColor(white: 1.0, alpha: pixelOpacity).setFill()
                    context.fill(rect)
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
    private static func hashNoise(x: Int, y: Int, seed: UInt64) -> Double {
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
    /// Applies a dithering/noise texture overlay for visual tension.
    ///
    /// The dithering effect adds a film-grain aesthetic reminiscent of Se7en
    /// and old CRT monitors, creating palpable visual texture.
    ///
    /// - Parameters:
    ///   - intensity: Controls the visibility of the noise (0.0 to 1.0, default: 0.3).
    ///                At 1.0, max opacity is 40% for clearly visible grain.
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
                .font(.custom("Playfair Display", size: 24))
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
                .font(.custom("Playfair Display", size: 24))
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
                .font(.custom("Playfair Display", size: 24))
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
                .font(.custom("Playfair Display", size: 24))
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
                .font(.custom("Playfair Display", size: 24))
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
                .font(.custom("Playfair Display", size: 18))
                .foregroundColor(.dpSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .ditheringOverlay(intensity: 0.4, animated: true)
    }
    .ignoresSafeArea()
}
