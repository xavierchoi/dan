import SwiftUI

/// A subtle, almost subliminal progress indicator that appears as a glowing edge.
///
/// Rather than displaying explicit progress (like a percentage bar), this component
/// creates a barely-perceptible glow at the screen edge that users "feel" rather than
/// consciously track. This aligns with Dan's Protocol's typographic tension design system.
///
/// Two modes are available:
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
/// ```
struct EdgeGlow: View {

    // MARK: - Types

    /// The edge where the glow appears
    enum Position {
        case top
        case leading

        var isHorizontal: Bool {
            self == .top
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
    /// Blur radius for the glow effect (2-4px as per spec)
    private static let blurRadius: CGFloat = 3

    // MARK: - Properties

    /// Progress value from 0.0 to 1.0
    let progress: Double
    /// Which edge the glow appears on
    let position: Position
    /// How the progress is visualized
    let mode: Mode

    // MARK: - Computed Properties

    /// Calculate opacity based on progress and mode
    private var glowOpacity: Double {
        switch mode {
        case .opacity, .combined:
            // Linear interpolation: 0.1 at 0%, 0.5 at 100%
            return Self.minOpacity + (clampedProgress * (Self.maxOpacity - Self.minOpacity))
        case .length:
            // Constant opacity in length mode for consistent visibility
            return 0.35
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
    init(progress: Double, position: Position = .top, mode: Mode = .opacity) {
        self.progress = progress
        self.position = position
        self.mode = mode
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            glowLine(in: geometry)
        }
        .frame(
            width: position.isHorizontal ? nil : Self.lineThickness + Self.blurRadius * 2,
            height: position.isHorizontal ? Self.lineThickness + Self.blurRadius * 2 : nil
        )
    }

    // MARK: - Private Views

    @ViewBuilder
    private func glowLine(in geometry: GeometryProxy) -> some View {
        let fullLength = position.isHorizontal ? geometry.size.width : geometry.size.height
        let glowLength = fullLength * lengthFraction

        ZStack(alignment: position.isHorizontal ? .leading : .top) {
            // The glow line with gradient for soft edges
            if position.isHorizontal {
                horizontalGlow(length: glowLength, fullLength: fullLength)
            } else {
                verticalGlow(length: glowLength, fullLength: fullLength)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.isHorizontal ? .leading : .top)
    }

    /// Horizontal glow for top edge
    private func horizontalGlow(length: CGFloat, fullLength: CGFloat) -> some View {
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

    /// Vertical glow for leading edge
    private func verticalGlow(length: CGFloat, fullLength: CGFloat) -> some View {
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

    func body(content: Content) -> some View {
        content.overlay(alignment: overlayAlignment) {
            EdgeGlow(progress: progress, position: position, mode: mode)
        }
    }

    private var overlayAlignment: Alignment {
        switch position {
        case .top: return .top
        case .leading: return .leading
        }
    }
}

extension View {
    /// Adds a subtle edge glow progress indicator to the view.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - position: Which edge to display the glow (default: .top)
    ///   - mode: How progress is visualized (default: .opacity)
    func edgeGlow(
        progress: Double,
        position: EdgeGlow.Position = .top,
        mode: EdgeGlow.Mode = .opacity
    ) -> some View {
        modifier(EdgeGlowModifier(progress: progress, position: position, mode: mode))
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
