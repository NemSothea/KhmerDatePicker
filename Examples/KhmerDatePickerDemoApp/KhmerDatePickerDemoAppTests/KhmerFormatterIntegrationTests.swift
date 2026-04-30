import XCTest
import KhmerDatePickerSwiftUI
@testable import KhmerDatePickerDemoApp

/// Integration tests at the app level that exercise the formatter through the
/// view model surface (so we catch wiring regressions, not just package logic).
/// The package itself has its own focused unit tests under `Tests/`.
final class KhmerFormatterIntegrationTests: XCTestCase {

    // MARK: Spec sample — Thu, Jan 1 2026 14:30 in Asia/Phnom_Penh
    //
    // Note: The original SKILL.md draft listed this date as a Monday, but
    // Jan 1 2026 is actually a Thursday (ព្រហស្បតិ៍). The package's own
    // tests in KhmerDateFormatterTests already encode the correct weekday;
    // we match that here.

    private var specDate: Date {
        FormatPreviewViewModel.specSampleDate()
    }

    func testKhmerFullStyleMatchesSpec() {
        let output = KhmerDateFormatter.string(from: specDate, style: .full, locale: .khmer)
        XCTAssertEqual(output, "ថ្ងៃ ព្រហស្បតិ៍ ទី ១ ខែ មករា ឆ្នាំ ២០២៦")
    }

    func testEnglishFullStyleMatchesSpec() {
        let output = KhmerDateFormatter.string(from: specDate, style: .full, locale: .english)
        XCTAssertEqual(output, "Thursday, January 1, 2026")
    }

    func testKhmerLongStyle() {
        let output = KhmerDateFormatter.string(from: specDate, style: .long, locale: .khmer)
        XCTAssertEqual(output, "១ មករា ២០២៦")
    }

    func testKhmerMediumStyleHasKhmerLeadingZero() {
        let output = KhmerDateFormatter.string(from: specDate, style: .medium, locale: .khmer)
        XCTAssertEqual(output, "០១ មករា ២០២៦")
    }

    func testKhmerShortStyleUsesKhmerNumeralsOnly() {
        let output = KhmerDateFormatter.string(from: specDate, style: .short, locale: .khmer)
        XCTAssertEqual(output, "០១/០១/២០២៦")

        // Defensive: not a single ASCII digit must have leaked through.
        for digit in "0123456789" {
            XCTAssertFalse(output.contains(digit), "Khmer .short output leaked Arabic digit \(digit)")
        }
    }

    func testEnglishShortStyle() {
        let output = KhmerDateFormatter.string(from: specDate, style: .short, locale: .english)
        XCTAssertEqual(output, "01/01/2026")
    }

    func testKhmerTimeStyle() {
        let output = KhmerDateFormatter.string(from: specDate, style: .time, locale: .khmer)
        XCTAssertEqual(output, "ម៉ោង ១៤ នាទី ៣០")
    }

    func testEnglishTimeStyle() {
        let output = KhmerDateFormatter.string(from: specDate, style: .time, locale: .english)
        XCTAssertEqual(output, "14:30")
    }

    func testKhmerDateTimeStyle() {
        let output = KhmerDateFormatter.string(from: specDate, style: .dateTime, locale: .khmer)
        XCTAssertEqual(output, "ថ្ងៃ ព្រហស្បតិ៍ ទី ១ ខែ មករា ឆ្នាំ ២០២៦ ម៉ោង ១៤ នាទី ៣០")
    }

    // MARK: Edge dates

    func testLeapDayFormatsCleanly() {
        let leap = EdgeCasesViewModel.Fixture.leapDay.date()
        let khmer = KhmerDateFormatter.string(from: leap, style: .long, locale: .khmer)
        XCTAssertEqual(khmer, "២៩ កុម្ភៈ ២០២៤")

        let english = KhmerDateFormatter.string(from: leap, style: .long, locale: .english)
        XCTAssertEqual(english, "29 February 2024")
    }

    func testEndOfYearKhmerShortRendersAllNines() {
        let endOfYear = EdgeCasesViewModel.Fixture.endOfYear.date()
        let output = KhmerDateFormatter.string(from: endOfYear, style: .short, locale: .khmer)
        XCTAssertEqual(output, "៣១/១២/២០២៦")
    }

    func testTimeBoundaryNeverRollsToNextDay() {
        let boundary = EdgeCasesViewModel.Fixture.endOfYear.date()
        let cal = Calendar(identifier: .gregorian)
        var calKH = cal
        calKH.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        let comps = calKH.dateComponents([.year, .month, .day, .hour, .minute, .second], from: boundary)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 12)
        XCTAssertEqual(comps.day, 31)
        XCTAssertEqual(comps.hour, 23)
        XCTAssertEqual(comps.minute, 59)
        XCTAssertEqual(comps.second, 59)
    }

    // MARK: Locale switching

    func testLocaleSwitchProducesDifferentOutputForSameDate() {
        let date = specDate
        let km = KhmerDateFormatter.string(from: date, style: .full, locale: .khmer)
        let en = KhmerDateFormatter.string(from: date, style: .full, locale: .english)
        XCTAssertNotEqual(km, en)
        XCTAssertTrue(km.contains("ខែ"))
        XCTAssertTrue(en.contains("January"))
    }

    // MARK: Round-trip Khmer numerals

    func testKhmerNumeralsRoundTrip() {
        let arabic = "2026-12-31 23:59:59"
        let khmer = KhmerNumerals.toKhmer(arabic)
        XCTAssertEqual(khmer, "២០២៦-១២-៣១ ២៣:៥៩:៥៩")
        XCTAssertEqual(KhmerNumerals.toArabic(khmer), arabic)
    }
}
