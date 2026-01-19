import SwiftUI
import SwiftData

struct InterruptView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: ProtocolSession
    let questionId: String
    var questionType: QuestionService.QuestionType = .interrupt
    var onDismiss: (() -> Void)?
    var onSkip: ((String) -> Void)?  // Called with questionId when user skips
    @State private var response: String = ""

    /// Controls the chromatic aberration glitch effect on appear
    @State private var showGlitch = false

    private var question: Question? {
        QuestionService.shared.questions(for: 2, type: questionType)
            .first { $0.id == questionId }
    }

    private var placeholder: String {
        session.language == "ko" ? "짧은 생각..." : "A brief thought..."
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                QuestionView(text: question?.text(for: session.language) ?? "", language: session.language)

                Spacer()

                MinimalTextField(
                    placeholder: placeholder,
                    text: $response
                )

                Spacer()

                HStack {
                    TextButton(title: NavLabels.skip(for: session.language), action: handleSkip)

                    Spacer()

                    TextButton(
                        title: NavLabels.save(for: session.language),
                        action: handleSave,
                        isEnabled: !response.isEmpty
                    )
                }
                .padding(Spacing.screenPadding)
                .padding(.bottom, Spacing.screenPadding)
            }
        }
        // Micro-tremor: stronger tremor for disruption mood
        .microTremor(intensity: 0.5)
        // Edge glow: always full brightness, always pulsing for urgency
        .edgeGlow(progress: 1.0, pulsing: true)
        // Chromatic aberration: jarring glitch on appear
        .chromaticAberration(isActive: showGlitch, offset: 5)
        // Dithering: jarring disruption at 0.6 intensity, always animated
        .ditheringOverlay(intensity: 0.6, animated: true)
        .onAppear {
            // Instant appear with immediate glitch effect - no fade in
            showGlitch = true
            // Staccato 3x burst haptic for jarring disruption
            HapticEngine.shared.interruptBurst()
            // Reset glitch after effect completes
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                showGlitch = false
            }
        }
    }

    private func dismissView() {
        dismiss()
        onDismiss?()
    }

    /// Handle skip button with haptic feedback and snooze logic
    private func handleSkip() {
        HapticEngine.shared.buttonTap()

        // For interrupt questions, use snooze logic (which handles dismiss)
        if questionType == .interrupt, let onSkip = onSkip {
            dismiss()
            onSkip(questionId)
            return
        }

        // For other question types (contemplation), just dismiss
        dismissView()
    }

    /// Handle save button with haptic feedback
    private func handleSave() {
        guard let question = question else { return }

        HapticEngine.shared.buttonTap()

        if let existingEntry = session.entries.first(where: { $0.questionKey == question.id }) {
            existingEntry.response = response
        } else {
            let entry = JournalEntry(
                part: 2,
                questionKey: question.id,
                response: response
            )
            entry.session = session
            modelContext.insert(entry)
        }

        PendingInterruptStore.remove(question.id, sessionId: session.id)

        // Clear snooze state and cancel pending snooze reminders for this question
        if questionType == .interrupt {
            SnoozeStore.resetSnooze(for: question.id, sessionId: session.id)
            NotificationService.shared.cancelSnoozeReminders(for: question.id)
        }

        NotificationCenter.default.post(
            name: .didAnswerInterrupt,
            object: nil,
            userInfo: [
                "questionId": question.id,
                "sessionId": session.id.uuidString
            ]
        )

        dismissView()
    }
}

#Preview {
    let session = ProtocolSession(
        startDate: Date(),
        wakeUpTime: Date(),
        language: "en"
    )
    return InterruptView(session: session, questionId: "p2_interrupt_1")
}
