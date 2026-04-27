import XCTest

final class DemoAppUITests: XCTestCase {

    /// SwiftUI's `.accessibilityIdentifier` on `.tabItem` does not propagate to
    /// the underlying `UITabBar` buttons, so we look them up by their tab-bar
    /// index instead. The order matches `RootView`: 0=Date 1=Time 2=Formats
    /// 3=Edge 4=Debug.
    private enum Tab: Int {
        case date = 0, time, formats, edge, debug
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    private func tapTab(_ tab: Tab, in app: XCUIApplication) {
        let bar = app.tabBars.firstMatch
        XCTAssertTrue(bar.waitForExistence(timeout: 5), "Tab bar never appeared")
        let button = bar.buttons.element(boundBy: tab.rawValue)
        XCTAssertTrue(button.exists, "Tab #\(tab.rawValue) was not present")
        button.tap()
    }

    // MARK: Tests

    func testAppLaunchesAndAllTabsAreReachable() throws {
        let app = launchApp()
        for tab in [Tab.date, .time, .formats, .edge, .debug] {
            tapTab(tab, in: app)
        }
    }

    func testLocaleToggleFlipsToEnglishAndBack() throws {
        let app = launchApp()
        tapTab(.date, in: app)

        let englishChip = app.buttons["locale.english"]
        XCTAssertTrue(englishChip.waitForExistence(timeout: 3), "English chip should be visible")
        englishChip.tap()

        // The English .full card always contains "2026" (the year) but never the
        // Khmer year "២០២៦" — and vice versa. This is locale-stable and date-agnostic.
        let englishFull = app.staticTexts["format.english.full"]
        XCTAssertTrue(englishFull.waitForExistence(timeout: 3))
        XCTAssertTrue(englishFull.label.contains("2026"), "English .full should have Arabic year, got: \(englishFull.label)")
        XCTAssertFalse(englishFull.label.contains("២"), "English .full must not leak Khmer digits")

        app.buttons["locale.khmer"].tap()

        let khmerFull = app.staticTexts["format.khmer.full"]
        XCTAssertTrue(khmerFull.waitForExistence(timeout: 3))
        XCTAssertTrue(khmerFull.label.contains("២០២៦"), "Khmer .full should have Khmer year, got: \(khmerFull.label)")
    }

    func testEdgeCaseLeapDayUpdatesOutput() throws {
        let app = launchApp()
        tapTab(.edge, in: app)
        app.buttons["locale.english"].tap()
        app.buttons["edge.leapDay"].tap()

        let englishOutput = app.staticTexts["edge.english.full"]
        XCTAssertTrue(englishOutput.waitForExistence(timeout: 3))
        XCTAssertTrue(englishOutput.label.contains("February"))
        XCTAssertTrue(englishOutput.label.contains("2024"))
    }

    func testDebugTabRendersPicker() throws {
        let app = launchApp()
        tapTab(.debug, in: app)

        // The epoch row is a stable, leaf-level static text that proves the
        // Debug tab's content view (and therefore the picker above it) mounted.
        let epoch = app.staticTexts["debug.epoch"]
        XCTAssertTrue(epoch.waitForExistence(timeout: 5), "Debug tab should expose the epoch row")

        // The component breakdown should expose all seven calendar fields.
        XCTAssertTrue(app.staticTexts["debug.iso"].exists)
        XCTAssertTrue(app.staticTexts["debug.description"].exists)
    }

    func testFormatPreviewSpecSampleButtonResetsDate() throws {
        let app = launchApp()
        tapTab(.formats, in: app)
        app.buttons["locale.khmer"].tap()
        app.buttons["button.specSample"].tap()

        let fullKhmer = app.staticTexts["preview.khmer.full"]
        XCTAssertTrue(fullKhmer.waitForExistence(timeout: 3))
        XCTAssertEqual(fullKhmer.label, "ថ្ងៃ ព្រហស្បតិ៍ ទី ១ ខែ មករា ឆ្នាំ ២០២៦")
    }
}
