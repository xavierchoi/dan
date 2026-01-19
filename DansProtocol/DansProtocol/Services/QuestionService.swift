import Foundation

class QuestionService {
    static let shared = QuestionService()

    private var questionsData: QuestionsData?

    /// Error message if Questions.json failed to load
    private(set) var loadError: String?

    /// Returns true if Questions.json loaded successfully
    var isLoaded: Bool { questionsData != nil }

    private init() {
        loadQuestions()
    }

    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "Questions", withExtension: "json") else {
            loadError = "Questions.json file not found in app bundle"
            assertionFailure("Missing Questions.json in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            questionsData = try JSONDecoder().decode(QuestionsData.self, from: data)
        } catch {
            loadError = "Failed to parse Questions.json: \(error.localizedDescription)"
            assertionFailure("Failed to load Questions.json: \(error)")
        }
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

    /// Find a question by its ID across all parts
    func question(byId id: String) -> Question? {
        guard let data = questionsData else { return nil }

        let allQuestions = data.part1
            + data.part2Interrupts
            + data.part2Contemplation
            + data.part3Synthesis
            + data.part3Components

        return allQuestions.first { $0.id == id }
    }

    enum QuestionType {
        case main
        case interrupt
        case contemplation
        case synthesis
        case components
    }
}
