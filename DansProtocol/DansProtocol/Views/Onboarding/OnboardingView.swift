import SwiftUI
import SwiftData

struct OnboardingView: View {
    // MARK: - FetchDescriptor for Query Optimization
    /// Fetch only 1 session to check if history exists
    /// This avoids loading all sessions just to check !sessions.isEmpty
    static var anySessionDescriptor: FetchDescriptor<ProtocolSession> {
        var descriptor = FetchDescriptor<ProtocolSession>()
        descriptor.fetchLimit = 1
        return descriptor
    }

    @Environment(\.modelContext) private var modelContext
    @Query(OnboardingView.anySessionDescriptor) private var sessions: [ProtocolSession]
    @State private var viewModel = OnboardingViewModel()
    @State private var showingHistorySheet = false
    var onComplete: (ProtocolSession) -> Void

    /// Total number of onboarding steps for progress indicator
    private let totalSteps = OnboardingViewModel.OnboardingStep.allCases.count

    var body: some View {
        ZStack {
            Color.dpBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeStepView(
                            language: viewModel.selectedLanguage,
                            hasHistory: !sessions.isEmpty,
                            onContinue: { advanceStep() },
                            onViewHistory: { showingHistorySheet = true }
                        )

                    case .date:
                        DateSelectionView(
                            language: viewModel.selectedLanguage,
                            selectedDate: $viewModel.selectedDate,
                            onBack: { goBack() },
                            onContinue: { advanceStep() }
                        )

                    case .wakeTime:
                        WakeTimeSelectionView(
                            language: viewModel.selectedLanguage,
                            wakeUpTime: $viewModel.wakeUpTime,
                            onBack: { goBack() },
                            onContinue: { advanceStep() }
                        )

                    case .notifications:
                        NotificationPermissionView(
                            language: viewModel.selectedLanguage,
                            onBack: { goBack() },
                            onContinue: { advanceStep() }
                        )

                    case .ready:
                        ReadyStepView(
                            language: viewModel.selectedLanguage,
                            onBack: { goBack() },
                            onStart: {
                                HapticEngine.shared.buttonTap()
                                let session = viewModel.createSession(modelContext: modelContext)
                                onComplete(session)
                            }
                        )
                    }
                }
                .frame(maxHeight: .infinity)

                // Step indicator dots - subtle progress at bottom
                StepIndicatorView(
                    currentStep: viewModel.currentStep.rawValue,
                    totalSteps: totalSteps
                )
                .padding(.bottom, Spacing.sectionSpacing)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: viewModel.currentStep)
        .sheet(isPresented: $showingHistorySheet) {
            HistoryView(sessions: sessions, onStartNew: {}, isModal: true)
        }
    }

    /// Advance to next step with haptic feedback
    private func advanceStep() {
        HapticEngine.shared.buttonTap()
        withAnimation(.easeInOut(duration: 0.8)) {
            viewModel.nextStep()
        }
    }

    /// Go back to previous step with haptic feedback
    private func goBack() {
        HapticEngine.shared.buttonTap()
        withAnimation(.easeInOut(duration: 0.8)) {
            viewModel.previousStep()
        }
    }
}

// MARK: - StepIndicatorView

/// Subtle step indicator dots for onboarding progress
struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Image(systemName: step == currentStep ? "circle.fill" : "circle")
                    .font(.system(size: 6))
                    .foregroundColor(.dpSecondaryText)
                    .opacity(step == currentStep ? 0.6 : 0.3)
            }
        }
    }
}

// MARK: - WelcomeStepView

struct WelcomeStepView: View {
    let language: String
    let hasHistory: Bool
    var onContinue: () -> Void
    var onViewHistory: () -> Void

    /// Dan Koe's original article URL
    private let danKoeArticleURL = URL(string: "https://x.com/thedankoe/status/2010751592346030461")!

    var body: some View {
        VStack(spacing: 0) {
            // History button in top right
            HStack {
                Spacer()
                if hasHistory {
                    Button(action: onViewHistory) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(OnboardingLabels.viewHistory(for: language))
                                .font(.dpCaption)
                        }
                        .foregroundColor(.dpSecondaryText)
                    }
                }
            }
            .padding(.top, Spacing.elementSpacing)

            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text(OnboardingLabels.appTitle)
                    .breathingText(for: language, fontSize: 32, duration: 6.0)
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                Text(OnboardingLabels.tagline(for: language))
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                TextButton(
                    title: NavLabels.begin(for: language),
                    action: onContinue
                )

                // Dan Koe credit link
                Link(destination: danKoeArticleURL) {
                    Text(OnboardingLabels.credit(for: language))
                        .font(.dpCaption)
                        .foregroundColor(.dpSecondaryText)
                        .underline()
                }
            }
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
        }
        .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview("Onboarding") {
    OnboardingView(onComplete: { _ in })
        .modelContainer(for: ProtocolSession.self, inMemory: true)
}

#Preview("Welcome Step - No History") {
    WelcomeStepView(
        language: "en",
        hasHistory: false,
        onContinue: {},
        onViewHistory: {}
    )
    .background(Color.dpBackground)
}

#Preview("Welcome Step - With History") {
    WelcomeStepView(
        language: "ko",
        hasHistory: true,
        onContinue: {},
        onViewHistory: {}
    )
    .background(Color.dpBackground)
}
