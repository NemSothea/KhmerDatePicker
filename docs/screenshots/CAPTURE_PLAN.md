# Demo-app screenshot capture plan

> **Status: ✅ completed 2026-04-28.** All 10 PNGs are in `docs/screenshots/` and the README gallery is wired up. Keep this file as a contributor reference for re-capturing screenshots after future UI changes; delete if no longer useful.

Saved 2026-04-27. Target: capture once on a Mac, then update the package README with a small image gallery.

## 1. Open the demo app

```bash
cd /Users/sothea007/Documents/Research/KhmerDatePicker/Examples/KhmerDatePickerDemoApp
xcodegen generate          # only needed if .xcodeproj is missing or stale
open KhmerDatePickerDemoApp.xcodeproj
```

In Xcode pick **iPhone 17** (or any iPhone with iOS 26.x — iPhone 16 is iOS 18.5 only on this machine and won't run the app), then `Cmd-R`.

## 2. Capture each frame

`Cmd-S` in the simulator saves a PNG to `~/Desktop`. Rename and drop into `docs/screenshots/` per the table below.

| # | Tab     | Locale  | Setup                       | Filename                                |
|---|---------|---------|-----------------------------|-----------------------------------------|
| 1 | Date    | Khmer   | default state               | `docs/screenshots/01-date-km.png`       |
| 2 | Date    | English | tap `🇺🇸 English` chip       | `docs/screenshots/02-date-en.png`       |
| 3 | Time    | Khmer   | tap `🇰🇭 ភាសាខ្មែរ`           | `docs/screenshots/03-time-km.png`       |
| 4 | Time    | English | tap `🇺🇸 English`            | `docs/screenshots/04-time-en.png`       |
| 5 | Formats | Khmer   | tap **Spec sample** button  | `docs/screenshots/05-formats-km.png`    |
| 6 | Formats | English | flip locale, Spec sample    | `docs/screenshots/06-formats-en.png`    |
| 7 | Edge    | Khmer   | tap **Leap day** fixture    | `docs/screenshots/07-edge-km.png`       |
| 8 | Edge    | English | flip locale                 | `docs/screenshots/08-edge-en.png`       |
| 9 | Debug   | Khmer   | scroll a bit so log shows   | `docs/screenshots/09-debug-km.png`      |
| 10| Debug   | English | flip locale                 | `docs/screenshots/10-debug-en.png`      |

## 3. Update the package README

Replace the screenshot-placeholder line in `/README.md` with a 2-column gallery:

```markdown
## Screenshots

| Khmer | English |
|---|---|
| ![Date](docs/screenshots/01-date-km.png) | ![Date](docs/screenshots/02-date-en.png) |
| ![Time](docs/screenshots/03-time-km.png) | ![Time](docs/screenshots/04-time-en.png) |
| ![Formats](docs/screenshots/05-formats-km.png) | ![Formats](docs/screenshots/06-formats-en.png) |
| ![Edge cases](docs/screenshots/07-edge-km.png) | ![Edge cases](docs/screenshots/08-edge-en.png) |
| ![Debug](docs/screenshots/09-debug-km.png) | ![Debug](docs/screenshots/10-debug-en.png) |
```

(Or ask Claude to generate it once the PNGs are in place — "screenshots are captured, write the README gallery".)

## 4. Commit and push

```bash
git add docs/screenshots/ README.md
git commit -m "docs: add demo-app screenshots to README"
git push origin main
```

## Notes

- Don't include the simulator status bar in the screenshot if you can avoid it — `xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100` cleans it up before capture.
- Optional: tap each tab once to warm up the simulator before capturing — first render of the calendar grid can show a brief layout flash.
- This file (`CAPTURE_PLAN.md`) is not load-bearing — feel free to delete after the README is updated, or keep it as contributor documentation.
