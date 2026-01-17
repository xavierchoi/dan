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

                Spacer()

                MinimalTextField(
                    placeholder: viewModel.placeholder,
                    text: $viewModel.currentResponse
                )

                Spacer()

                HStack {
                    if viewModel.currentIndex > 0 {
                        TextButton(title: "← Back", action: viewModel.goBack)
                    }

                    Spacer()

                    TextButton(
                        title: viewModel.isLast ? "Complete →" : "Continue →",
                        action: {
                            viewModel.saveAndNext(modelContext: modelContext)
                            if viewModel.isDone {
                                onComplete()
                            }
                        },
                        isEnabled: !viewModel.currentResponse.isEmpty
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

    var isDone: Bool {
        currentIndex >= prompts.count
    }

    func saveAndNext(modelContext: ModelContext) {
        guard currentIndex < prompts.count else { return }

        // Map response to appropriate component field
        let promptId = prompts[currentIndex].id
        switch promptId {
        case "part3_component_antivision":
            components.antiVision = currentResponse
        case "part3_component_vision":
            components.vision = currentResponse
        case "part3_component_oneyear":
            components.oneYearGoal = currentResponse
        case "part3_component_onemonth":
            components.oneMonthProject = currentResponse
        case "part3_component_dailylevers":
            // Split by newlines or commas
            components.dailyLevers = currentResponse
                .split(whereSeparator: { $0.isNewline || $0 == "," })
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        case "part3_component_constraints":
            components.constraints = currentResponse
        default:
            break
        }

        // Save components to session if not already
        if session.components == nil {
            components.session = session
            modelContext.insert(components)
            session.components = components
        }

        currentResponse = ""
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        loadCurrentValue()
    }

    private func loadCurrentValue() {
        guard currentIndex < prompts.count else {
            currentResponse = ""
            return
        }

        let promptId = prompts[currentIndex].id
        switch promptId {
        case "part3_component_antivision":
            currentResponse = components.antiVision
        case "part3_component_vision":
            currentResponse = components.vision
        case "part3_component_oneyear":
            currentResponse = components.oneYearGoal
        case "part3_component_onemonth":
            currentResponse = components.oneMonthProject
        case "part3_component_dailylevers":
            currentResponse = components.dailyLevers.joined(separator: "\n")
        case "part3_component_constraints":
            currentResponse = components.constraints
        default:
            currentResponse = ""
        }
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
