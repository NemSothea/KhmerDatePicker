import Foundation
import KhmerDatePicker

final class EdgeCasesViewModel: ObservableObject {

    enum Fixture: String, CaseIterable, Identifiable {
        case leapDay
        case endOfMonth
        case endOfYear
        case timeBoundary
        case midnight
        case today

        var id: String { rawValue }

        var title: (km: String, en: String) {
            switch self {
            case .leapDay:      return ("ថ្ងៃ​ឆ្នាំ​លោត", "Leap day (Feb 29 2024)")
            case .endOfMonth:   return ("ថ្ងៃ​ចុង​ខែ", "End of month (Jan 31 2026)")
            case .endOfYear:    return ("ថ្ងៃ​ចុង​ឆ្នាំ", "End of year (Dec 31 2026 23:59:59)")
            case .timeBoundary: return ("ម៉ោង​ដែន​កំណត់", "Time boundary 23:59:59 today")
            case .midnight:     return ("ម៉ោង​អាធ្រាត្រ", "Midnight 00:00:00 today")
            case .today:        return ("ថ្ងៃ​នេះ", "Today")
            }
        }

        /// Calendar pinned to Asia/Phnom_Penh so fixtures don't drift across CI runners.
        private static var calendar: Calendar {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
            return cal
        }

        func date(now: Date = Date()) -> Date {
            let cal = Self.calendar
            switch self {
            case .leapDay:
                return cal.date(from: DateComponents(year: 2024, month: 2, day: 29, hour: 12, minute: 0, second: 0)) ?? now
            case .endOfMonth:
                return cal.date(from: DateComponents(year: 2026, month: 1, day: 31, hour: 9, minute: 0, second: 0)) ?? now
            case .endOfYear:
                return cal.date(from: DateComponents(year: 2026, month: 12, day: 31, hour: 23, minute: 59, second: 59)) ?? now
            case .timeBoundary:
                let today = cal.dateComponents([.year, .month, .day], from: now)
                return cal.date(from: DateComponents(
                    year: today.year, month: today.month, day: today.day,
                    hour: 23, minute: 59, second: 59
                )) ?? now
            case .midnight:
                return cal.startOfDay(for: now)
            case .today:
                return now
            }
        }
    }

    @Published var selectedDate: Date

    init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
    }

    func apply(_ fixture: Fixture, now: Date = Date()) {
        selectedDate = fixture.date(now: now)
    }

    func format(_ style: KhmerDateFormatter.Style, in locale: KhmerLocale) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: style, locale: locale)
    }
}
