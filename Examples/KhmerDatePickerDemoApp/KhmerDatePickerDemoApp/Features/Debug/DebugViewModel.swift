import Foundation
import KhmerDatePickerSwiftUI

final class DebugViewModel: ObservableObject {

    @Published var selectedDate: Date

    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = KhmerLocale.khmer.foundationLocale
        return cal
    }()

    init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
    }

    // MARK: Raw

    var epochSeconds: String {
        String(format: "%.3f", selectedDate.timeIntervalSince1970)
    }

    var iso8601: String {
        isoFormatter.string(from: selectedDate)
    }

    var debugDescription: String {
        String(describing: selectedDate)
    }

    // MARK: Components

    struct Component: Identifiable, Hashable {
        let id: String
        let name: String
        let arabic: String
        let khmer: String
    }

    func components() -> [Component] {
        let parts = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .weekday],
            from: selectedDate
        )
        let weekdayIndex = (parts.weekday ?? 1) - 1
        let weekdayName = KhmerCalendarSymbols.weekdaysFull[weekdayIndex]
        let monthIndex = (parts.month ?? 1) - 1
        let monthName = KhmerCalendarSymbols.months[monthIndex]

        return [
            row("year",    arabic: "\(parts.year ?? 0)",   khmer: KhmerNumerals.toKhmer(parts.year ?? 0)),
            row("month",   arabic: "\(parts.month ?? 0)",  khmer: "\(monthName) (\(KhmerNumerals.toKhmer(parts.month ?? 0)))"),
            row("day",     arabic: "\(parts.day ?? 0)",    khmer: KhmerNumerals.toKhmer(parts.day ?? 0)),
            row("hour",    arabic: padded(parts.hour ?? 0),   khmer: KhmerNumerals.render(parts.hour ?? 0, in: .khmer, paddedTo: 2)),
            row("minute",  arabic: padded(parts.minute ?? 0), khmer: KhmerNumerals.render(parts.minute ?? 0, in: .khmer, paddedTo: 2)),
            row("second",  arabic: padded(parts.second ?? 0), khmer: KhmerNumerals.render(parts.second ?? 0, in: .khmer, paddedTo: 2)),
            row("weekday", arabic: "\(parts.weekday ?? 0)", khmer: weekdayName),
        ]
    }

    private func padded(_ value: Int) -> String {
        String(format: "%02d", value)
    }

    private func row(_ name: String, arabic: String, khmer: String) -> Component {
        Component(id: name, name: name, arabic: arabic, khmer: khmer)
    }

    // MARK: Logging

    func snapshot() -> AppEnvironment.LogEntry {
        AppEnvironment.LogEntry(
            timestamp: Date(),
            khmer:   KhmerDateFormatter.string(from: selectedDate, style: .dateTime, locale: .khmer),
            english: KhmerDateFormatter.string(from: selectedDate, style: .dateTime, locale: .english)
        )
    }
}
