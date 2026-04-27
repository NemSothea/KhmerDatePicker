import XCTest
import KhmerDatePicker
@testable import KhmerDatePickerDemoApp

final class ViewModelTests: XCTestCase {

    // MARK: AppEnvironment

    func testEnvironmentToggleFlipsLocale() {
        let env = AppEnvironment(locale: .khmer)
        env.toggleLocale()
        XCTAssertEqual(env.locale, .english)
        env.toggleLocale()
        XCTAssertEqual(env.locale, .khmer)
    }

    func testEnvironmentLogIsCappedAtLimit() {
        let env = AppEnvironment()
        for i in 0..<(AppEnvironment.logLimit + 50) {
            env.appendLog(.init(timestamp: Date(), khmer: "k\(i)", english: "e\(i)"))
        }
        XCTAssertEqual(env.formatterLog.count, AppEnvironment.logLimit)
    }

    func testEnvironmentLogClears() {
        let env = AppEnvironment()
        env.appendLog(.init(timestamp: Date(), khmer: "k", english: "e"))
        XCTAssertFalse(env.formatterLog.isEmpty)
        env.clearLog()
        XCTAssertTrue(env.formatterLog.isEmpty)
    }

    // MARK: DatePickerViewModel

    func testDatePickerViewModelEmitsAllSixStyles() {
        let vm = DatePickerViewModel(initialDate: FormatPreviewViewModel.specSampleDate())
        XCTAssertEqual(vm.allStyles.count, 6)
        for entry in vm.allStyles {
            let km = vm.formatted(in: .khmer, style: entry.style)
            let en = vm.formatted(in: .english, style: entry.style)
            XCTAssertFalse(km.isEmpty, "Khmer \(entry.label) was empty")
            XCTAssertFalse(en.isEmpty, "English \(entry.label) was empty")
            XCTAssertNotEqual(km, en, "Locales should differ for \(entry.label)")
        }
    }

    // MARK: TimePickerViewModel

    func testTimePickerViewModelExposesAllComponents() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        let date = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 14, minute: 30, second: 45))!
        let vm = TimePickerViewModel(initialDate: date)
        let comps = vm.components()
        XCTAssertEqual(comps.hour, 14)
        XCTAssertEqual(comps.minute, 30)
        XCTAssertEqual(comps.second, 45)
        XCTAssertEqual(vm.renderedComponent(comps.hour, in: .khmer), "១៤")
        XCTAssertEqual(vm.renderedComponent(comps.minute, in: .english), "30")
    }

    // MARK: FormatPreviewViewModel

    func testFormatPreviewSpecSampleIsStable() {
        let date = FormatPreviewViewModel.specSampleDate()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 1)
        XCTAssertEqual(comps.hour, 14)
        XCTAssertEqual(comps.minute, 30)
        XCTAssertEqual(comps.weekday, 5) // Thursday — Jan 1 2026 is a Thursday in the Gregorian calendar
    }

    // MARK: EdgeCasesViewModel

    func testEdgeCasesApplySetsSelection() {
        let vm = EdgeCasesViewModel(initialDate: Date())
        vm.apply(.leapDay)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        let comps = cal.dateComponents([.year, .month, .day], from: vm.selectedDate)
        XCTAssertEqual(comps.year, 2024)
        XCTAssertEqual(comps.month, 2)
        XCTAssertEqual(comps.day, 29)
    }

    // MARK: DebugViewModel

    func testDebugViewModelExposesEpochAndIso() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        let date = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 14, minute: 30))!
        let vm = DebugViewModel(initialDate: date)
        XCTAssertFalse(vm.epochSeconds.isEmpty)
        XCTAssertTrue(vm.iso8601.contains("2026"))
        XCTAssertEqual(vm.components().count, 7)
    }

    func testDebugSnapshotPairsKhmerAndEnglish() {
        let date = FormatPreviewViewModel.specSampleDate()
        let vm = DebugViewModel(initialDate: date)
        let snapshot = vm.snapshot()
        XCTAssertEqual(snapshot.khmer, "ថ្ងៃ ព្រហស្បតិ៍ ទី ១ ខែ មករា ឆ្នាំ ២០២៦ ម៉ោង ១៤ នាទី ៣០")
        XCTAssertEqual(snapshot.english, "Thursday, January 1, 2026 14:30")
    }
}
