import XCTest
@testable import KhmerDatePickerDemoApp

final class EdgeCaseFixtureTests: XCTestCase {

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        return cal
    }

    func testLeapDayIsExactlyFeb29_2024() {
        let date = EdgeCasesViewModel.Fixture.leapDay.date()
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(comps.year, 2024)
        XCTAssertEqual(comps.month, 2)
        XCTAssertEqual(comps.day, 29)
    }

    func testEndOfMonthIsJan31_2026() {
        let date = EdgeCasesViewModel.Fixture.endOfMonth.date()
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 31)
    }

    func testEndOfYearHits235959() {
        let date = EdgeCasesViewModel.Fixture.endOfYear.date()
        let comps = calendar.dateComponents([.hour, .minute, .second], from: date)
        XCTAssertEqual(comps.hour, 23)
        XCTAssertEqual(comps.minute, 59)
        XCTAssertEqual(comps.second, 59)
    }

    func testTimeBoundaryUsesProvidedNow() {
        let referenceNow = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 8, minute: 30))!
        let boundary = EdgeCasesViewModel.Fixture.timeBoundary.date(now: referenceNow)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: boundary)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 6)
        XCTAssertEqual(comps.day, 15)
        XCTAssertEqual(comps.hour, 23)
        XCTAssertEqual(comps.minute, 59)
        XCTAssertEqual(comps.second, 59)
    }

    func testMidnightIsStartOfDay() {
        let referenceNow = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 14))!
        let midnight = EdgeCasesViewModel.Fixture.midnight.date(now: referenceNow)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: midnight)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 6)
        XCTAssertEqual(comps.day, 15)
        XCTAssertEqual(comps.hour, 0)
        XCTAssertEqual(comps.minute, 0)
        XCTAssertEqual(comps.second, 0)
    }

    func testAllFixturesProduceUniqueDates() {
        let referenceNow = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 14, minute: 30))!
        let dates = EdgeCasesViewModel.Fixture.allCases.map { $0.date(now: referenceNow) }
        XCTAssertEqual(Set(dates).count, EdgeCasesViewModel.Fixture.allCases.count, "Fixtures must produce distinct dates")
    }
}
