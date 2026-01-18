import Foundation
import SwiftData

@Observable
class JournalingViewModel {
    var session: ProtocolSession
    var currentQuestionIndex: Int = 0
    var currentResponse: String = ""

    private let questions: [Question]

    init(session: ProtocolSession, part: Int) {
        self.session = session
        self.questions = QuestionService.shared.questions(for: part)
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
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var totalQuestions: Int {
        questions.count
    }

    var placeholder: String {
        session.language == "ko" ? "여기에 생각을 적어주세요..." : "Your thoughts..."
    }

    func saveAndNext(modelContext: ModelContext) {
        guard let question = currentQuestion else { return }

        // Update existing entry or create new one
        if let existingEntry = session.entries.first(where: { $0.questionKey == question.id }) {
            existingEntry.response = currentResponse
        } else {
            let entry = JournalEntry(
                part: question.part,
                questionKey: question.id,
                response: currentResponse
            )
            entry.session = session
            modelContext.insert(entry)
        }

        currentResponse = ""
        currentQuestionIndex += 1
    }

    func goBack() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
        loadResponseForCurrentQuestion()
    }

    private func loadResponseForCurrentQuestion() {
        guard let question = currentQuestion else {
            currentResponse = ""
            return
        }
        if let existingEntry = session.entries.first(where: { $0.questionKey == question.id }) {
            currentResponse = existingEntry.response
        } else {
            currentResponse = ""
        }
    }
}
