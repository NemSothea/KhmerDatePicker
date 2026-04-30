import Foundation

public enum KhmerDatePickerMode: Hashable, CaseIterable, Sendable {
    case date
    case time
    case dateAndTime

    public var showsCalendar: Bool {
        self == .date || self == .dateAndTime
    }

    public var showsTime: Bool {
        self == .time || self == .dateAndTime
    }
}
