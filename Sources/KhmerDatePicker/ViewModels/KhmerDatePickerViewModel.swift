import Foundation
import Combine

public final class KhmerDatePickerViewModel: ObservableObject {

    @Published public var selectedDate: Date
    @Published public var displayedMonth: Date
    @Published public var locale: KhmerLocale
    @Published public var mode: KhmerDatePickerMode
    @Published public var showsSeconds: Bool

    public let firstWeekday: Int

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = firstWeekday
        cal.locale = locale.foundationLocale
        return cal
    }

    public init(
        initialDate: Date = Date(),
        locale: KhmerLocale = .khmer,
        mode: KhmerDatePickerMode = .date,
        firstWeekday: Int = 1,
        showsSeconds: Bool = false
    ) {
        self.selectedDate = initialDate
        self.displayedMonth = Self.startOfMonth(for: initialDate, firstWeekday: firstWeekday)
        self.locale = locale
        self.mode = mode
        self.firstWeekday = firstWeekday
        self.showsSeconds = showsSeconds
    }

    // MARK: Header

    public var monthLabel: String {
        let comps = calendar.dateComponents([.month, .year], from: displayedMonth)
        let monthIndex = (comps.month ?? 1) - 1
        let year = comps.year ?? 0
        let monthName = KhmerCalendarSymbols.month(at: monthIndex, locale: locale)
        let yearString = KhmerNumerals.render(year, in: locale)
        return "\(monthName) \(yearString)"
    }

    public var weekdayHeader: [String] {
        let symbols = KhmerCalendarSymbols.weekdaySymbols(short: true, locale: locale)
        return rotated(symbols, by: firstWeekday - 1)
    }

    // MARK: Calendar grid

    public struct DayCell: Identifiable, Hashable {
        public let id: Date
        public let date: Date
        public let dayNumber: Int
        public let label: String
        public let isInDisplayedMonth: Bool
        public let isToday: Bool
        public let isSelected: Bool
    }

    public var dayCells: [DayCell] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        let firstOfMonth = monthInterval.start
        let firstWeekdayIndex = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekdayIndex - calendar.firstWeekday + 7) % 7

        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        var cells: [DayCell] = []
        cells.reserveCapacity(42)

        // Leading days from previous month.
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

        // Current month days.
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                cells.append(makeCell(for: date, dayNumber: day, isInDisplayedMonth: true))
            }
        }

        // Trailing days to fill 6 rows (42 cells) for stable layout.
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
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
        )
    }

    // MARK: Time

    public var hourComponents: [Int] { Array(0...23) }
    public var minuteComponents: [Int] { Array(0...59) }
    public var secondComponents: [Int] { Array(0...59) }

    public var selectedHour: Int {
        get { calendar.component(.hour, from: selectedDate) }
        set { setTime(hour: newValue) }
    }

    public var selectedMinute: Int {
        get { calendar.component(.minute, from: selectedDate) }
        set { setTime(minute: newValue) }
    }

    public var selectedSecond: Int {
        get { calendar.component(.second, from: selectedDate) }
        set { setTime(second: newValue) }
    }

    public func label(forHour hour: Int) -> String {
        KhmerNumerals.render(hour, in: locale, paddedTo: 2)
    }

    public func label(forMinute minute: Int) -> String {
        KhmerNumerals.render(minute, in: locale, paddedTo: 2)
    }

    public func label(forSecond second: Int) -> String {
        KhmerNumerals.render(second, in: locale, paddedTo: 2)
    }

    // MARK: Mutations

    public func selectDate(_ date: Date) {
        selectedDate = mergeTime(into: date)
        if !calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month) {
            displayedMonth = Self.startOfMonth(for: date, firstWeekday: firstWeekday)
        }
    }

    public func goToPreviousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = Self.startOfMonth(for: prev, firstWeekday: firstWeekday)
        }
    }

    public func goToNextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = Self.startOfMonth(for: next, firstWeekday: firstWeekday)
        }
    }

    public func goToToday() {
        let today = Date()
        selectedDate = today
        displayedMonth = Self.startOfMonth(for: today, firstWeekday: firstWeekday)
    }

    public func formatted(style: KhmerDateFormatter.Style) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: style, locale: locale, calendar: calendar)
    }

    public func syncSelection(_ date: Date) {
        guard date != selectedDate else { return }
        selectedDate = date
        if !calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month) {
            displayedMonth = Self.startOfMonth(for: date, firstWeekday: firstWeekday)
        }
    }

    // MARK: Helpers

    private func setTime(hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
        if let hour = hour { comps.hour = hour }
        if let minute = minute { comps.minute = minute }
        if let second = second { comps.second = second }
        if let updated = calendar.date(from: comps) {
            selectedDate = updated
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

    private func rotated<T>(_ array: [T], by offset: Int) -> [T] {
        guard !array.isEmpty else { return array }
        let normalized = ((offset % array.count) + array.count) % array.count
        return Array(array[normalized..<array.count]) + Array(array[0..<normalized])
    }
}
