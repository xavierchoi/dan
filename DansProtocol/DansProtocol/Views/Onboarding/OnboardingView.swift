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
                WelcomeStepView(
                    language: viewModel.selectedLanguage,
                    onContinue: viewModel.nextStep
                )

            case .language:
                LanguageSelectionView(
                    selectedLanguage: $viewModel.selectedLanguage,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .date:
                DateSelectionView(
                    language: viewModel.selectedLanguage,
                    selectedDate: $viewModel.selectedDate,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .wakeTime:
                WakeTimeSelectionView(
                    language: viewModel.selectedLanguage,
                    wakeUpTime: $viewModel.wakeUpTime,
                    onBack: viewModel.previousStep,
                    onContinue: viewModel.nextStep
                )

            case .notifications:
                NotificationPermissionView(
                    language: viewModel.selectedLanguage,
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
    let language: String
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
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
    WelcomeStepView(language: "en", onContinue: {})
        .background(Color.dpBackground)
}
