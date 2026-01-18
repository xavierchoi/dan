import SwiftUI

struct WakeTimeSelectionView: View {
    let language: String
    @Binding var wakeUpTime: Date
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing * 1.5) {
                Text(OnboardingLabels.whatTimeWakeUp(for: language))
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
                TextButton(title: NavLabels.back(for: language), action: onBack)
                Spacer()
                TextButton(title: NavLabels.continueButton(for: language), action: onContinue)
            }
            .padding(.bottom, Spacing.sectionSpacing * 1.5)
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
