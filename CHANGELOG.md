# Changelog

All notable changes to **KhmerDatePicker** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

_Nothing yet._

---

## [1.0.0] — 2026-04-28

Initial public release.

### Added — public API

- `KhmerDatePickerView` — SwiftUI component with three modes (`.date`, `.time`, `.dateAndTime`) whose initializer mirrors Apple's `DatePicker` shape.
- `in: ClosedRange<Date>?` parameter on the picker to constrain the selectable range. Out-of-range day cells are dimmed and disabled, the prev/next-month chevrons auto-disable when the adjacent month has no overlap, the time wheel clamps any value that would push the selection past the bounds, and the initial `selection` is auto-clamped into range.
- `KhmerDatePickerMode`, `KhmerLocale` (Khmer / English), runtime locale switching via the picker's `locale:` parameter.
- `KhmerDateFormatter` with six built-in styles (`.full`, `.long`, `.medium`, `.short`, `.time`, `.dateTime`) and an overload accepting an explicit `Calendar`.
- `KhmerNumerals` — Arabic ↔ Khmer conversion plus a locale-aware padded `render(_:in:paddedTo:)`.
- `KhmerCalendarSymbols` — months, short months, weekdays full + short, day/month/year/ordinal/hour/minute/second labels.
- `KhmerFont` enum (`.system`, `.kantumruyPro`, `.custom(name:)`) plus a `Font.khmer(_:size:weight:relativeTo:)` resolver and a SwiftUI `.khmerFont(_:)` environment modifier.
- Bundled **Kantumruy Pro** font (Regular + Italic, SIL OFL 1.1) registered with CoreText lazily on first use.
- `KhmerDatePickerInfo.version` constant.

### Added — accessibility & Dynamic Type

- Every day cell exposes a fully-formatted VoiceOver label in the active locale (e.g. *"ថ្ងៃ ច័ន្ទ ទី ១ ខែ មករា ឆ្នាំ ២០២៦"*).
- Selected day cells advertise the `isSelected` accessibility trait; the month/year header is marked as a heading.
- The hour/minute/second wheels each carry an English `accessibilityLabel` so assistive-tech users can identify the column regardless of the visible locale; the visible Khmer/English titles are accessibility-hidden to avoid double-reading.
- `Font.khmer(_:size:)` accepts a `relativeTo: Font.TextStyle?` parameter (default `.body`), so custom Khmer fonts scale with Dynamic Type by default. Pass `relativeTo: nil` to opt out.

### Added — repo & tooling

- `LICENSE` — MIT, copyright Nem Sothea & KOSIGN (Cambodia) Investment Co., Ltd.
- GitHub Actions CI workflow (`.github/workflows/swift.yml`) running `swift build -v` + `swift test -v` on every push and PR.
- 16 unit tests covering numeral conversion, every formatter style for both locales, and font registration.
- SwiftUI demo app under `Examples/KhmerDatePickerDemoApp/` (XcodeGen project with five MVVM screens, locale toggle, font toggle, and a debug log).
- `ScreenshotCaptureUITests` UI test that drives the demo app through 10 states and emits PNGs for the README gallery (gated behind `CAPTURE_SCREENSHOTS=1`).
- README with sponsor block (developed by NEMSOTHEA, sponsored by KOSIGN), installation guide, range/accessibility/font/locale documentation, screenshots gallery, and `Sponsors & contributing` section.
- `docs/screenshots/` — 10 captured PNGs from iPhone 17 / iOS 26.4 plus a contributor `CAPTURE_PLAN.md`.

### Internal

- `KhmerDatePickerViewModel` and its `DayCell` struct are deliberately scoped `internal`. The committed v1.0.0 public surface is: `KhmerDatePickerView`, `KhmerDatePickerMode`, `KhmerLocale`, `KhmerFont`, `KhmerDateFormatter` (+ `Style`), `KhmerNumerals`, `KhmerCalendarSymbols`, `KhmerDatePickerInfo`, plus the `EnvironmentValues.khmerFont` key and the `View.khmerFont(_:)` modifier. The view model is free to be refactored without breaking SemVer.

[Unreleased]: https://github.com/NemSothea/KhmerDatePicker/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/NemSothea/KhmerDatePicker/releases/tag/v1.0.0
