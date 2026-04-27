import Foundation

public enum KhmerNumerals {
    private static let arabicToKhmer: [Character: Character] = [
        "0": "០", "1": "១", "2": "២", "3": "៣", "4": "៤",
        "5": "៥", "6": "៦", "7": "៧", "8": "៨", "9": "៩"
    ]

    private static let khmerToArabic: [Character: Character] = {
        var map: [Character: Character] = [:]
        for (k, v) in arabicToKhmer { map[v] = k }
        return map
    }()

    public static func toKhmer(_ string: String) -> String {
        String(string.map { arabicToKhmer[$0] ?? $0 })
    }

    public static func toKhmer(_ number: Int) -> String {
        toKhmer(String(number))
    }

    public static func toArabic(_ string: String) -> String {
        String(string.map { khmerToArabic[$0] ?? $0 })
    }

    public static func render(_ number: Int, in locale: KhmerLocale, paddedTo width: Int = 0) -> String {
        let padded = String(format: "%0\(width)d", number)
        switch locale {
        case .khmer:   return toKhmer(padded)
        case .english: return padded
        }
    }
}
