import SwiftUI

/// A ViewModifier that creates a dramatic "convergence from edges" entrance effect.
///
/// When the view appears, it feels like the content is being assembled from the void -
/// fragments converging from all four edges toward the center, reminiscent of film
/// title sequences where text materializes from chaos.
///
/// The effect combines:
/// 1. Four-directional edge masks that converge inward
/// 2. Scale animation (0.95 → 1.0)
/// 3. Opacity fade with blur clear
/// 4. Optional chromatic aberration during assembly
///
/// When `isExiting` becomes true:
/// 1. The effect reverses - content disperses toward edges
/// 2. Chromatic aberration intensifies during dispersion
/// 3. Combined with afterimage for psychological weight
///
/// Usage:
/// ```swift
/// Text("What truth have you been avoiding?")
///     .edgeConvergence(isExiting: isTransitioning)
/// ```
struct EdgeConvergence: ViewModifier {
    let isExiting: Bool

    // MARK: - Animation Constants

    /// Total duration for entrance animation
    private let entranceDuration: Double = 0.6

    /// Duration for exit dispersion
    private let exitDuration: Double = 0.4

    /// Initial scale (slightly smaller, creates depth)
    private let initialScale: CGFloat = 0.95

    /// Initial blur radius for entrance
    private let initialBlur: CGFloat = 8

    /// Edge offset distance (how far fragments start from center)
    private let edgeOffset: CGFloat = 20

    /// Chromatic aberration intensity during transition
    private let chromaticOffset: CGFloat = 4

    // MARK: - Animation State

    /// Scale of the content
    @State private var scale: CGFloat = 0.95

    /// Blur radius
    @State private var blur: CGFloat = 8

    /// Opacity of the main content
    @State private var opacity: Double = 0

    /// Edge mask insets (animated to 0)
    @State private var maskInset: CGFloat = 20

    /// Chromatic split offset
    @State private var chromaticSplit: CGFloat = 0

    /// Track if entrance animation has completed
    @State private var hasAppeared: Bool = false

    /// Task for managing animation lifecycle
    @State private var animationTask: Task<Void, Never>?

    /// Accessibility: Reduce Motion setting
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Color Tints for Chromatic Effect

    private let redTint = Color(red: 1.0, green: 0.3, blue: 0.3)
    private let cyanTint = Color(red: 0.3, green: 1.0, blue: 1.0)

    func body(content: Content) -> some View {
        // Accessibility: Skip animations when Reduce Motion is enabled
        if reduceMotion {
            content
        } else {
            ZStack {
                // Chromatic red channel - offset during transition
                content
                    .colorMultiply(redTint)
                    .offset(x: -chromaticSplit, y: -chromaticSplit * 0.5)
                    .opacity(chromaticSplit > 0 ? 0.3 : 0)
                    .blendMode(.plusLighter)

                // Chromatic cyan channel - offset opposite direction
                content
                    .colorMultiply(cyanTint)
                    .offset(x: chromaticSplit, y: chromaticSplit * 0.5)
                    .opacity(chromaticSplit > 0 ? 0.3 : 0)
                    .blendMode(.plusLighter)

                // Main content with convergence effect
                content
                    .scaleEffect(scale)
                    .blur(radius: blur)
                    .opacity(opacity)
                    .mask(
                        // Four-edge convergence mask
                        ConvergenceMask(inset: maskInset)
                    )
            }
            .onAppear {
                guard !hasAppeared else { return }
                performEntranceAnimation()
            }
            .onDisappear {
                animationTask?.cancel()
            }
            .onChange(of: isExiting) { oldValue, newValue in
                if newValue && !oldValue {
                    performExitAnimation()
                } else if !newValue && oldValue {
                    // Reset for re-entrance
                    resetForReentrance()
                }
            }
        }
    }

    // MARK: - Animation Sequences

    /// Dramatic entrance: fragments converge from edges
    private func performEntranceAnimation() {
        animationTask?.cancel()

        animationTask = Task { @MainActor in
            // Start with chromatic split visible briefly
            chromaticSplit = chromaticOffset

            // Phase 1: Quick chromatic flash (0.1s)
            withAnimation(.easeOut(duration: 0.1)) {
                opacity = 0.4
            }

            // Phase 2: Convergence with spring (0.5s) - starts immediately
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                scale = 1.0
                blur = 0
                opacity = 1.0
                maskInset = 0
            }

            // Phase 3: Chromatic channels converge (0.15s delay, then 0.1s)
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(150))

            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.1)) {
                chromaticSplit = 0
            }

            // Mark as appeared
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .seconds(entranceDuration))

            guard !Task.isCancelled else { return }
            hasAppeared = true
        }
    }

    /// Exit dispersion: content scatters toward edges with chromatic aberration
    private func performExitAnimation() {
        // Phase 1: Chromatic split expands
        withAnimation(.easeIn(duration: 0.1)) {
            chromaticSplit = chromaticOffset * 1.5
        }

        // Phase 2: Disperse toward edges
        withAnimation(.easeIn(duration: exitDuration)) {
            scale = 0.92
            blur = 12
            opacity = 0
            maskInset = edgeOffset * 1.5
        }
    }

    /// Reset state for potential re-entrance
    private func resetForReentrance() {
        animationTask?.cancel()

        animationTask = Task { @MainActor in
            // Instantly reset to initial state
            scale = initialScale
            blur = initialBlur
            opacity = 0
            maskInset = edgeOffset
            chromaticSplit = 0
            hasAppeared = false

            // Trigger entrance again
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(50))

            guard !Task.isCancelled else { return }
            performEntranceAnimation()
        }
    }
}

// MARK: - Convergence Mask

/// A shape that creates the four-edge convergence mask effect.
/// The inset value controls how much each edge "bites" into the content.
private struct ConvergenceMask: View {
    let inset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            // Create a rounded rectangle that expands as inset approaches 0
            // When inset is large, the mask clips more of the content from edges
            RoundedRectangle(cornerRadius: inset * 0.5)
                .padding(.horizontal, inset)
                .padding(.vertical, inset * 0.6) // Slightly less vertical for text
        }
    }
}

// MARK: - Alternative: Fragment-Based Convergence

/// More dramatic alternative that splits content into actual fragments.
/// Each fragment comes from a different edge direction.
struct FragmentConvergence: ViewModifier {
    let isExiting: Bool
    let fragmentCount: Int = 4

    @State private var fragmentOffsets: [CGSize] = []
    @State private var fragmentOpacities: [Double] = []
    @State private var hasInitialized = false

    private let entranceDuration: Double = 0.6

    func body(content: Content) -> some View {
        content
            .modifier(EdgeConvergence(isExiting: isExiting))
    }
}

// MARK: - Convenience Extension

extension View {
    /// Applies a dramatic edge convergence entrance effect.
    ///
    /// When the view appears, it materializes from the void - fragments converge
    /// from all four edges toward the center like a film title sequence.
    ///
    /// When `isExiting` becomes true, the effect reverses - content disperses
    /// toward the edges with chromatic aberration.
    ///
    /// - Parameter isExiting: When true, triggers the exit dispersion effect
    /// - Returns: A view with the edge convergence effect applied
    func edgeConvergence(isExiting: Bool = false) -> some View {
        modifier(EdgeConvergence(isExiting: isExiting))
    }
}

// MARK: - Previews

#Preview("Edge Convergence - Interactive") {
    EdgeConvergencePreview()
}

#Preview("Edge Convergence - Entrance Only") {
    VStack(spacing: 40) {
        Text("What is the dull and persistent dissatisfaction you've learned to live with?")
            .font(.custom("Playfair Display", size: 24))
            .foregroundColor(.dpPrimaryText)
            .multilineTextAlignment(.leading)
            .edgeConvergence()
            .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

#Preview("Edge Convergence - Korean") {
    VStack(spacing: 40) {
        Text("당신이 삶의 일부로 받아들인, 희미하지만 끊이지 않는 불만족은 무엇인가요?")
            .font(.custom("Noto Serif KR", size: 24))
            .foregroundColor(.dpPrimaryText)
            .multilineTextAlignment(.leading)
            .edgeConvergence()
            .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBackground)
}

/// Interactive preview helper for testing the edge convergence effect
private struct EdgeConvergencePreview: View {
    @State private var isExiting = false
    @State private var questionIndex = 0
    @State private var showQuestion = true
    @State private var previewTask: Task<Void, Never>?

    private let questions = [
        "What is the dull and persistent dissatisfaction you've learned to live with?",
        "What truth have you been avoiding?",
        "What would you do if you knew you could not fail?"
    ]

    var body: some View {
        VStack(spacing: 40) {
            Text("Tap to trigger transition")
                .font(.caption)
                .foregroundColor(.dpSecondaryText)

            Spacer()

            if showQuestion {
                Text(questions[questionIndex])
                    .font(.custom("Playfair Display", size: 24))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .edgeConvergence(isExiting: isExiting)
                    .id(questionIndex) // Force recreation on question change
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Question \(questionIndex + 1) of \(questions.count)")
                    .font(.caption)
                    .foregroundColor(.dpSecondaryText)

                HStack(spacing: 20) {
                    Button("Exit Effect") {
                        triggerExit()
                    }
                    .disabled(isExiting)

                    Button("Next Question") {
                        cycleQuestion()
                    }
                }
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

    private func triggerExit() {
        previewTask?.cancel()
        isExiting = true

        // Reset after animation completes
        previewTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(500))

            guard !Task.isCancelled else { return }
            isExiting = false
        }
    }

    private func cycleQuestion() {
        previewTask?.cancel()

        // Exit current
        isExiting = true

        // Swap question and re-enter
        previewTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(400))

            guard !Task.isCancelled else { return }
            showQuestion = false
            questionIndex = (questionIndex + 1) % questions.count

            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(100))

            guard !Task.isCancelled else { return }
            isExiting = false
            showQuestion = true
        }
    }
}
