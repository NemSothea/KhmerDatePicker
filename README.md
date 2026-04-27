# KhmerDatePicker

A reusable, **MVVM-clean SwiftUI DatePicker** with full Khmer (ខ្មែរ) localization — Khmer numerals (០–៩), Khmer month names (មករា–ធ្នូ), Khmer weekday names (ច័ន្ទ–អាទិត្យ), and Khmer time labels (ម៉ោង / នាទី / វិនាទី). Switch between Khmer and English at runtime with a single binding.

```
ថ្ងៃ ច័ន្ទ ទី ១ ខែ មករា ឆ្នាំ ២០២៦
```

---

## Features

- SwiftUI component, public API mirrors Apple's `DatePicker`
- Three modes: `.date`, `.time`, `.dateAndTime`
- Khmer ↔ English locale switch at runtime
- Six built-in date format styles (`.full`, `.long`, `.medium`, `.short`, `.time`, `.dateTime`)
- Configurable first-weekday (Sunday or Monday)
- Optional seconds picker
- Pure Foundation + SwiftUI — zero third-party dependencies

## Installation

### Xcode

1. **File → Add Package Dependencies…**
2. Enter the repo URL.
3. Add `KhmerDatePicker` to your app target.

### `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/your-org/KhmerDatePicker.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "KhmerDatePicker", package: "KhmerDatePicker")
        ]
    )
]
```

## Quick start

```swift
import SwiftUI
import KhmerDatePicker

struct MyView: View {
    @State private var date = Date()

    var body: some View {
        KhmerDatePickerView(selection: $date)
    }
}
```

## All three modes

```swift
KhmerDatePickerView(selection: $date, mode: .date)
KhmerDatePickerView(selection: $date, mode: .time, showsSeconds: true)
KhmerDatePickerView(selection: $date, mode: .dateAndTime)
```

## Switching locale at runtime

```swift
@State private var locale: KhmerLocale = .khmer

var body: some View {
    VStack {
        Picker("Locale", selection: $locale) {
            ForEach(KhmerLocale.allCases, id: \.self) { value in
                Text(value.displayName).tag(value)
            }
        }
        .pickerStyle(.segmented)

        KhmerDatePickerView(selection: $date, locale: locale)
    }
}
```

The picker re-renders all weekday/month/numeral text whenever `locale` changes.

## Custom formatting

`KhmerDateFormatter` produces strings independently of the picker view.

```swift
let label = KhmerDateFormatter.string(
    from: date,
    style: .full,
    locale: .khmer
)
// → "ថ្ងៃ ច័ន្ទ ទី ១ ខែ មករា ឆ្នាំ ២០២៦"
```

| Style       | Khmer                                                  | English                          |
|-------------|--------------------------------------------------------|----------------------------------|
| `.full`     | `ថ្ងៃ ច័ន្ទ ទី ១ ខែ មករា ឆ្នាំ ២០២៦`                          | `Monday, January 1, 2026`        |
| `.long`     | `១ មករា ២០២៦`                                            | `1 January 2026`                 |
| `.medium`   | `០១ មករា ២០២៦`                                          | `01 Jan 2026`                    |
| `.short`    | `០១/០១/២០២៦`                                             | `01/01/2026`                     |
| `.time`     | `ម៉ោង ១៤ នាទី ៣០`                                        | `14:30`                          |
| `.dateTime` | `ថ្ងៃ ច័ន្ទ ទី ១ ខែ មករា ឆ្នាំ ២០២៦ ម៉ោង ១៤ នាទី ៣០`                | `Monday, January 1, 2026 14:30`  |

## Numeral conversion

```swift
KhmerNumerals.toKhmer("2026")   // → "២០២៦"
KhmerNumerals.toKhmer(7)        // → "៧"
KhmerNumerals.toArabic("២០២៦")  // → "2026"
KhmerNumerals.render(7, in: .khmer, paddedTo: 2) // → "០៧"
```

## Architecture

```
┌──────────────────────────────────────┐
│  Views (SwiftUI)                     │
│   KhmerDatePickerView (root)         │
│   ├ KhmerMonthYearSelectorView       │
│   ├ KhmerCalendarGridView            │
│   └ KhmerTimePickerView              │
└──────────────────────────────────────┘
                  ▲
                  │ @ObservedObject
                  ▼
┌──────────────────────────────────────┐
│  ViewModel                           │
│   KhmerDatePickerViewModel           │
│    @Published selectedDate / locale  │
│    dayCells, monthLabel, weekdayHdr  │
└──────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────┐
│  Localization (pure values)          │
│   KhmerLocale                        │
│   KhmerNumerals                      │
│   KhmerCalendarSymbols               │
│   KhmerDateFormatter                 │
└──────────────────────────────────────┘
```

Views never compute calendar math — they read derived state from the view model. Localization types are stateless namespaces; `KhmerDateFormatter` is a `struct` with `static func string(from:style:locale:)`.

## Extensibility

### Add a new format style

Add a case to `KhmerDateFormatter.Style`, then handle it in both `khmerString(from:style:)` and `englishString(from:style:)`.

### Add a third locale (e.g. Buddhist Era)

Add a case to `KhmerLocale`, define its `identifier` / `displayName`, and extend the `switch` in `KhmerDateFormatter.string(from:style:locale:)`. `KhmerNumerals.render(_:in:paddedTo:)` and `KhmerCalendarSymbols.month(at:locale:)` likewise switch on the locale — extend them too.

### Custom theme

The picker uses the SwiftUI environment `Color.accentColor` for selected-day fill. Wrap it in `.accentColor(.green)` (or `.tint(...)` on iOS 15+) to recolor.

## Why iOS 14, not iOS 13?

`@StateObject` (iOS 14), `LazyVGrid` (iOS 14), and `.onChange(of:)` (iOS 14) collapse what would otherwise be ~150 lines of manual layout and `ObservableObject` plumbing into idiomatic SwiftUI. iOS 14 is also the practical floor for new SwiftUI apps in 2026 — &lt;1% of active devices are below it. If you really need iOS 13, the localization layer (`KhmerNumerals`, `KhmerCalendarSymbols`, `KhmerDateFormatter`) is iOS 13-clean — fork the views and substitute `@ObservedObject` + manual `HStack` rows.

## Running the example

The `Examples/KhmerDatePickerExample/ContentView.swift` file is a self-contained SwiftUI screen. To try it:

1. Create a new SwiftUI iOS 14+ app in Xcode.
2. **File → Add Package Dependencies…** → add this repo (or a local path).
3. Replace the generated `ContentView.swift` with the file from `Examples/KhmerDatePickerExample/`.
4. Run.

## Tests

```bash
swift test
```

Covers numeral conversion (Arabic ↔ Khmer, padding, mixed strings) and date formatting (every `Style` for both locales).

## License

MIT — replace this section with your project's license before publishing.
