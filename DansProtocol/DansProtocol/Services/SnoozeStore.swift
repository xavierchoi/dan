import Foundation

/// Stores snooze counts per question for the current session.
///
/// When a user skips an interrupt question:
/// - Snooze count < 2: Schedule a 30-minute reminder
/// - Snooze count >= 2: No more notifications, user must answer in-app
enum SnoozeStore {
    private static let sessionIdKey = "snoozeSessionId"
    private static let countsKey = "snoozeCounts"

    /// Maximum snoozes before notifications stop
    static let maxSnoozeCount = 2

    /// Delay before snooze reminder (30 minutes)
    static let snoozeDelayMinutes = 30

    // MARK: - Public API

    /// Get snooze count for a specific question in the current session
    static func snoozeCount(for questionId: String, sessionId: UUID) -> Int {
        let counts = loadCounts(for: sessionId)
        return counts[questionId] ?? 0
    }

    /// Increment snooze count for a question. Returns the new count.
    @discardableResult
    static func incrementSnooze(for questionId: String, sessionId: UUID) -> Int {
        var counts = loadCounts(for: sessionId)
        let currentCount = counts[questionId] ?? 0
        let newCount = currentCount + 1
        counts[questionId] = newCount
        saveCounts(counts, for: sessionId)
        return newCount
    }

    /// Check if question has reached max snooze count
    static func hasReachedMaxSnooze(for questionId: String, sessionId: UUID) -> Bool {
        snoozeCount(for: questionId, sessionId: sessionId) >= maxSnoozeCount
    }

    /// Reset snooze count for a specific question (e.g., when answered)
    static func resetSnooze(for questionId: String, sessionId: UUID) {
        var counts = loadCounts(for: sessionId)
        counts.removeValue(forKey: questionId)
        saveCounts(counts, for: sessionId)
    }

    /// Get all question IDs that have reached max snooze count
    static func maxSnoozedQuestionIds(sessionId: UUID) -> [String] {
        let counts = loadCounts(for: sessionId)
        return counts.filter { $0.value >= maxSnoozeCount }.map { $0.key }
    }

    /// Clear all snooze data
    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: sessionIdKey)
        defaults.removeObject(forKey: countsKey)
    }

    // MARK: - Private Helpers

    private static func loadCounts(for sessionId: UUID) -> [String: Int] {
        let defaults = UserDefaults.standard
        let currentSessionId = sessionId.uuidString
        let storedSessionId = defaults.string(forKey: sessionIdKey)

        // Clear counts if session changed
        if storedSessionId != currentSessionId {
            defaults.set(currentSessionId, forKey: sessionIdKey)
            defaults.removeObject(forKey: countsKey)
            return [:]
        }

        guard let data = defaults.data(forKey: countsKey),
              let counts = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }

        return counts
    }

    private static func saveCounts(_ counts: [String: Int], for sessionId: UUID) {
        let defaults = UserDefaults.standard
        defaults.set(sessionId.uuidString, forKey: sessionIdKey)

        if let data = try? JSONEncoder().encode(counts) {
            defaults.set(data, forKey: countsKey)
        }
    }
}
