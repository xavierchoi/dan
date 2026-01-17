import SwiftUI

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    var onBack: () -> Void
    var onContinue: () -> Void

    private var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .month, value: 1, to: today) ?? today
        return today...maxDate
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.sectionSpacing) {
                Text("When is your Protocol Day?")
                    .font(.dpQuestionLarge)
                    .foregroundColor(.dpPrimaryText)
                    .multilineTextAlignment(.center)

                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .tint(.dpPrimaryText)
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
    DateSelectionView(
        selectedDate: .constant(Date()),
        onBack: {},
        onContinue: {}
    )
}
