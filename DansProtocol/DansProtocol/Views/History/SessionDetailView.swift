import SwiftUI

struct SessionDetailView: View {
    let session: ProtocolSession

    @State private var expandedParts: Set<Int> = []

    private var dateString: String {
        session.completedAt?.longDateString ?? ""
    }

    private var language: String {
        session.language
    }

    /// Group entries by part number
    private var entriesByPart: [Int: [JournalEntry]] {
        Dictionary(grouping: session.entries) { $0.part }
    }

    var body: some View {
        ZStack {
            Color.dpBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sectionSpacing) {
                    // Date header
                    Text(dateString)
                        .font(.dpQuestionLarge)
                        .foregroundColor(.dpPrimaryText)
                        .padding(.top, Spacing.elementSpacing)

                    // MARK: - Life Game Components Section
                    if let components = session.components {
                        SectionHeader(
                            title: HistoryLabels.lifeGameComponents(for: language)
                        )

                        VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                            ComponentSection(
                                title: ComponentLabels.antiVision(for: language),
                                value: components.antiVision
                            )

                            ComponentSection(
                                title: ComponentLabels.vision(for: language),
                                value: components.vision
                            )

                            ComponentSection(
                                title: ComponentLabels.oneYearGoal(for: language),
                                value: components.oneYearGoal
                            )

                            ComponentSection(
                                title: ComponentLabels.oneMonthProject(for: language),
                                value: components.oneMonthProject
                            )

                            ComponentSection(
                                title: ComponentLabels.dailyLevers(for: language),
                                value: components.dailyLevers.joined(separator: " • ")
                            )

                            ComponentSection(
                                title: ComponentLabels.constraints(for: language),
                                value: components.constraints,
                                showSeparator: false
                            )
                        }
                    }

                    // MARK: - Journal Entries Section
                    if !session.entries.isEmpty {
                        SectionHeader(
                            title: HistoryLabels.journalEntries(for: language)
                        )
                        .padding(.top, Spacing.elementSpacing)

                        // Part 1 Entries
                        JournalPartSection(
                            part: 1,
                            title: HistoryLabels.part1Reflection(for: language),
                            entries: entriesByPart[1] ?? [],
                            language: language,
                            isExpanded: expandedParts.contains(1),
                            onToggle: { togglePart(1) }
                        )

                        // Part 2 Entries
                        JournalPartSection(
                            part: 2,
                            title: HistoryLabels.part2Interrupts(for: language),
                            entries: entriesByPart[2] ?? [],
                            language: language,
                            isExpanded: expandedParts.contains(2),
                            onToggle: { togglePart(2) }
                        )

                        // Part 3 Entries
                        JournalPartSection(
                            part: 3,
                            title: HistoryLabels.part3Synthesis(for: language),
                            entries: entriesByPart[3] ?? [],
                            language: language,
                            isExpanded: expandedParts.contains(3),
                            onToggle: { togglePart(3) }
                        )
                    }
                }
                .padding(Spacing.screenPadding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func togglePart(_ part: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedParts.contains(part) {
                expandedParts.remove(part)
            } else {
                expandedParts.insert(part)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.dpCaption)
            .foregroundColor(.dpSecondaryText)
            .tracking(2)
    }
}

// MARK: - Journal Part Section (Collapsible)

struct JournalPartSection: View {
    let part: Int
    let title: String
    let entries: [JournalEntry]
    let language: String
    let isExpanded: Bool
    let onToggle: () -> Void

    /// Sorted entries by creation date
    private var sortedEntries: [JournalEntry] {
        entries.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with toggle
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(.dpBody)
                        .fontWeight(.medium)
                        .foregroundColor(.dpPrimaryText)

                    Spacer()

                    Text("\(entries.count)")
                        .font(.dpCaption)
                        .foregroundColor(.dpSecondaryText)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.dpSecondaryText)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, Spacing.elementSpacing)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.elementSpacing) {
                    if entries.isEmpty {
                        Text(HistoryLabels.noEntries(for: language))
                            .font(.dpCaption)
                            .foregroundColor(.dpSecondaryText)
                            .padding(.bottom, Spacing.elementSpacing)
                    } else {
                        ForEach(sortedEntries, id: \.id) { entry in
                            JournalEntryRow(entry: entry, language: language)
                        }
                    }
                }
                .padding(.bottom, Spacing.elementSpacing)
            }

            // Separator
            Rectangle()
                .fill(Color.dpSeparator)
                .frame(height: 1)
        }
    }
}

// MARK: - Journal Entry Row

struct JournalEntryRow: View {
    let entry: JournalEntry
    let language: String

    /// Get question text from QuestionService
    private var questionText: String {
        if let question = QuestionService.shared.question(byId: entry.questionKey) {
            return question.text(for: language)
        }
        return entry.questionKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            // Question
            Text(questionText)
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            // Response
            Text(entry.response.isEmpty ? "—" : entry.response)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, Spacing.lineSpacing)
    }
}

// MARK: - Component Section

struct ComponentSection: View {
    let title: String
    let value: String
    var showSeparator: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lineSpacing) {
            Text(title.uppercased())
                .font(.dpCaption)
                .foregroundColor(.dpSecondaryText)
                .tracking(1)

            Text(value.isEmpty ? "—" : value)
                .font(.dpBody)
                .foregroundColor(.dpPrimaryText)

            if showSeparator {
                Rectangle()
                    .fill(Color.dpSeparator)
                    .frame(height: 1)
                    .padding(.top, Spacing.lineSpacing)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(
            session: ProtocolSession(
                startDate: Date(),
                wakeUpTime: Date(),
                language: "en",
                status: .completed
            )
        )
    }
}
