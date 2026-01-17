import SwiftUI

struct ReadyStepView: View {
    let language: String
    var onBack: () -> Void
    var onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text(language == "ko" ? "\u{C900}\u{BE44}\u{B418}\u{C5C8}\u{C2B5}\u{B2C8}\u{B2E4}" : "You're ready")
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: Spacing.elementSpacing) {
                    ReadyItem(
                        title: language == "ko" ? "Part 1: \u{C131}\u{CC30}" : "Part 1: Reflection",
                        description: language == "ko"
                            ? "\u{C544}\u{CE68}\u{C5D0} 15\u{AC1C}\u{C758} \u{C9C8}\u{BB38}\u{C5D0} \u{B2F5}\u{D558}\u{BA70} \u{C0B6}\u{C744} \u{B3CC}\u{C544}\u{BD05}\u{B2C8}\u{B2E4}"
                            : "Answer 15 questions in the morning to reflect on your life"
                    )

                    ReadyItem(
                        title: language == "ko" ? "Part 2: \u{C911}\u{B2E8}" : "Part 2: Interruption",
                        description: language == "ko"
                            ? "\u{D558}\u{B8E8} \u{C885}\u{C77C} \u{BB34}\u{C791}\u{C704} \u{C54C}\u{B9BC}\u{C744} \u{BC1B}\u{C544} \u{C21C}\u{AC04}\u{C744} \u{AE30}\u{B85D}\u{D569}\u{B2C8}\u{B2E4}"
                            : "Receive random notifications throughout the day to capture moments"
                    )

                    ReadyItem(
                        title: language == "ko" ? "Part 3: \u{D1B5}\u{D569}" : "Part 3: Integration",
                        description: language == "ko"
                            ? "\u{BC24}\u{C5D0} \u{D558}\u{B8E8}\u{B97C} \u{C815}\u{B9AC}\u{D558}\u{ACE0} \u{C0B6}\u{C758} \u{AC8C}\u{C784} \u{C694}\u{C18C}\u{B97C} \u{C815}\u{C758}\u{D569}\u{B2C8}\u{B2E4}"
                            : "Synthesize your day in the evening and define your Life Game components"
                    )
                }
            }

            Spacer()

            VStack(spacing: Spacing.elementSpacing) {
                TextButton(
                    title: language == "ko" ? "Part 1 \u{C2DC}\u{C791} \u{2192}" : "Start Part 1 \u{2192}",
                    action: onStart
                )

                TextButton(title: "\u{2190} Back", action: onBack)
            }
            .padding(.bottom, Spacing.sectionSpacing)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }
}

// MARK: - ReadyItem

struct ReadyItem: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title)
                .font(.dpButton)
                .foregroundColor(.dpPrimaryText)

            Text(description)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.elementSpacing)
        .padding(.horizontal, Spacing.screenPadding)
        .overlay(
            Rectangle()
                .stroke(Color.dpSeparator, lineWidth: 1)
        )
    }
}

#Preview("English") {
    ReadyStepView(
        language: "en",
        onBack: {},
        onStart: {}
    )
}

#Preview("Korean") {
    ReadyStepView(
        language: "ko",
        onBack: {},
        onStart: {}
    )
}
