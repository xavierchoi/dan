import SwiftUI
import SwiftData

struct ComponentsInputView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ComponentsInputViewModel
    var onComplete: () -> Void

    init(session: ProtocolSession, onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: ComponentsInputViewModel(session: session))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                QuestionView(text: viewModel.currentPrompt, language: viewModel.session.language)

                // Show Anti-Vision primer only on the anti-vision question
                if viewModel.isAntiVisionQuestion {
                    AntiVisionPrimer(language: viewModel.session.language)
                        .padding(.horizontal, Spacing.screenPadding)
                }

                // Show Daily Levers input hint
                if viewModel.isDailyLeversQuestion {
                    Text(ComponentLabels.dailyLeversHint(for: viewModel.session.language))
                        .font(.dpCaption)
                        .foregroundColor(.dpSecondaryText)
                        .padding(.horizontal, Spacing.screenPadding)
                        .padding(.top, Spacing.elementSpacing)
                }

                Spacer()

                MinimalTextField(
                    placeholder: viewModel.placeholder,
                    text: $viewModel.currentResponse
                )

                Spacer()

                HStack {
                    if viewModel.currentIndex > 0 {
                        TextButton(title: NavLabels.back(for: viewModel.session.language), action: viewModel.goBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLast ? NavLabels.complete(for: viewModel.session.language) : NavLabels.continueButton(for: viewModel.session.language),
                        action: {
                            viewModel.saveAndNext(modelContext: modelContext)
                            if viewModel.isDone {
                                onComplete()
                            }
                        },
                        isEnabled: viewModel.canProceed
                    )
                }
                .padding(Spacing.screenPadding)
                .padding(.bottom, Spacing.screenPadding)
            }
        }
    }
}

@Observable
class ComponentsInputViewModel {
    var session: ProtocolSession
    var currentIndex: Int = 0
    var currentResponse: String = ""

    private let prompts: [Question]
    private var components: LifeGameComponents

    init(session: ProtocolSession) {
        self.session = session
        self.prompts = QuestionService.shared.questions(for: 3, type: .components)
        self.components = session.components ?? LifeGameComponents()
        restoreProgress()
    }

    var currentPrompt: String {
        guard currentIndex < prompts.count else { return "" }
        return prompts[currentIndex].text(for: session.language)
    }

    var placeholder: String {
        session.language == "ko" ? "여기에 적어주세요..." : "Write here..."
    }

    var isLast: Bool {
        currentIndex >= prompts.count - 1
    }

    var isAntiVisionQuestion: Bool {
        guard currentIndex < prompts.count else { return false }
        return prompts[currentIndex].id == "part3_component_antivision"
    }

    var isDailyLeversQuestion: Bool {
        guard currentIndex < prompts.count else { return false }
        return prompts[currentIndex].id == "part3_component_dailylevers"
    }

    var isDone: Bool {
        currentIndex >= prompts.count
    }

    var canProceed: Bool {
        !currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveAndNext(modelContext: ModelContext) {
        let trimmedResponse = currentResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedResponse.isEmpty else { return }
        guard currentIndex < prompts.count else { return }

        // Map response to appropriate component field
        let promptId = prompts[currentIndex].id
        switch promptId {
        case "part3_component_antivision":
            components.antiVision = trimmedResponse
        case "part3_component_vision":
            components.vision = trimmedResponse
        case "part3_component_oneyear":
            components.oneYearGoal = trimmedResponse
        case "part3_component_onemonth":
            components.oneMonthProject = trimmedResponse
        case "part3_component_dailylevers":
            // Split by newlines or commas
            components.dailyLevers = trimmedResponse
                .split(whereSeparator: { $0.isNewline || $0 == "," })
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        case "part3_component_constraints":
            components.constraints = trimmedResponse
        default:
            break
        }

        // Save components to session if not already
        if session.components == nil {
            components.session = session
            modelContext.insert(components)
            session.components = components
        }

        currentIndex += 1
        loadCurrentValue()
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        loadCurrentValue()
    }

    private func restoreProgress() {
        guard !prompts.isEmpty else { return }

        if let firstUnansweredIndex = prompts.firstIndex(where: { currentValue(for: $0.id).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            currentIndex = firstUnansweredIndex
        } else {
            currentIndex = max(prompts.count - 1, 0)
        }
        loadCurrentValue()
    }

    private func currentValue(for promptId: String) -> String {
        switch promptId {
        case "part3_component_antivision":
            return components.antiVision
        case "part3_component_vision":
            return components.vision
        case "part3_component_oneyear":
            return components.oneYearGoal
        case "part3_component_onemonth":
            return components.oneMonthProject
        case "part3_component_dailylevers":
            return components.dailyLevers.joined(separator: "\n")
        case "part3_component_constraints":
            return components.constraints
        default:
            return ""
        }
    }

    private func loadCurrentValue() {
        guard currentIndex < prompts.count else {
            currentResponse = ""
            return
        }

        let promptId = prompts[currentIndex].id
        currentResponse = currentValue(for: promptId)
    }
}

// MARK: - AntiVisionPrimer

/// Subtle introduction to the Anti-Vision concept
struct AntiVisionPrimer: View {
    let language: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(ComponentLabels.antiVision(for: language))
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
                .italic()

            Text(OnboardingLabels.antiVisionPrimer(for: language))
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.elementSpacing)
    }
}

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return ComponentsInputView(session: session, onComplete: {})
}
