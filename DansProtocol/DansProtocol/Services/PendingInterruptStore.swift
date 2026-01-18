import Foundation

enum PendingInterruptStore {
    private static let sessionIdKey = "pendingInterruptSessionId"
    private static let idsKey = "pendingInterruptQuestionIds"
    private static let legacyIdsKey = "pendingInterruptQuestionIdsLegacy"

    static func load(for sessionId: UUID) -> [String] {
        let defaults = UserDefaults.standard
        let currentSessionId = sessionId.uuidString
        let storedSessionId = defaults.string(forKey: sessionIdKey)

        if storedSessionId != currentSessionId {
            defaults.set(currentSessionId, forKey: sessionIdKey)
            defaults.set([], forKey: idsKey)
        }

        var ids = defaults.stringArray(forKey: idsKey) ?? []
        let legacyIds = defaults.stringArray(forKey: legacyIdsKey) ?? []

        if !legacyIds.isEmpty {
            for id in legacyIds where !ids.contains(id) {
                ids.append(id)
            }
            defaults.removeObject(forKey: legacyIdsKey)
            save(ids, for: sessionId)
        }

        return ids
    }

    static func add(_ id: String, sessionId: UUID) {
        var ids = load(for: sessionId)
        guard !ids.contains(id) else { return }
        ids.append(id)
        save(ids, for: sessionId)
    }

    static func addLegacy(_ id: String) {
        let defaults = UserDefaults.standard
        var ids = defaults.stringArray(forKey: legacyIdsKey) ?? []
        guard !ids.contains(id) else { return }
        ids.append(id)
        defaults.set(ids, forKey: legacyIdsKey)
    }

    static func remove(_ id: String, sessionId: UUID) {
        var ids = load(for: sessionId)
        ids.removeAll { $0 == id }
        save(ids, for: sessionId)
    }

    static func save(_ ids: [String], for sessionId: UUID) {
        let defaults = UserDefaults.standard
        defaults.set(sessionId.uuidString, forKey: sessionIdKey)
        defaults.set(ids, forKey: idsKey)
    }

    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: sessionIdKey)
        defaults.removeObject(forKey: idsKey)
        defaults.removeObject(forKey: legacyIdsKey)
    }
}
