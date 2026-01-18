import SwiftUI

struct CompletionView: View {
    let session: ProtocolSession
    var onContinue: () -> Void

    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?

    // MARK: - Animation State

    /// Edge glow progress - starts full, dims to 0.3 for catharsis effect
    @State private var edgeGlowProgress: Double = 1.0

    /// Opacity values for cascading component fade-in (6 components)
    @State private var componentOpacities: [Double] = Array(repeating: 0.0, count: 6)

    // MARK: - Computed Properties

    /// The 6 Life Game component data for display
    private var componentData: [(title: String, value: String)] {
        guard let components = session.components else { return [] }
        let isKorean = session.language == "ko"
        return [
            (isKorean ? "안티비전" : "Anti-Vision", components.antiVision),
            (isKorean ? "비전" : "Vision", components.vision),
            (isKorean ? "1년 목표" : "1-Year Goal", components.oneYearGoal),
            (isKorean ? "1달 프로젝트" : "1-Month Project", components.oneMonthProject),
            (isKorean ? "일일 레버" : "Daily Levers", components.dailyLevers.joined(separator: "\n")),
            (isKorean ? "제약" : "Constraints", components.constraints)
        ]
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    // MARK: - Title with breathing animation
                    Text(session.language == "ko" ? "당신의 라이프 게임" : "Your Life Game")
                        .breathingTypography(for: session.language, fontSize: 32, includeScale: true)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.questionTopPadding)

                    // MARK: - 6 Components with cascading fade-in
                    ForEach(Array(componentData.enumerated()), id: \.offset) { index, component in
                        ComponentRow(
                            title: component.title,
                            value: component.value
                        )
                        .opacity(componentOpacities[index])
                    }

                    Spacer(minLength: Spacing.sectionSpacing)

                    HStack {
                        TextButton(
                            title: session.language == "ko" ? "공유" : "Share",
                            action: generateAndShare
                        )

                        Spacer()

                        TextButton(
                            title: session.language == "ko" ? "완료 →" : "Finish →",
                            action: onContinue
                        )
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
        .edgeGlow(progress: edgeGlowProgress, position: .frame, pulsing: false)
        .onAppear {
            // Haptic feedback - heartbeat pattern for completion
            HapticEngine.shared.completionHeartbeat()

            // Slowly dim the edge glow for catharsis effect (release, calm after storm)
            withAnimation(.easeOut(duration: 4.0)) {
                edgeGlowProgress = 0.3
            }

            // Cascade fade-in for the 6 components
            for index in 0..<componentOpacities.count {
                withAnimation(.easeIn(duration: 0.5).delay(Double(index) * 0.3 + 1.0)) {
                    componentOpacities[index] = 1.0
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func generateAndShare() {
        guard let components = session.components else { return }
        shareImage = ShareImageGenerator.generate(components: components, language: session.language)
        showingShareSheet = true
    }
}

struct ComponentRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)

            Text(value)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
    }
}
