import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
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
                            onContinue: { advanceStep() }
                        )

                    case .language:
                        LanguageSelectionView(
                            selectedLanguage: $viewModel.selectedLanguage,
                            onBack: { goBack() },
                            onContinue: { advanceStep() }
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
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text("Dan's Protocol")
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                Text(language == "ko" ? "하루 만에 인생 전체를 바꾸세요." : "Fix your entire life in 1 day.")
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            TextButton(
                title: language == "ko" ? "시작하기 →" : "Begin →",
                action: onContinue
            )
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
        }
        .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview("Onboarding") {
    OnboardingView(onComplete: { _ in })
        .modelContainer(for: ProtocolSession.self, inMemory: true)
}

#Preview("Welcome Step") {
    WelcomeStepView(language: "en", onContinue: {})
        .background(Color.dpBackground)
}
