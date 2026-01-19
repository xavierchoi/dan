import Foundation

enum LanguageHelper {
    /// Returns the current app language based on iOS per-app language settings
    /// Uses Bundle.main.preferredLocalizations which respects per-app language settings
    /// Falls back to "en" if language cannot be determined or is not Korean
    static var currentLanguage: String {
        let preferred = Bundle.main.preferredLocalizations.first ?? "en"
        return preferred.hasPrefix("ko") ? "ko" : "en"
    }
}
