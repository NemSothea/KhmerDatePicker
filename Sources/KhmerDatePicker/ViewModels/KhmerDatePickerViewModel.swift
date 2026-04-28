import Foundation
import Combine

final class KhmerDatePickerViewModel: ObservableObject {

    @Published var selectedDate: Date
    @Published var displayedMonth: Date
    @Published var locale: KhmerLocale
    @Published var mode: KhmerDatePickerMode
    @Published var showsSeconds: Bool
    @Published var range: ClosedRange<Date>?

    let firstWeekday: Int

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = firstWeekday
        cal.locale = locale.foundationLocale
        return cal
    }

    init(
        initialDate: Date = Date(),
        locale: KhmerLocale = .khmer,
        mode: KhmerDatePickerMode = .date,
        firstWeekday: Int = 1,
        showsSeconds: Bool = false,
        range: ClosedRange<Date>? = nil
    ) {
        let clamped = Self.clamp(initialDate, to: range)
        self.selectedDate = clamped
        self.displayedMonth = Self.startOfMonth(for: clamped, firstWeekday: firstWeekday)
        self.locale = locale
        self.mode = mode
        self.firstWeekday = firstWeekday
        self.showsSeconds = showsSeconds
        self.range = range
    }

    // MARK: Header

    var monthLabel: String {
        let comps = calendar.dateComponents([.month, .year], from: displayedMonth)
        let monthIndex = (comps.month ?? 1) - 1
        let year = comps.year ?? 0
        let monthName = KhmerCalendarSymbols.month(at: monthIndex, locale: locale)
        let yearString = KhmerNumerals.render(year, in: locale)
        return "\(monthName) \(yearString)"
    }

    var weekdayHeader: [String] {
        let symbols = KhmerCalendarSymbols.weekdaySymbols(short: true, locale: locale)
        return rotated(symbols, by: firstWeekday - 1)
    }

    // MARK: Calendar grid

    struct DayCell: Identifiable, Hashable {
        let id: Date
        let date: Date
        let dayNumber: Int
        let label: String
        let isInDisplayedMonth: Bool
        let isToday: Bool
        let isSelected: Bool
        let isEnabled: Bool
        let accessibilityLabel: String
    }

    var dayCells: [DayCell] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        let firstOfMonth = monthInterval.start
        let firstWeekdayIndex = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekdayIndex - calendar.firstWeekday + 7) % 7

        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        var cells: [DayCell] = []
        cells.reserveCapacity(42)

        if leadingBlanks > 0,
           let prevMonthStart = calendar.date(byAdding: .month, value: -1, to: firstOfMonth),
           let prevDays = calendar.range(of: .day, in: .month, for: prevMonthStart)?.count {
            let startingDay = prevDays - leadingBlanks + 1
            for offset in 0..<leadingBlanks {
                let day = startingDay + offset
                if let date = calendar.date(bySetting: .day, value: day, of: prevMonthStart) {
                    cells.append(makeCell(for: date, dayNumber: day, isInDisplayedMonth: false))
                }
            }
        }

        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                cells.append(makeCell(for: date, dayNumber: day, isInDisplayedMonth: true))
            }
        }

        let trailing = 42 - cells.count
        if trailing > 0,
           let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: firstOfMonth) {
            for day in 1...trailing {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonthStart) {
                    cells.append(makeCell(for: date, dayNumber: day, isInDisplayedMonth: false))
                }
            }
        }
        return cells
    }

    private func makeCell(for date: Date, dayNumber: Int, isInDisplayedMonth: Bool) -> DayCell {
        DayCell(
            id: date,
            date: date,
            dayNumber: dayNumber,
            label: KhmerNumerals.render(dayNumber, in: locale),
            isInDisplayedMonth: isInDisplayedMonth,
            isToday: calendar.isDateInToday(date),
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
            isEnabled: isDayEnabled(date),
            accessibilityLabel: KhmerDateFormatter.string(
                from: date,
                style: .full,
                locale: locale,
                calendar: calendar
            )
        )
    }

    // MARK: Time

    var hourComponents: [Int] { Array(0...23) }
    var minuteComponents: [Int] { Array(0...59) }
    var secondComponents: [Int] { Array(0...59) }

    var selectedHour: Int {
        get { calendar.component(.hour, from: selectedDate) }
        set { setTime(hour: newValue) }
    }

    var selectedMinute: Int {
        get { calendar.component(.minute, from: selectedDate) }
        set { setTime(minute: newValue) }
    }

    var selectedSecond: Int {
        get { calendar.component(.second, from: selectedDate) }
        set { setTime(second: newValue) }
    }

    func label(forHour hour: Int) -> String {
        KhmerNumerals.render(hour, in: locale, paddedTo: 2)
    }

    func label(forMinute minute: Int) -> String {
        KhmerNumerals.render(minute, in: locale, paddedTo: 2)
    }

    func label(forSecond second: Int) -> String {
        KhmerNumerals.render(second, in: locale, paddedTo: 2)
    }

    // MARK: Range

    var canGoToPreviousMonth: Bool {
        guard let range = range else { return true }
        guard let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth),
              let interval = calendar.dateInterval(of: .month, for: prev) else {
            return false
        }
        return interval.start < range.upperBound && interval.end > range.lowerBound
    }

    var canGoToNextMonth: Bool {
        guard let range = range else { return true }
        guard let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth),
              let interval = calendar.dateInterval(of: .month, for: next) else {
            return false
        }
        return interval.start < range.upperBound && interval.end > range.lowerBound
    }

    private func isDayEnabled(_ date: Date) -> Bool {
        guard let range = range else { return true }
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return false
        }
        return dayStart < range.upperBound && dayEnd > range.lowerBound
    }

    // MARK: Mutations

    func selectDate(_ date: Date) {
        let merged = mergeTime(into: date)
        let clamped = Self.clamp(merged, to: range)
        selectedDate = clamped
        if !calendar.isDate(clamped, equalTo: displayedMonth, toGranularity: .month) {
            displayedMonth = Self.startOfMonth(for: clamped, firstWeekday: firstWeekday)
        }
    }

    func goToPreviousMonth() {
        guard canGoToPreviousMonth else { return }
        if let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = Self.startOfMonth(for: prev, firstWeekday: firstWeekday)
        }
    }

    func goToNextMonth() {
        guard canGoToNextMonth else { return }
        if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = Self.startOfMonth(for: next, firstWeekday: firstWeekday)
        }
    }

    func goToToday() {
        let today = Self.clamp(Date(), to: range)
        selectedDate = today
        displayedMonth = Self.startOfMonth(for: today, firstWeekday: firstWeekday)
    }

    func formatted(style: KhmerDateFormatter.Style) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: style, locale: locale, calendar: calendar)
    }

    func syncSelection(_ date: Date) {
        let clamped = Self.clamp(date, to: range)
        guard clamped != selectedDate else { return }
        selectedDate = clamped
        if !calendar.isDate(clamped, equalTo: displayedMonth, toGranularity: .month) {
            displayedMonth = Self.startOfMonth(for: clamped, firstWeekday: firstWeekday)
        }
    }

    // MARK: Helpers

    private func setTime(hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
        if let hour = hour { comps.hour = hour }
        if let minute = minute { comps.minute = minute }
        if let second = second { comps.second = second }
        if let updated = calendar.date(from: comps) {
            selectedDate = Self.clamp(updated, to: range)
        }
    }

    private func mergeTime(into newDate: Date) -> Date {
        let timeComps = calendar.dateComponents([.hour, .minute, .second], from: selectedDate)
        var merged = calendar.dateComponents([.year, .month, .day], from: newDate)
        merged.hour = timeComps.hour
        merged.minute = timeComps.minute
        merged.second = timeComps.second
        return calendar.date(from: merged) ?? newDate
    }

    private static func startOfMonth(for date: Date, firstWeekday: Int) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = firstWeekday
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private static func clamp(_ date: Date, to range: ClosedRange<Date>?) -> Date {
        guard let range = range else { return date }
        if date < range.lowerBound { return range.lowerBound }
        if date > range.upperBound { return range.upperBound }
        return date
    }

    private func rotated<T>(_ array: [T], by offset: Int) -> [T] {
        guard !array.isEmpty else { return array }
        let normalized = ((offset % array.count) + array.count) % array.count
        return Array(array[normalized..<array.count]) + Array(array[0..<normalized])
    }
}
