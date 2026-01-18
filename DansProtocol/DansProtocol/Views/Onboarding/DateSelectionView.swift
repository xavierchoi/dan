import SwiftUI

struct DateSelectionView: View {
    let language: String
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

            VStack(spacing: Spacing.sectionSpacing * 1.5) {
                Text(OnboardingLabels.whenIsProtocolDay(for: language))
                    .font(.dpQuestionLarge(for: language))
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

                if Calendar.current.isDateInToday(selectedDate) {
                    Text(OnboardingLabels.todayWarning(for: language))
                        .font(.dpCaption)
                        .foregroundColor(.dpSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.screenPadding)
                }
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
    DateSelectionView(
        language: "en",
        selectedDate: .constant(Date()),
        onBack: {},
        onContinue: {}
    )
}
