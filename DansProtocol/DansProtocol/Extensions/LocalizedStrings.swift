import Foundation

/// Localized strings helper for Life Game components
enum ComponentLabels {
    static func antiVision(for language: String) -> String {
        language == "ko" ? "안티비전" : "Anti-Vision"
    }

    static func vision(for language: String) -> String {
        language == "ko" ? "비전" : "Vision"
    }

    static func oneYearGoal(for language: String) -> String {
        language == "ko" ? "1년 목표" : "1-Year Goal"
    }

    static func oneMonthProject(for language: String) -> String {
        language == "ko" ? "1개월 프로젝트" : "1-Month Project"
    }

    static func dailyLevers(for language: String) -> String {
        language == "ko" ? "일일 레버" : "Daily Levers"
    }

    static func constraints(for language: String) -> String {
        language == "ko" ? "제약 조건" : "Constraints"
    }

    static func noData(for language: String) -> String {
        language == "ko" ? "데이터 없음" : "No data available"
    }

    static func noComparisonData(for language: String) -> String {
        language == "ko" ? "비교 데이터 없음" : "No comparison data available"
    }

    static func then(for language: String) -> String {
        language == "ko" ? "과거" : "THEN"
    }

    static func now(for language: String) -> String {
        language == "ko" ? "현재" : "NOW"
    }
}
