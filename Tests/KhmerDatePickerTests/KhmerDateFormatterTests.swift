import XCTest
@testable import KhmerDatePicker

final class KhmerDateFormatterTests: XCTestCase {

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        return cal.date(from: comps)!
    }

    func testKhmerFullStyleForJanuaryFirst2026() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 14, minute: 30)
        let result = KhmerDateFormatter.string(from: date, style: .full, locale: .khmer)
        XCTAssertEqual(result, "ថ្ងៃ ព្រហស្បតិ៍ ទី ១ ខែ មករា ឆ្នាំ ២០២៦")
    }

    func testKhmerLongStyle() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 0, minute: 0)
        XCTAssertEqual(
            KhmerDateFormatter.string(from: date, style: .long, locale: .khmer),
            "១ មករា ២០២៦"
        )
    }

    func testKhmerMediumStyle() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 0, minute: 0)
        XCTAssertEqual(
            KhmerDateFormatter.string(from: date, style: .medium, locale: .khmer),
            "០១ មករា ២០២៦"
        )
    }

    func testKhmerShortStyle() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 0, minute: 0)
        XCTAssertEqual(
            KhmerDateFormatter.string(from: date, style: .short, locale: .khmer),
            "០១/០១/២០២៦"
        )
    }

    func testKhmerTimeStyle() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 14, minute: 30)
        XCTAssertEqual(
            KhmerDateFormatter.string(from: date, style: .time, locale: .khmer),
            "ម៉ោង ១៤ នាទី ៣០"
        )
    }

    func testEnglishShortStyle() {
        let date = makeDate(year: 2026, month: 1, day: 1, hour: 0, minute: 0)
        XCTAssertEqual(
            KhmerDateFormatter.string(from: date, style: .short, locale: .english),
            "01/01/2026"
        )
    }

    func testWeekdayHeaderRotationForMondayFirst() {
        let symbols = KhmerCalendarSymbols.weekdaySymbols(short: false, locale: .khmer)
        // Sun-first storage: index 0 = អាទិត្យ (Sunday).
        XCTAssertEqual(symbols.first, "អាទិត្យ")
        XCTAssertEqual(symbols[1], "ច័ន្ទ")
    }

    func testMonthNamesMatchSpec() {
        XCTAssertEqual(KhmerCalendarSymbols.months, [
            "មករា", "កុម្ភៈ", "មីនា", "មេសា", "ឧសភា", "មិថុនា",
            "កក្កដា", "សីហា", "កញ្ញា", "តុលា", "វិច្ឆិកា", "ធ្នូ"
        ])
    }
}
