import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var part: Int
    var questionKey: String
    var response: String
    var createdAt: Date

    var session: ProtocolSession?

    init(
        id: UUID = UUID(),
        part: Int,
        questionKey: String,
        response: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.part = part
        self.questionKey = questionKey
        self.response = response
        self.createdAt = createdAt
    }
}
