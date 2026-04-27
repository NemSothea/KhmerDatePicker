import Foundation
import KhmerDatePicker

/// Shared, app-wide state. Injected at the root via `.environmentObject` so every
/// screen reads from (and writes to) a single source of truth — the locale toggle
/// in any tab flips the entire app.
final class AppEnvironment: ObservableObject {

    @Published var locale: KhmerLocale
    @Published var firstWeekday: Int
    @Published var formatterLog: [LogEntry]

    /// Hard cap on the in-memory log so the Debug tab can't grow without bound.
    static let logLimit = 200

    init(
        locale: KhmerLocale = .khmer,
        firstWeekday: Int = 1
    ) {
        self.locale = locale
        self.firstWeekday = firstWeekday
        self.formatterLog = []
    }

    func toggleLocale() {
        locale = (locale == .khmer) ? .english : .khmer
    }

    func appendLog(_ entry: LogEntry) {
        formatterLog.insert(entry, at: 0)
        if formatterLog.count > Self.logLimit {
            formatterLog = Array(formatterLog.prefix(Self.logLimit))
        }
    }

    func clearLog() {
        formatterLog.removeAll()
    }

    struct LogEntry: Identifiable, Hashable {
        let id = UUID()
        let timestamp: Date
        let khmer: String
        let english: String
    }
}
