import XCTest
@testable import KhmerDatePicker

final class KhmerNumeralsTests: XCTestCase {

    func testToKhmerFromString() {
        XCTAssertEqual(KhmerNumerals.toKhmer("2026"), "២០២៦")
        XCTAssertEqual(KhmerNumerals.toKhmer("0"), "០")
        XCTAssertEqual(KhmerNumerals.toKhmer("0123456789"), "០១២៣៤៥៦៧៨៩")
    }

    func testToKhmerFromInt() {
        XCTAssertEqual(KhmerNumerals.toKhmer(0), "០")
        XCTAssertEqual(KhmerNumerals.toKhmer(2026), "២០២៦")
    }

    func testToKhmerPreservesNonDigits() {
        XCTAssertEqual(KhmerNumerals.toKhmer("Year 2026!"), "Year ២០២៦!")
        XCTAssertEqual(KhmerNumerals.toKhmer("01/12/2026"), "០១/១២/២០២៦")
    }

    func testToArabic() {
        XCTAssertEqual(KhmerNumerals.toArabic("២០២៦"), "2026")
        XCTAssertEqual(KhmerNumerals.toArabic("០១/០១/២០២៦"), "01/01/2026")
    }

    func testRenderRespectsLocale() {
        XCTAssertEqual(KhmerNumerals.render(7, in: .khmer, paddedTo: 2), "០៧")
        XCTAssertEqual(KhmerNumerals.render(7, in: .english, paddedTo: 2), "07")
        XCTAssertEqual(KhmerNumerals.render(2026, in: .khmer), "២០២៦")
        XCTAssertEqual(KhmerNumerals.render(2026, in: .english), "2026")
    }
}
