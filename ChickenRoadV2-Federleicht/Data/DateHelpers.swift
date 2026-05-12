import Foundation

enum DateHelpers {
    static let isoDayKey: String = "yyyy-MM-dd"

    static func dayMarker(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = isoDayKey
        return formatter.string(from: date)
    }

    static func startOfWeek(for date: Date = Date()) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    static func sameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        Calendar.current.isDate(lhs, inSameDayAs: rhs)
    }

    static func weekdayIndex(_ date: Date) -> Int {
        Calendar.current.component(.weekday, from: date)
    }

    static func daysOfCurrentWeek() -> [Date] {
        let monday = startOfWeek()
        let calendar = Calendar.current
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
}
