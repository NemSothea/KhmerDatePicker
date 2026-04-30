import Foundation

public struct KhmerDateFormatter {

    public enum Style: Hashable, Sendable {
        case full
        case long
        case medium
        case short
        case time
        case dateTime
    }

    public static func string(from date: Date, style: Style, locale: KhmerLocale) -> String {
        switch locale {
        case .khmer:   return khmerString(from: date, style: style)
        case .english: return englishString(from: date, style: style)
        }
    }

    public static func string(
        from date: Date,
        style: Style,
        locale: KhmerLocale,
        calendar: Calendar
    ) -> String {
        switch locale {
        case .khmer:   return khmerString(from: date, style: style, calendar: calendar)
        case .english: return englishString(from: date, style: style, calendar: calendar)
        }
    }

    // MARK: Khmer

    private static func khmerString(from date: Date, style: Style, calendar: Calendar = .gregorianKhmer) -> String {
        let comps = calendar.dateComponents([.day, .month, .year, .hour, .minute, .weekday], from: date)
        let day = comps.day ?? 1
        let monthIndex = (comps.month ?? 1) - 1
        let year = comps.year ?? 0
        let weekdayIndex = (comps.weekday ?? 1) - 1
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0

        let kDay = KhmerNumerals.toKhmer(day)
        let kDayPadded = KhmerNumerals.toKhmer(String(format: "%02d", day))
        let kMonthPadded = KhmerNumerals.toKhmer(String(format: "%02d", monthIndex + 1))
        let kYear = KhmerNumerals.toKhmer(year)
        let kHour = KhmerNumerals.toKhmer(String(format: "%02d", hour))
        let kMinute = KhmerNumerals.toKhmer(String(format: "%02d", minute))
        let monthName = KhmerCalendarSymbols.months[monthIndex]
        let weekdayName = KhmerCalendarSymbols.weekdaysFull[weekdayIndex]

        let datePart = "\(KhmerCalendarSymbols.day) \(weekdayName) \(KhmerCalendarSymbols.ordinal) \(kDay) \(KhmerCalendarSymbols.month) \(monthName) \(KhmerCalendarSymbols.year) \(kYear)"
        let timePart = "\(KhmerCalendarSymbols.hour) \(kHour) \(KhmerCalendarSymbols.minute) \(kMinute)"

        switch style {
        case .full:
            return datePart
        case .long:
            return "\(kDay) \(monthName) \(kYear)"
        case .medium:
            return "\(kDayPadded) \(monthName) \(kYear)"
        case .short:
            return "\(kDayPadded)/\(kMonthPadded)/\(kYear)"
        case .time:
            return timePart
        case .dateTime:
            return "\(datePart) \(timePart)"
        }
    }

    // MARK: English

    private static func englishString(from date: Date, style: Style, calendar: Calendar = .gregorianEnglish) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = KhmerLocale.english.foundationLocale

        switch style {
        case .full:
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
        case .long:
            formatter.dateFormat = "d MMMM yyyy"
        case .medium:
            formatter.dateFormat = "dd MMM yyyy"
        case .short:
            formatter.dateFormat = "dd/MM/yyyy"
        case .time:
            formatter.dateFormat = "HH:mm"
        case .dateTime:
            formatter.dateFormat = "EEEE, MMMM d, yyyy HH:mm"
        }
        return formatter.string(from: date)
    }
}

extension Calendar {
    static let gregorianKhmer: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = KhmerLocale.khmer.foundationLocale
        return cal
    }()

    static let gregorianEnglish: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = KhmerLocale.english.foundationLocale
        return cal
    }()
}
