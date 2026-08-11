import Foundation

enum WeekDay: Int, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var title: String {
        switch self {
        case .monday:
            String(localized: "weekday.monday")
        case .tuesday:
            String(localized: "weekday.tuesday")
        case .wednesday:
            String(localized: "weekday.wednesday")
        case .thursday:
            String(localized: "weekday.thursday")
        case .friday:
            String(localized: "weekday.friday")
        case .saturday:
            String(localized: "weekday.saturday")
        case .sunday:
            String(localized: "weekday.sunday")
        }
    }
    var shortTitle: String {
        switch self {
        case .monday:
            String(localized: "weekday.monday.short")
        case .tuesday:
            String(localized: "weekday.tuesday.short")
        case .wednesday:
            String(localized: "weekday.wednesday.short")
        case .thursday:
            String(localized: "weekday.thursday.short")
        case .friday:
            String(localized: "weekday.friday.short")
        case .saturday:
            String(localized: "weekday.saturday.short")
        case .sunday:
            String(localized: "weekday.sunday.short")
        }
    }
}
