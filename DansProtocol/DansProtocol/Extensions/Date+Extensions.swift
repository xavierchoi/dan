import Foundation

extension Date {
    // Static formatters - expensive to create, so cached
    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    var longDateString: String {
        Date.longDateFormatter.string(from: self)
    }

    var monthYearString: String {
        Date.monthYearFormatter.string(from: self)
    }
}
