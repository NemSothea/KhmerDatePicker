# UI Test Plan — Suggestions

The smoke tests in `DemoAppUITests.swift` cover launch, tab routing, locale toggle, and one edge-case fixture. The suggestions below extend coverage in directions that are valuable but more brittle and/or device-dependent — adopt them as the package matures.

## 1. Calendar interaction

- **Tap-to-select**: locate a day cell (`accessibilityIdentifier("calendar.day.<yyyy-MM-dd>")` if you add it on `KhmerCalendarGridView`) and assert the formatted output below updates.
- **Swipe between months**: simulate swipe left/right on the calendar and assert the month-year header changes by exactly one month.
- **First-weekday rotation**: launch with a launch argument (`-firstWeekday 2`) that flips `AppEnvironment.firstWeekday`; assert the leftmost weekday header reads `ច័ន្ទ` in Khmer mode.

## 2. Time picker

- **Wheel scroll**: rotate the hour wheel to `23` and the minute wheel to `59`; assert `time.khmer` reads `ម៉ោង ២៣ នាទី ៥៩`.
- **Seconds toggle**: flip `toggle.showsSeconds`, scroll the seconds wheel, assert `comp.second` updates.

## 3. Locale switching mid-edit

- Edit the time, flip locale, and assert the wheels redraw with Khmer numerals without resetting the selection.
- Repeat under VoiceOver to confirm spoken values switch language.

## 4. Edge cases

For each `EdgeCasesViewModel.Fixture`:
- Tap the fixture button.
- Snapshot `picker.edge` (e.g. via `swift-snapshot-testing`).
- Compare against a baseline image in both locales.

## 5. Accessibility

- **VoiceOver**: rotate through the calendar grid; verify each cell announces "ថ្ងៃ ទី ១ ខែ មករា" (Khmer) or "Monday January 1" (English).
- **Dynamic Type**: launch with the largest accessibility text size; assert no clipping in the format-preview cards.
- **Dark mode**: launch with `UIInterfaceStyle = Dark`; assert background contrast is acceptable (no hard-coded white backgrounds).

## 6. Performance

- Measure `XCTOSSignpostMetric.applicationLaunch` to keep cold-start under 800 ms on iPhone 12-class devices.
- Add an `XCTMetric.memory` assertion around scrolling a year of months to keep heap growth bounded.

## 7. Snapshot regression

A small `swift-snapshot-testing` setup against:
- Each tab × each locale (10 images).
- Calendar at the spec date (Jan 1 2026).
- Time picker at `23:59:59`.
- Edge tab with `endOfYear` selected.

Total ≈ 14 reference images; rerun whenever the package's view files change.

## 8. Device matrix

Beyond the iPhone 15 simulator default, validate on:
- iPhone SE (3rd gen) — narrowest layout.
- iPad (10th gen) — verify `StackNavigationViewStyle` keeps the picker single-column.
- Mac Catalyst — confirm Khmer fonts render correctly under macOS.

## Local CI tip

Add a `Fastlane` lane that runs the unit tests on every commit and the UI smoke tests on PRs only — the UI suite is slow enough that you don't want it in the inner loop.
