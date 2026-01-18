import Foundation
import SwiftData

enum ProtocolStatus: String, Codable {
    case notStarted
    case part1
    case part2
    case part3Synthesis    // 기존 part3 → part3Synthesis로 변경
    case part3Components   // 새로 추가: Components 입력 단계
    case completed

    // MARK: - Migration for existing "part3" data
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // 기존 "part3" 값을 "part3Synthesis"로 매핑 (하위 호환성)
        if rawValue == "part3" {
            self = .part3Synthesis
        } else if let status = ProtocolStatus(rawValue: rawValue) {
            self = status
        } else {
            self = .notStarted
        }
    }
}

@Model
final class ProtocolSession {
    var id: UUID
    var startDate: Date
    var wakeUpTime: Date
    var language: String
    var status: ProtocolStatus
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
        status: ProtocolStatus = .notStarted
    ) {
        self.id = id
        self.startDate = startDate
        self.wakeUpTime = wakeUpTime
        self.language = language
        self.status = status
    }
}
