import Foundation
import SwiftData

@Observable
class JournalingViewModel {
    var session: ProtocolSession
    var currentQuestionIndex: Int = 0
    var currentResponse: String = ""

    private let questions: [Question]

    // MARK: - O(1) Lookup Cache
    /// Dictionary index for fast entry lookup by questionKey
    /// Eliminates O(n) array traversal on every question access
    private var entryByQuestionKey: [String: JournalEntry] = [:]

    init(session: ProtocolSession, part: Int) {
        self.session = session
        self.questions = QuestionService.shared.questions(for: part)
        buildEntryIndex()
        restoreProgress()
    }

    // MARK: - Index Management
    /// Build dictionary index from session entries for O(1) lookups
    private func buildEntryIndex() {
        // Use uniquingKeysWith to safely handle duplicate keys (keeps latest value)
        entryByQuestionKey = Dictionary(
            session.entries.map { ($0.questionKey, $0) },
            uniquingKeysWith: { _, new in new }
        )
    }

    /// Update index when new entry is added
    private func updateIndex(for entry: JournalEntry) {
        entryByQuestionKey[entry.questionKey] = entry
    }

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var questionText: String {
        currentQuestion?.text(for: session.language) ?? ""
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        let clampedIndex = min(currentQuestionIndex + 1, questions.count)
        return Double(clampedIndex) / Double(questions.count)
    }

    var totalQuestions: Int {
        questions.count
    }

    var placeholder: String {
        session.language == "ko" ? "여기에 생각을 적어주세요..." : "Your thoughts..."
    }

    var canProceed: Bool {
        !currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveAndNext(modelContext: ModelContext) {
        let trimmedResponse = currentResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedResponse.isEmpty else { return }
        guard let question = currentQuestion else { return }

        // O(1) lookup using dictionary cache instead of O(n) array traversal
        if let existingEntry = entryByQuestionKey[question.id] {
            existingEntry.response = trimmedResponse
        } else {
            let entry = JournalEntry(
                part: question.part,
                questionKey: question.id,
                response: trimmedResponse
            )
            entry.session = session
            modelContext.insert(entry)
            // Update cache with new entry
            updateIndex(for: entry)
        }

        currentQuestionIndex += 1
        loadResponseForCurrentQuestion()
    }

    func goBack() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
        loadResponseForCurrentQuestion()
    }

    private func restoreProgress() {
        guard !questions.isEmpty else { return }

        if let firstUnansweredIndex = questions.firstIndex(where: { !isAnswered($0) }) {
            currentQuestionIndex = firstUnansweredIndex
        } else {
            currentQuestionIndex = max(questions.count - 1, 0)
        }
        loadResponseForCurrentQuestion()
    }

    private func isAnswered(_ question: Question) -> Bool {
        // O(1) lookup using dictionary cache
        guard let entry = entryByQuestionKey[question.id] else {
            return false
        }
        return !entry.response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadResponseForCurrentQuestion() {
        guard let question = currentQuestion else {
            currentResponse = ""
            return
        }
        // O(1) lookup using dictionary cache
        if let existingEntry = entryByQuestionKey[question.id] {
            currentResponse = existingEntry.response
        } else {
            currentResponse = ""
        }
    }
}
