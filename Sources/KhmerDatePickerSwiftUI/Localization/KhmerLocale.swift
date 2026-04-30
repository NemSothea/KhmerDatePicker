import Foundation

public enum KhmerLocale: String, CaseIterable, Hashable, Sendable {
    case khmer
    case english

    public var identifier: String {
        switch self {
        case .khmer:   return "km_KH"
        case .english: return "en_US"
        }
    }

    public var foundationLocale: Locale {
        Locale(identifier: identifier)
    }

    public var displayName: String {
        switch self {
        case .khmer:   return "ភាសាខ្មែរ"
        case .english: return "English"
        }
    }
}
