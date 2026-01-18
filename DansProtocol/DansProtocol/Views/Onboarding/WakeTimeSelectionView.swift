import SwiftUI

struct WakeTimeSelectionView: View {
    let language: String
    @Binding var wakeUpTime: Date
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text(language == "ko" ? "몇 시에 일어나시나요?" : "What time will you wake up?")
                    .font(.dpQuestionLarge(for: language))
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                DatePicker(
                    "",
                    selection: $wakeUpTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
            }

            Spacer()

            HStack {
                TextButton(title: language == "ko" ? "← 이전" : "← Back", action: onBack)
                Spacer()
                TextButton(title: language == "ko" ? "계속 →" : "Continue →", action: onContinue)
            }
            .padding(.bottom, Spacing.sectionSpacing)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }
}

#Preview {
    WakeTimeSelectionView(
        language: "en",
        wakeUpTime: .constant(
            Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        ),
        onBack: {},
        onContinue: {}
    )
}
