import Foundation

public enum KhmerCalendarSymbols {

    public static let months: [String] = [
        "មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុនា",
        "កក្កដា", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិកា", "ធ្នូ"
    ]

    public static let monthsShort: [String] = [
        "មក", "កុម្ភៈ", "មីនា", "មេសា", "ឧស", "មិថុ",
        "កក្ក", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិ", "ធ្នូ"
    ]

    public static let weekdaysFull: [String] = [
        "អាទិត្យ", "ច័ន្ទ", "អង្គារ", "ពុធ", "ព្រហស្បតិ៍", "សុក្រ", "សៅរ៍"
    ]

    public static let weekdaysShort: [String] = [
        "អា", "ច", "អ", "ព", "ព្រ", "សុ", "ស"
    ]

    public static let day = "ថ្ងៃ"
    public static let month = "ខែ"
    public static let year = "ឆ្នាំ"
    public static let ordinal = "ទី"

    public static let hour = "ម៉ោង"
    public static let minute = "នាទី"
    public static let second = "វិនាទី"

    public static func month(at index: Int, locale: KhmerLocale) -> String {
        switch locale {
        case .khmer:
            return months[index]
        case .english:
            let formatter = DateFormatter()
            formatter.locale = locale.foundationLocale
            return formatter.monthSymbols[index]
        }
    }

    public static func weekdaySymbols(short: Bool, locale: KhmerLocale) -> [String] {
        switch locale {
        case .khmer:
            return short ? weekdaysShort : weekdaysFull
        case .english:
            let formatter = DateFormatter()
            formatter.locale = locale.foundationLocale
            return short ? formatter.shortWeekdaySymbols : formatter.weekdaySymbols
        }
    }
}
