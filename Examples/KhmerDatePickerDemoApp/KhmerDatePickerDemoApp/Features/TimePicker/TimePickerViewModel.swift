import Foundation
import KhmerDatePicker

final class TimePickerViewModel: ObservableObject {

    @Published var selectedDate: Date
    @Published var showsSeconds: Bool

    private let calendar: Calendar

    init(initialDate: Date = Date(), showsSeconds: Bool = true) {
        self.selectedDate = initialDate
        self.showsSeconds = showsSeconds
        var cal = Calendar(identifier: .gregorian)
        cal.locale = KhmerLocale.khmer.foundationLocale
        self.calendar = cal
    }

    func timeString(in locale: KhmerLocale) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: .time, locale: locale)
    }

    func dateTimeString(in locale: KhmerLocale) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: .dateTime, locale: locale)
    }

    func components() -> (hour: Int, minute: Int, second: Int) {
        let parts = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
        return (parts.hour ?? 0, parts.minute ?? 0, parts.second ?? 0)
    }

    func renderedComponent(_ value: Int, in locale: KhmerLocale) -> String {
        KhmerNumerals.render(value, in: locale, paddedTo: 2)
    }
}
