# KhmerDatePickerDemoApp

A SwiftUI demo / QA harness for the **KhmerDatePicker** Swift Package. Validates every public surface of the package — date mode, time mode, runtime locale switching, all six format styles, and a curated set of edge cases — and ships with a debug panel that exposes the raw `Date`, the Khmer-numeral conversion, and a live formatter log.

> **Platform:** iOS 14+ (the package's minimum). The package relies on `@StateObject` and `LazyVGrid`, so the demo app's deployment target matches.

---

## 1. Folder structure

```
Examples/KhmerDatePickerDemoApp/
├── project.yml                              ← XcodeGen project definition
├── README.md                                ← you are here
├── KhmerDatePickerDemoApp/
│   ├── KhmerDatePickerDemoApp.swift         ← @main app entry
│   ├── App/
│   │   ├── RootView.swift                   ← TabView with the five screens
│   │   └── AppEnvironment.swift             ← shared @ObservedObject (locale, log)
│   ├── Components/
│   │   ├── LocaleToggle.swift               ← Khmer / English flag toggle
│   │   └── SectionCard.swift                ← reusable titled card
│   ├── Features/
│   │   ├── DatePicker/
│   │   │   ├── DatePickerScreen.swift
│   │   │   └── DatePickerViewModel.swift
│   │   ├── TimePicker/
│   │   │   ├── TimePickerScreen.swift
│   │   │   └── TimePickerViewModel.swift
│   │   ├── FormatPreview/
│   │   │   ├── FormatPreviewScreen.swift
│   │   │   └── FormatPreviewViewModel.swift
│   │   ├── EdgeCases/
│   │   │   ├── EdgeCasesScreen.swift
│   │   │   └── EdgeCasesViewModel.swift
│   │   └── Debug/
│   │       ├── DebugScreen.swift
│   │       └── DebugViewModel.swift
│   └── Generated/                           ← XcodeGen-managed Info.plist
├── KhmerDatePickerDemoAppTests/
│   ├── KhmerFormatterIntegrationTests.swift
│   ├── EdgeCaseFixtureTests.swift
│   └── ViewModelTests.swift
└── KhmerDatePickerDemoAppUITests/
    ├── DemoAppUITests.swift
    └── UITestSuggestions.md
```

Each feature folder is a self-contained MVVM unit: one screen + one view model. The view models are `ObservableObject` subclasses with `@Published` state and own all formatting / fixture logic. Views are pure projections.

---

## 2. SPM integration

The package is referenced **locally** from the parent directory:

```yaml
# project.yml
packages:
  KhmerDatePicker:
    path: "../.."
```

After regenerating the project with XcodeGen, Xcode picks this up as a local package. Editing files under `Sources/KhmerDatePicker/` and re-running the demo app reflects changes immediately — no version bump or Git tag required.

If you'd rather not use XcodeGen (see §3), add the package manually in Xcode:

> File ▸ Add Package Dependencies… ▸ Add Local… ▸ pick the `KhmerDatePicker` repo root ▸ add the `KhmerDatePicker` library to the demo target.

---

## 3. Setup

### Option A — XcodeGen (recommended)

```bash
brew install xcodegen        # one-time
cd Examples/KhmerDatePickerDemoApp
xcodegen generate
open KhmerDatePickerDemoApp.xcodeproj
```

`KhmerDatePickerDemoApp.xcodeproj` is generated, never checked in. Re-run `xcodegen generate` any time you add or remove files.

### Option B — manual Xcode

1. **File ▸ New ▸ Project ▸ App** (iOS, SwiftUI, Swift). Save it to `Examples/KhmerDatePickerDemoApp/` so the relative package path resolves.
2. Set the deployment target to **iOS 14.0**.
3. Delete the auto-generated `ContentView.swift` and the default `*App.swift`.
4. Drag the `KhmerDatePickerDemoApp/` source folder (everything except `Generated/`) into the project navigator — choose **"Create groups"**, target = the app.
5. Drag `KhmerDatePickerDemoAppTests/` and `KhmerDatePickerDemoAppUITests/` into their matching test bundles.
6. **File ▸ Add Package Dependencies… ▸ Add Local…** and pick the repo root (`../..`). Add the `KhmerDatePicker` library to the app target.
7. Cmd-R. Done.

---

## 4. Screens

| Tab        | What it tests                                                                                          |
|------------|--------------------------------------------------------------------------------------------------------|
| **Date**   | `KhmerDatePickerView(.date)` + every `KhmerDateFormatter.Style` rendered in both locales side-by-side. |
| **Time**   | `.time` mode with optional seconds; Khmer time labels (`ម៉ោង / នាទី / វិនាទី`); component breakdown.    |
| **Formats**| `.dateAndTime` mode + all six styles in both locales (spec sample = Thu Jan 1 2026 14:30 in Asia/Phnom_Penh). |
| **Edge**   | One-tap fixtures: leap day, end-of-month, end-of-year, time-boundary 23:59:59, midnight, today.        |
| **Debug**  | Raw `Date` (epoch + ISO-8601), Khmer-numeral component breakdown, append-only formatter log.           |

The **Locale toggle** lives at the top of every screen and writes to a single `AppEnvironment.locale` — flipping it rerenders every screen at once, which is the whole point of the runtime-switching test.

---

## 5. Sample data / preview

`EdgeCasesViewModel.Fixture` enumerates the canonical test dates so they can be reused from SwiftUI previews and from `XCTestCase`:

```swift
EdgeCasesViewModel.Fixture.leapDay.date       // 2024-02-29 12:00 (Asia/Phnom_Penh)
EdgeCasesViewModel.Fixture.endOfYear.date     // 2026-12-31 23:59:59
EdgeCasesViewModel.Fixture.timeBoundary.date  // today @ 23:59:59
```

Every screen ships with a `#Preview`-style `PreviewProvider` so you can inspect both locales in the canvas without launching the simulator.

---

## 6. Testing checklist

### Unit tests (`KhmerDatePickerDemoAppTests`)

- [ ] `KhmerFormatterIntegrationTests` — every `Style × Locale` combo for the canonical Jan 1 2026 14:30 fixture matches the spec table.
- [ ] `KhmerFormatterIntegrationTests.testNoArabicDigitsLeakIntoKhmerOutput` — `.short` style on a single-digit day pads in Khmer, never `0` ASCII.
- [ ] `KhmerFormatterIntegrationTests.testLeapDayRoundTrip` — Feb 29 2024 → `២៩ កុម្ភៈ ២០២៤` and back.
- [ ] `EdgeCaseFixtureTests` — every fixture date matches its declared components; `endOfYear` is exactly `23:59:59`.
- [ ] `ViewModelTests.testLocaleSwitchUpdatesFormatter` — flipping locale on `DatePickerViewModel` produces a different output for the same `Date`.
- [ ] `ViewModelTests.testEdgeCaseSelection` — applying a fixture mutates `selectedDate` to the expected instant.
- [ ] `ViewModelTests.testDebugLogAccumulates` — `DebugViewModel.recordSnapshot` appends and respects the cap.

### UI smoke tests (`KhmerDatePickerDemoAppUITests`)

- [ ] App launches and all five tabs are reachable.
- [ ] Locale toggle flips the title between `ប្រតិទិន` and `Date Picker`.
- [ ] Tapping a day cell on the calendar updates the formatted output below.
- [ ] Edge-case "Leap day" button changes the displayed Khmer date string.

### Manual QA (visual)

- [ ] All six format styles render the Khmer-spec strings on Jan 1 2026.
- [ ] Calendar grid never shows ASCII digits in Khmer mode.
- [ ] Time picker wheels show `ម៉ោង / នាទី / វិនាទី` headers in Khmer mode and `Hour / Minute / Second` in English.
- [ ] Locale switch is instant — no re-mounting flash.
- [ ] Dark mode is legible (system colors only — no hard-coded backgrounds).

See `KhmerDatePickerDemoAppUITests/UITestSuggestions.md` for the longer UI test plan (gestures, snapshot diffs, accessibility audit).

---

## 7. Architecture notes

- **One `AppEnvironment`** at the root, injected via `.environmentObject(...)`. Every screen reads `environment.locale` and writes through it — so the locale toggle is global, not per-screen.
- **No singletons in view models.** Each VM is `@StateObject`-owned by its screen so previews get fresh state.
- **Bindings flow into `KhmerDatePickerView`** as `Binding<Date>` from the view model's `@Published var selectedDate`. The package's `.onChange(of: selection)` handles two-way sync.
- **No third-party dependencies.** Foundation + SwiftUI + the local `KhmerDatePicker` package only.
