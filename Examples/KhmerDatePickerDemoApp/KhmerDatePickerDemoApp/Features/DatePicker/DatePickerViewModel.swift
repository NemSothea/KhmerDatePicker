import Foundation
import KhmerDatePicker

final class DatePickerViewModel: ObservableObject {

    @Published var selectedDate: Date

    init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
    }

    func formatted(in locale: KhmerLocale, style: KhmerDateFormatter.Style) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: style, locale: locale)
    }

    /// Every style we want to render in the demo, in display order.
    var allStyles: [(style: KhmerDateFormatter.Style, label: String)] {
        [
            (.full,     "Full"),
            (.long,     "Long"),
            (.medium,   "Medium"),
            (.short,    "Short"),
            (.time,     "Time"),
            (.dateTime, "Date + Time"),
        ]
    }

    /// Stable identifier suffix for accessibility / UI testing.
    static func identifier(for style: KhmerDateFormatter.Style, locale: KhmerLocale) -> String {
        "format.\(locale.rawValue).\(String(describing: style))"
    }
}
