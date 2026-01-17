import Foundation
import SwiftData

@Model
final class ProtocolSession {
    var id: UUID
    var startDate: Date
    var wakeUpTime: Date
    var language: String
    var status: String
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.session)
    var entries: [JournalEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \LifeGameComponents.session)
    var components: LifeGameComponents?

    init(
        id: UUID = UUID(),
        startDate: Date,
        wakeUpTime: Date,
        language: String = "en",
        status: String = "notStarted"
    ) {
        self.id = id
        self.startDate = startDate
        self.wakeUpTime = wakeUpTime
        self.language = language
        self.status = status
    }
}

extension ProtocolSession {
    enum Status: String {
        case notStarted
        case part1
        case part2
        case part3
        case completed
    }
}
