import Foundation

class QuestionService {
    static let shared = QuestionService()

    private var questionsData: QuestionsData?

    private init() {
        loadQuestions()
    }

    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "Questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        questionsData = try? JSONDecoder().decode(QuestionsData.self, from: data)
    }

    func questions(for part: Int, type: QuestionType = .main) -> [Question] {
        guard let data = questionsData else { return [] }

        switch (part, type) {
        case (1, _): return data.part1
        case (2, .interrupt): return data.part2Interrupts
        case (2, .contemplation): return data.part2Contemplation
        case (3, .synthesis): return data.part3Synthesis
        case (3, .components): return data.part3Components
        default: return []
        }
    }

    enum QuestionType {
        case main
        case interrupt
        case contemplation
        case synthesis
        case components
    }
}
