import SwiftUI

/// A cinematic progress indicator that creates psychological pressure through light and shadow.
///
/// This component creates a visible, atmospheric glow at screen edges that intensifies
/// as progress increases. The effect is designed to feel like "walls closing in" -
/// creating subtle but perceptible pressure that users experience viscerally.
///
/// Three position modes are available:
/// - **Top/Leading**: Single edge glow (original behavior)
/// - **Frame**: All 4 edges glow simultaneously with corner vignettes - maximum pressure effect
///
/// Two visualization modes are available:
/// - **Opacity mode**: Full-width glow that brightens as progress increases (more subliminal)
/// - **Length mode**: Glow line that extends as progress increases (more perceptible)
///
/// Usage:
/// ```swift
/// // Subtle brightness-based progress at top edge
/// EdgeGlow(progress: 0.5, position: .top, mode: .opacity)
///
/// // Length-based progress at leading edge
/// EdgeGlow(progress: 0.7, position: .leading, mode: .length)
///
/// // Frame mode with pulsing for Pressure Chamber effect
/// EdgeGlow(progress: 0.9, position: .frame, pulsing: true)
/// ```
struct EdgeGlow: View {

    // MARK: - Types

    /// The edge where the glow appears
    enum Position {
        case top
        case bottom
        case leading
        case trailing
        /// All 4 edges simultaneously - creates a "walls closing in" effect
        case frame

        var isHorizontal: Bool {
            self == .top || self == .bottom
        }

        /// Returns all individual edge positions for frame mode
        static var frameEdges: [Position] {
            [.top, .bottom, .leading, .trailing]
        }
    }

    /// How progress is visualized
    enum Mode {
        /// Glow spans full width/height, opacity increases with progress (more subliminal)
        case opacity
        /// Glow extends along the edge as progress increases (more visible)
        case length
        /// Combines both: glow extends AND brightens (balanced approach)
        case combined
    }

    // MARK: - Constants

    /// Minimum opacity at 0% progress
    private static let minOpacity: Double = 0.1
    /// Maximum opacity at 100% progress
    private static let maxOpacity: Double = 0.5
    /// The glow line thickness in points
    private static let lineThickness: CGFloat = 1
    /// Blur radius for the glow effect - increased for cinematic atmosphere
    private static let blurRadius: CGFloat = 6

    // Frame mode specific constants
    /// Minimum opacity for frame mode at 0% progress (clearly visible from start)
    private static let frameMinOpacity: Double = 0.25
    /// Maximum opacity for frame mode at 100% progress (dramatic climax)
    private static let frameMaxOpacity: Double = 0.7
    /// Threshold at which INTENSE pulsing begins (subtle pulse always active)
    private static let pulseThreshold: Double = 0.8
    /// Base pulse frequency (cycles per second) - constant breathing at all times
    private static let basePulseFrequency: Double = 0.5
    /// Maximum pulse frequency at 100% progress
    private static let maxPulseFrequency: Double = 2.0
    /// Pulse amplitude (opacity variation) - increases with progress
    private static let pulseAmplitude: Double = 0.15
    /// Minimum pulse amplitude at 0% progress (subtle breathing)
    private static let minPulseAmplitude: Double = 0.03
    /// Corner vignette opacity multiplier
    private static let vignetteIntensity: Double = 0.4

    // MARK: - Properties

    /// Progress value from 0.0 to 1.0
    let progress: Double
    /// Which edge the glow appears on
    let position: Position
    /// How the progress is visualized
    let mode: Mode
    /// Whether to enable pulse animation (subtle breathing at all times, intensifies above 80%)
    let pulsing: Bool

    // MARK: - State

    /// Current pulse phase for animation
    @State private var pulsePhase: Double = 0

    // MARK: - Computed Properties

    /// Calculate opacity based on progress and mode
    private var glowOpacity: Double {
        baseOpacity + pulseOffset
    }

    /// Base opacity without pulse animation
    private var baseOpacity: Double {
        switch mode {
        case .opacity, .combined:
            // Linear interpolation: 0.1 at 0%, 0.5 at 100%
            return Self.minOpacity + (clampedProgress * (Self.maxOpacity - Self.minOpacity))
        case .length:
            // Constant opacity in length mode for consistent visibility
            return 0.35
        }
    }

    /// Opacity for frame mode (separate calculation)
    private var frameOpacity: Double {
        let base = Self.frameMinOpacity + (clampedProgress * (Self.frameMaxOpacity - Self.frameMinOpacity))
        return base + pulseOffset
    }

    /// Pulse animation offset - always active with subtle breathing, intensifies with progress
    private var pulseOffset: Double {
        guard pulsing else { return 0 }

        // Calculate pulse intensity: subtle at low progress, dramatic at high progress
        let intensity: Double
        if clampedProgress > Self.pulseThreshold {
            // Above threshold: dramatic pulsing
            let pulseProgress = (clampedProgress - Self.pulseThreshold) / (1.0 - Self.pulseThreshold)
            intensity = Self.minPulseAmplitude + (pulseProgress * (Self.pulseAmplitude - Self.minPulseAmplitude))
        } else {
            // Below threshold: subtle constant breathing
            // Amplitude grows linearly from minPulseAmplitude at 0% to minPulseAmplitude*2 at threshold
            let preThresholdGrowth = clampedProgress / Self.pulseThreshold
            intensity = Self.minPulseAmplitude * (1.0 + preThresholdGrowth)
        }

        // Use sine wave for smooth pulsing
        return sin(pulsePhase) * intensity
    }

    /// Current pulse frequency based on progress - always base frequency, accelerates above threshold
    private var pulseFrequency: Double {
        guard pulsing else { return 0 }

        if clampedProgress > Self.pulseThreshold {
            // Above threshold: accelerating frequency
            let pulseProgress = (clampedProgress - Self.pulseThreshold) / (1.0 - Self.pulseThreshold)
            return Self.basePulseFrequency + (pulseProgress * (Self.maxPulseFrequency - Self.basePulseFrequency))
        } else {
            // Below threshold: constant slow breathing (0.5 Hz)
            return Self.basePulseFrequency
        }
    }

    /// Progress clamped to valid range
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    /// The fraction of the edge that should glow
    private var lengthFraction: Double {
        switch mode {
        case .length, .combined:
            return clampedProgress
        case .opacity:
            return 1.0
        }
    }

    // MARK: - Initialization

    /// Creates an edge glow progress indicator.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - position: Which edge to display the glow (default: .top)
    ///   - mode: How progress is visualized (default: .opacity for maximum subtlety)
    ///   - pulsing: Whether to enable pulse animation when progress > 0.8 (default: false)
    init(progress: Double, position: Position = .top, mode: Mode = .opacity, pulsing: Bool = false) {
        self.progress = progress
        self.position = position
        self.mode = mode
        self.pulsing = pulsing
    }

    // MARK: - Body

    var body: some View {
        Group {
            if position == .frame {
                frameView
            } else {
                singleEdgeView
            }
        }
        .onAppear {
            startPulseAnimationIfNeeded()
        }
        .onChange(of: pulsing) { _, newValue in
            if newValue {
                startPulseAnimationIfNeeded()
            }
        }
        .onChange(of: progress) { _, _ in
            startPulseAnimationIfNeeded()
        }
    }

    /// Single edge glow (original behavior)
    private var singleEdgeView: some View {
        GeometryReader { geometry in
            glowLine(in: geometry, for: position)
        }
        .frame(
            width: position.isHorizontal ? nil : Self.lineThickness + Self.blurRadius * 2,
            height: position.isHorizontal ? Self.lineThickness + Self.blurRadius * 2 : nil
        )
    }

    /// Frame mode: all 4 edges rendered simultaneously
    private var frameView: some View {
        GeometryReader { geometry in
            ZStack {
                // Corner vignettes - "walls closing in" darkening effect
                cornerVignettes(in: geometry)

                // Top edge
                topEdgeGlow(in: geometry)
                // Bottom edge
                bottomEdgeGlow(in: geometry)
                // Leading edge
                leadingEdgeGlow(in: geometry)
                // Trailing edge
                trailingEdgeGlow(in: geometry)
            }
        }
    }

    // MARK: - Corner Vignette Effect

    /// Creates subtle corner darkening that intensifies with progress
    private func cornerVignettes(in geometry: GeometryProxy) -> some View {
        let vignetteOpacity = Self.vignetteIntensity * clampedProgress
        let cornerSize = min(geometry.size.width, geometry.size.height) * 0.35

        return ZStack {
            // Top-leading corner
            RadialGradient(
                colors: [Color.black.opacity(vignetteOpacity), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: cornerSize
            )

            // Top-trailing corner
            RadialGradient(
                colors: [Color.black.opacity(vignetteOpacity), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: cornerSize
            )

            // Bottom-leading corner
            RadialGradient(
                colors: [Color.black.opacity(vignetteOpacity), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: cornerSize
            )

            // Bottom-trailing corner
            RadialGradient(
                colors: [Color.black.opacity(vignetteOpacity), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: cornerSize
            )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Frame Edge Views

    private func topEdgeGlow(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.white, .white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: geometry.size.width, height: Self.lineThickness)
            .blur(radius: Self.blurRadius)
            .opacity(frameOpacity)
            .position(x: geometry.size.width / 2, y: Self.blurRadius)
    }

    private func bottomEdgeGlow(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.white, .white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: geometry.size.width, height: Self.lineThickness)
            .blur(radius: Self.blurRadius)
            .opacity(frameOpacity)
            .position(x: geometry.size.width / 2, y: geometry.size.height - Self.blurRadius)
    }

    private func leadingEdgeGlow(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.white, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: Self.lineThickness, height: geometry.size.height)
            .blur(radius: Self.blurRadius)
            .opacity(frameOpacity)
            .position(x: Self.blurRadius, y: geometry.size.height / 2)
    }

    private func trailingEdgeGlow(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.white, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: Self.lineThickness, height: geometry.size.height)
            .blur(radius: Self.blurRadius)
            .opacity(frameOpacity)
            .position(x: geometry.size.width - Self.blurRadius, y: geometry.size.height / 2)
    }

    // MARK: - Pulse Animation

    private func startPulseAnimationIfNeeded() {
        guard pulsing else { return }

        // Always run pulse animation when pulsing is enabled
        // Frequency and amplitude are controlled by progress level
        let frequency = max(pulseFrequency, Self.basePulseFrequency)
        withAnimation(
            .linear(duration: 1.0 / frequency)
            .repeatForever(autoreverses: false)
        ) {
            pulsePhase = .pi * 2
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func glowLine(in geometry: GeometryProxy, for edgePosition: Position) -> some View {
        let fullLength = edgePosition.isHorizontal ? geometry.size.width : geometry.size.height
        let glowLength = fullLength * lengthFraction

        ZStack(alignment: edgePosition.isHorizontal ? .leading : .top) {
            // The glow line with gradient for soft edges
            if edgePosition.isHorizontal {
                horizontalGlow(length: glowLength, fullLength: fullLength, position: edgePosition)
            } else {
                verticalGlow(length: glowLength, fullLength: fullLength, position: edgePosition)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: edgePosition.isHorizontal ? .leading : .top)
    }

    /// Horizontal glow for top/bottom edge
    private func horizontalGlow(length: CGFloat, fullLength: CGFloat, position: Position) -> some View {
        // Use a gradient that fades at the trailing edge for smooth appearance
        Rectangle()
            .fill(
                LinearGradient(
                    stops: gradientStops(for: length, fullLength: fullLength),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: length > 0 ? max(length, 1) : 0, height: Self.lineThickness)
            .blur(radius: Self.blurRadius)
            .opacity(glowOpacity)
            .frame(maxHeight: .infinity, alignment: .center)
    }

    /// Vertical glow for leading/trailing edge
    private func verticalGlow(length: CGFloat, fullLength: CGFloat, position: Position) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: gradientStops(for: length, fullLength: fullLength),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: Self.lineThickness, height: length > 0 ? max(length, 1) : 0)
            .blur(radius: Self.blurRadius)
            .opacity(glowOpacity)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Generate gradient stops for smooth edge fading
    private func gradientStops(for length: CGFloat, fullLength: CGFloat) -> [Gradient.Stop] {
        // In opacity mode (full width), no edge fade needed
        guard mode != .opacity else {
            return [
                .init(color: .white, location: 0),
                .init(color: .white, location: 1)
            ]
        }

        // For length-based modes, add a soft fade at the leading edge
        // to make the progress feel more organic
        let fadeLength: CGFloat = min(20, length * 0.2)
        let fadeStart = max(0, 1 - (fadeLength / max(length, 1)))

        return [
            .init(color: .white, location: 0),
            .init(color: .white, location: fadeStart),
            .init(color: .white.opacity(0), location: 1)
        ]
    }
}

// MARK: - View Modifier

/// Convenience modifier to add edge glow to any view
struct EdgeGlowModifier: ViewModifier {
    let progress: Double
    let position: EdgeGlow.Position
    let mode: EdgeGlow.Mode
    let pulsing: Bool

    func body(content: Content) -> some View {
        content.overlay(alignment: overlayAlignment) {
            EdgeGlow(progress: progress, position: position, mode: mode, pulsing: pulsing)
        }
    }

    private var overlayAlignment: Alignment {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .frame: return .center
        }
    }
}

extension View {
    /// Adds a subtle edge glow progress indicator to the view.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - position: Which edge to display the glow (default: .top)
    ///   - mode: How progress is visualized (default: .opacity)
    ///   - pulsing: Whether to enable pulse animation - subtle breathing at all times, intensifies above 80% (default: false)
    func edgeGlow(
        progress: Double,
        position: EdgeGlow.Position = .top,
        mode: EdgeGlow.Mode = .opacity,
        pulsing: Bool = false
    ) -> some View {
        modifier(EdgeGlowModifier(progress: progress, position: position, mode: mode, pulsing: pulsing))
    }
}

// MARK: - Previews

#Preview("Opacity Mode - Top Edge") {
    VStack(spacing: 40) {
        Text("Opacity Mode: Glow brightens with progress")
            .font(.caption)
            .foregroundColor(.dpSecondaryText)

        ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { progress in
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)

                Rectangle()
                    .fill(Color.dpBackground)
                    .frame(height: 60)
                    .overlay(alignment: .top) {
                        EdgeGlow(progress: progress, position: .top, mode: .opacity)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.dpSeparator, lineWidth: 0.5)
                    )
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Length Mode - Top Edge") {
    VStack(spacing: 40) {
        Text("Length Mode: Glow extends with progress")
            .font(.caption)
            .foregroundColor(.dpSecondaryText)

        ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { progress in
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)

                Rectangle()
                    .fill(Color.dpBackground)
                    .frame(height: 60)
                    .overlay(alignment: .top) {
                        EdgeGlow(progress: progress, position: .top, mode: .length)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.dpSeparator, lineWidth: 0.5)
                    )
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Combined Mode - Top Edge") {
    VStack(spacing: 40) {
        Text("Combined Mode: Both length and opacity increase")
            .font(.caption)
            .foregroundColor(.dpSecondaryText)

        ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { progress in
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)

                Rectangle()
                    .fill(Color.dpBackground)
                    .frame(height: 60)
                    .overlay(alignment: .top) {
                        EdgeGlow(progress: progress, position: .top, mode: .combined)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.dpSeparator, lineWidth: 0.5)
                    )
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Leading Edge - Length Mode") {
    HStack(spacing: 40) {
        ForEach([0.0, 0.5, 1.0], id: \.self) { progress in
            VStack {
                Rectangle()
                    .fill(Color.dpBackground)
                    .frame(width: 80, height: 200)
                    .overlay(alignment: .leading) {
                        EdgeGlow(progress: progress, position: .leading, mode: .length)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.dpSeparator, lineWidth: 0.5)
                    )

                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Full Screen - Simulated Session") {
    ZStack {
        Color.dpBackground

        VStack(spacing: Spacing.sectionSpacing) {
            Text("What is the dull and persistent\ndissatisfaction you've learned\nto live with?")
                .font(.title2)
                .foregroundColor(.dpPrimaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(8)

            Text("(Subtle glow at top edge indicates progress)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)
        }
        .padding(Spacing.screenPadding)
    }
    .edgeGlow(progress: 0.6, position: .top, mode: .opacity)
    .ignoresSafeArea()
}

#Preview("Animated Progress") {
    AnimatedEdgeGlowPreview()
}

/// Helper view for animated preview
private struct AnimatedEdgeGlowPreview: View {
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Color.dpBackground

            VStack(spacing: 24) {
                Text("Animated Progress Demo")
                    .font(.headline)
                    .foregroundColor(.dpPrimaryText)

                Text("Progress: \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.dpSecondaryText)

                Button("Restart") {
                    progress = 0
                }
                .foregroundColor(.dpPrimaryText)
            }
        }
        .edgeGlow(progress: progress, position: .top, mode: .combined)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 5)) {
                progress = 1
            }
        }
    }
}

// MARK: - Frame Mode Previews

#Preview("Frame Mode - Static Progress Levels") {
    VStack(spacing: 30) {
        Text("Frame Mode: All 4 edges glow")
            .font(.caption)
            .foregroundColor(.dpSecondaryText)

        ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { progress in
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)

                ZStack {
                    Color.dpBackground

                    Text("Pressure")
                        .font(.caption)
                        .foregroundColor(.dpSecondaryText)
                }
                .frame(width: 120, height: 80)
                .overlay {
                    EdgeGlow(progress: progress, position: .frame)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.dpSeparator, lineWidth: 0.5)
                )
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Frame Mode - Full Screen Pressure Chamber") {
    FrameModePreview()
}

/// Helper view for frame mode animated preview
private struct FrameModePreview: View {
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Color.dpBackground

            VStack(spacing: 24) {
                Text("Pressure Chamber Effect")
                    .font(.headline)
                    .foregroundColor(.dpPrimaryText)

                Text("Progress: \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.dpSecondaryText)

                Text(progress > 0.8 ? "Pulsing active!" : "")
                    .font(.caption2)
                    .foregroundColor(.dpSecondaryText)

                Button("Restart") {
                    progress = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 8)) {
                            progress = 1
                        }
                    }
                }
                .foregroundColor(.dpPrimaryText)
            }
        }
        .overlay {
            EdgeGlow(progress: progress, position: .frame, pulsing: true)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 8)) {
                progress = 1
            }
        }
    }
}

#Preview("Frame Mode - High Pressure with Pulsing") {
    ZStack {
        Color.dpBackground

        VStack(spacing: 24) {
            Text("High Pressure State")
                .font(.headline)
                .foregroundColor(.dpPrimaryText)

            Text("Progress: 95% (pulsing)")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)
        }
    }
    .overlay {
        EdgeGlow(progress: 0.95, position: .frame, pulsing: true)
    }
    .ignoresSafeArea()
}
