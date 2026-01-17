import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let part: Int
    let order: Int
    let en: String
    let ko: String

    func text(for language: String) -> String {
        language == "ko" ? ko : en
    }
}

struct QuestionsData: Codable {
    let part1: [Question]
    let part2Interrupts: [Question]
    let part2Contemplation: [Question]
    let part3Synthesis: [Question]
    let part3Components: [Question]
}
