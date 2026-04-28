import XCTest

/// Walks the demo app through 10 specific states and attaches a PNG of each
/// screen to the .xcresult bundle. Extract them with:
///
///   xcrun xcresulttool export attachments \
///     --path <path-to>.xcresult \
///     --output-path /tmp/khmer-shots-export
///
/// Skipped by default so CI runs stay fast. Enable by passing the env var
/// through the simulator with the `SIMCTL_CHILD_` prefix:
///
///   SIMCTL_CHILD_CAPTURE_SCREENSHOTS=1 xcodebuild test \
///     -project KhmerDatePickerDemoApp.xcodeproj \
///     -scheme KhmerDatePickerDemoApp \
///     -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' \
///     -only-testing:KhmerDatePickerDemoAppUITests/ScreenshotCaptureUITests
final class ScreenshotCaptureUITests: XCTestCase {

    private enum Tab: Int { case date = 0, time, formats, edge, debug }

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["CAPTURE_SCREENSHOTS"] == "1",
            "Set SIMCTL_CHILD_CAPTURE_SCREENSHOTS=1 to enable screenshot capture."
        )
        continueAfterFailure = false
    }

    func testCaptureAllScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        // 1 — Date / Khmer (default state)
        tapTab(.date, in: app)
        capture("01-date-km")

        // 2 — Date / English
        tapLocale(.english, in: app)
        capture("02-date-en")

        // 3 — Time / Khmer
        tapTab(.time, in: app)
        tapLocale(.khmer, in: app)
        capture("03-time-km")

        // 4 — Time / English
        tapLocale(.english, in: app)
        capture("04-time-en")

        // 5 — Formats / Khmer (with spec sample applied)
        tapTab(.formats, in: app)
        tapLocale(.khmer, in: app)
        app.buttons["button.specSample"].tap()
        capture("05-formats-km")

        // 6 — Formats / English (spec sample re-applied)
        tapLocale(.english, in: app)
        app.buttons["button.specSample"].tap()
        capture("06-formats-en")

        // 7 — Edge / Khmer (Leap day fixture)
        tapTab(.edge, in: app)
        tapLocale(.khmer, in: app)
        app.buttons["edge.leapDay"].tap()
        capture("07-edge-km")

        // 8 — Edge / English (Leap day still applied)
        tapLocale(.english, in: app)
        capture("08-edge-en")

        // 9 — Debug / Khmer (log auto-populates onAppear)
        tapTab(.debug, in: app)
        tapLocale(.khmer, in: app)
        capture("09-debug-km")

        // 10 — Debug / English
        tapLocale(.english, in: app)
        capture("10-debug-en")
    }

    // MARK: helpers

    private func tapTab(_ tab: Tab, in app: XCUIApplication) {
        let bar = app.tabBars.firstMatch
        XCTAssertTrue(bar.waitForExistence(timeout: 5), "Tab bar never appeared")
        bar.buttons.element(boundBy: tab.rawValue).tap()
    }

    private enum Locale: String { case khmer, english }

    private func tapLocale(_ locale: Locale, in app: XCUIApplication) {
        let chip = app.buttons["locale.\(locale.rawValue)"]
        XCTAssertTrue(chip.waitForExistence(timeout: 3), "locale.\(locale.rawValue) chip not found")
        chip.tap()
    }

    private func capture(_ filename: String) {
        // Let any in-flight animation settle before sampling the screen.
        Thread.sleep(forTimeInterval: 0.45)
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = filename
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
