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
                Text(language == "ko" ? "프로토콜 데이는 언제인가요?" : "When is your Protocol Day?")
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
            }

            Spacer()

            HStack {
                TextButton(title: language == "ko" ? "← 이전" : "← Back", action: onBack)
                Spacer()
                TextButton(title: language == "ko" ? "계속 →" : "Continue →", action: onContinue)
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
