import SwiftUI

struct WakeTimeSelectionView: View {
    @Binding var wakeUpTime: Date
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text("What time will you wake up?")
                    .font(.dpQuestionLarge)
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
                TextButton(title: "\u{2190} Back", action: onBack)
                Spacer()
                TextButton(title: "Continue \u{2192}", action: onContinue)
            }
            .padding(.bottom, Spacing.sectionSpacing)
        }
        .padding(.horizontal, Spacing.screenPadding)
        .background(Color.dpBackground)
    }
}

#Preview {
    WakeTimeSelectionView(
        wakeUpTime: .constant(
            Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        ),
        onBack: {},
        onContinue: {}
    )
}
