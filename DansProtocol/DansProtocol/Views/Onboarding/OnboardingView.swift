import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    var onComplete: (ProtocolSession) -> Void

    var body: some View {
        ZStack {
            Color.dpBackground
                .ignoresSafeArea()

            switch viewModel.currentStep {
            case .welcome:
                WelcomeStepView(onContinue: viewModel.nextStep)

            case .language:
                LanguageSelectionView(
                    selectedLanguage: $viewModel.selectedLanguage,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .date:
                DateSelectionView(
                    selectedDate: $viewModel.selectedDate,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .wakeTime:
                WakeTimeSelectionView(
                    wakeUpTime: $viewModel.wakeUpTime,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .notifications:
                NotificationPermissionView(
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .ready:
                ReadyStepView(
                    language: viewModel.selectedLanguage,
                    onBack: viewModel.previousStep,
                    onStart: {
                        let session = viewModel.createSession(modelContext: modelContext)
                        onComplete(session)
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
    }
}

// MARK: - WelcomeStepView

struct WelcomeStepView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                Text("Dan's Protocol")
                    .font(.dpQuestionLarge)
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                Text("Fix your entire life in 1 day.")
                    .font(.dpBody)
                    .foregroundColor(.dpSecondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            TextButton(title: "Begin \u{2192}", action: onContinue)
                .padding(.bottom, Spacing.sectionSpacing)
        }
        .padding(.horizontal, Spacing.screenPadding)
    }
}

#Preview("Onboarding") {
    OnboardingView(onComplete: { _ in })
        .modelContainer(for: ProtocolSession.self, inMemory: true)
}

#Preview("Welcome Step") {
    WelcomeStepView(onContinue: {})
        .background(Color.dpBackground)
}
