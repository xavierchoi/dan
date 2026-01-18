import SwiftUI

/// A ViewModifier that creates a subtle, persistent micro-tremor effect
/// to evoke subconscious unease - like analog video instability or
/// a slightly shaky camera on an old projector.
///
/// The effect is intentionally subliminal: users should feel slightly
/// unsettled without consciously noticing the tremor. If looked for,
/// it might be perceived, but otherwise it simply contributes to
/// an atmosphere of something being subtly wrong with reality.
///
/// Design Intent (VS-Design-Diverge):
/// - Target Typicality Score: T < 0.2 (non-obvious, low entropy)
/// - Reference: Horror film subtle camera shake, analog CRT instability
/// - The effect must be FELT subconsciously, not consciously noticed
///
/// Usage:
/// ```swift
/// ContentView()
///     .microTremor(intensity: 0.3)
/// ```
struct MicroTremor: ViewModifier {
    /// Intensity of the tremor effect (0.0 to 1.0)
    /// - 0.0: No tremor
    /// - 0.3: Subliminal tremor (barely perceptible)
    /// - 0.5: Noticeable if actively looking
    /// - 1.0: Maximum tremor (use sparingly)
    let intensity: Double

    /// Whether the tremor effect is active
    let isActive: Bool

    /// Reference date for calculating time-based tremor
    @State private var startDate: Date = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(intensity: Double, isActive: Bool = true) {
        self.intensity = intensity
        self.isActive = isActive
    }

    func body(content: Content) -> some View {
        if isActive && intensity > 0 && !reduceMotion {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let tremor = calculateTremor(at: timeline.date)
                content
                    .offset(x: tremor.offsetX, y: tremor.offsetY)
                    .rotationEffect(.degrees(tremor.rotation), anchor: .center)
                    .scaleEffect(tremor.scale)
            }
        } else {
            content
        }
    }

    /// Calculates tremor values based on elapsed time
    /// Uses organic, film-like movement combining smooth noise with random jitter
    private func calculateTremor(at date: Date) -> TremorValues {
        let elapsed = date.timeIntervalSince(startDate)

        // Calculate maximum displacement values based on intensity
        // These are intentionally very small to remain subliminal
        let maxOffset = intensity * 0.6   // Max 0.6pt movement at full intensity
        let maxRotation = intensity * 0.08 // Max 0.08 degree rotation
        let scaleVariation = intensity * 0.002 // Max 0.2% scale variation

        // Use time-based phase values with prime-ish multipliers for organic movement
        let phaseX = elapsed * 2.37  // Different rates to avoid sync
        let phaseY = elapsed * 2.41
        let phaseR = elapsed * 1.89

        // Combine smooth sinusoidal movement with multiple frequencies
        // This creates an analog film projector feel
        let smoothX = sin(phaseX * 2.3) * 0.6 + sin(phaseX * 5.7) * 0.4
        let smoothY = sin(phaseY * 1.9) * 0.6 + sin(phaseY * 4.3) * 0.4
        let smoothR = sin(phaseR * 1.7) * 0.5 + sin(phaseR * 3.1) * 0.5

        // Add subtle random component (30% random, 70% smooth)
        // Using a seeded random based on time for consistent-ish jitter
        let jitterSeed = Int(elapsed * 30) // Changes every ~33ms
        var generator = SeededRandomGenerator(seed: UInt64(abs(jitterSeed)))
        let jitterX = CGFloat.random(in: -1...1, using: &generator)
        let jitterY = CGFloat.random(in: -1...1, using: &generator)
        let jitterR = Double.random(in: -1...1, using: &generator)

        // Final values: blend smooth noise with random jitter
        let offsetX = CGFloat(smoothX * 0.7 + Double(jitterX) * 0.3) * maxOffset
        let offsetY = CGFloat(smoothY * 0.7 + Double(jitterY) * 0.3) * maxOffset
        let rotation = (smoothR * 0.7 + jitterR * 0.3) * maxRotation

        // Subtle scale "breathing" adds to instability without being obvious
        let scale = 1.0 + CGFloat(sin(phaseX * 0.5) * scaleVariation)

        return TremorValues(offsetX: offsetX, offsetY: offsetY, rotation: rotation, scale: scale)
    }
}

/// Container for calculated tremor values
private struct TremorValues {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let rotation: Double
    let scale: CGFloat
}

/// Simple seeded random number generator for consistent jitter
private struct SeededRandomGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Simple LCG (Linear Congruential Generator)
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a persistent micro-tremor effect for psychological unease
    ///
    /// Creates a subliminal sense of instability, like viewing content
    /// through an old projector or unstable camera. The effect should
    /// be felt subconsciously rather than consciously noticed.
    ///
    /// - Parameters:
    ///   - intensity: Tremor strength from 0.0 to 1.0 (default: 0.3)
    ///     - 0.2-0.3: Subliminal, barely perceptible
    ///     - 0.4-0.5: Noticeable if actively looking
    ///     - 0.6+: Obvious tremor (use sparingly)
    ///   - isActive: Whether the effect is enabled (default: true)
    /// - Returns: A view with micro-tremor effect applied
    func microTremor(intensity: Double = 0.3, isActive: Bool = true) -> some View {
        modifier(MicroTremor(intensity: min(1.0, max(0, intensity)), isActive: isActive))
    }
}

// MARK: - Preview

#Preview("Micro Tremor - Intensity Comparison") {
    VStack(spacing: 40) {
        VStack {
            Text("Intensity: 0.2 (Subliminal)")
                .font(.caption)
                .foregroundColor(.gray)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 80)
                .overlay(
                    Text("Barely perceptible")
                        .foregroundColor(.white)
                )
                .microTremor(intensity: 0.2)
        }

        VStack {
            Text("Intensity: 0.5 (Noticeable)")
                .font(.caption)
                .foregroundColor(.gray)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 80)
                .overlay(
                    Text("Look for the shake")
                        .foregroundColor(.white)
                )
                .microTremor(intensity: 0.5)
        }

        VStack {
            Text("No Tremor (Static)")
                .font(.caption)
                .foregroundColor(.gray)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 80)
                .overlay(
                    Text("Comparison baseline")
                        .foregroundColor(.white)
                )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

#Preview("Micro Tremor - Dynamic Intensity") {
    struct DynamicDemo: View {
        @State private var progress: Double = 0.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Progress: \(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Tremor Intensity: \(String(format: "%.2f", 0.2 + progress * 0.3))")
                    .font(.caption)
                    .foregroundColor(.gray)

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 280, height: 150)
                    .overlay(
                        Text("The unease builds...")
                            .foregroundColor(.white)
                    )
                    .microTremor(intensity: 0.2 + progress * 0.3)

                Slider(value: $progress, in: 0...1)
                    .tint(.white)
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
    return DynamicDemo()
}
