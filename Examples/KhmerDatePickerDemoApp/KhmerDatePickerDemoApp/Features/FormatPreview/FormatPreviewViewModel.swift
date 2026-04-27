import Foundation
import KhmerDatePicker

final class FormatPreviewViewModel: ObservableObject {

    @Published var selectedDate: Date

    init(initialDate: Date = FormatPreviewViewModel.specSampleDate()) {
        self.selectedDate = initialDate
    }

    /// The reference fixture from the package skill: Mon, Jan 1 2026 14:30 in
    /// Asia/Phnom_Penh. Pinning this means anyone opening the demo for the first
    /// time sees the exact strings the spec table promises.
    static func specSampleDate() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Phnom_Penh") ?? .current
        return cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 14, minute: 30)) ?? Date()
    }

    func resetToSpecSample() {
        selectedDate = Self.specSampleDate()
    }

    func format(_ style: KhmerDateFormatter.Style, in locale: KhmerLocale) -> String {
        KhmerDateFormatter.string(from: selectedDate, style: style, locale: locale)
    }

    let styles: [KhmerDateFormatter.Style] = [.full, .long, .medium, .short, .time, .dateTime]

    func styleLabel(_ style: KhmerDateFormatter.Style) -> String {
        switch style {
        case .full:     return ".full"
        case .long:     return ".long"
        case .medium:   return ".medium"
        case .short:    return ".short"
        case .time:     return ".time"
        case .dateTime: return ".dateTime"
        }
    }
}
