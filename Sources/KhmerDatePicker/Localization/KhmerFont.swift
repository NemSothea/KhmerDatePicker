import SwiftUI
#if canImport(CoreText)
import CoreText
#endif

/// Font family used for Khmer text rendered by `KhmerDatePickerView`.
///
/// Apply via the `.khmerFont(_:)` view modifier:
///
///     KhmerDatePickerView(selection: $date)
///         .khmerFont(.kantumruyPro)
public enum KhmerFont: Hashable, Sendable {
    /// System font. On iOS this resolves to `Khmer Sangam MN` for Khmer glyphs.
    case system

    /// Kantumruy Pro — bundled with the package (SIL OFL 1.1).
    /// Modern UI font designed for screen reading, with clean Khmer numerals.
    case kantumruyPro

    /// A custom font registered by the host app. Pass the PostScript name.
    case custom(name: String)

    /// PostScript name passed to `Font.custom(_:size:)`, or `nil` for `.system`.
    public var postScriptName: String? {
        switch self {
        case .system:           return nil
        case .kantumruyPro:     return "KantumruyPro-Regular"
        case .custom(let name): return name
        }
    }
}

public extension Font {
    /// Resolve a `Font` for the given Khmer family at the given size and weight.
    ///
    /// Falls back to the system font when `family == .system` or when the named
    /// font is not registered with CoreText.
    ///
    /// `relativeTo` ties the font to a Dynamic Type text style so that custom
    /// Khmer fonts scale with the user's preferred content size. Pass `nil` to
    /// opt out and use a fixed size.
    static func khmer(
        _ family: KhmerFont,
        size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: Font.TextStyle? = .body
    ) -> Font {
        guard let name = family.postScriptName else {
            return .system(size: size, weight: weight)
        }
        KhmerFontRegistrar.registerBundledFontsIfNeeded()
        if let textStyle = textStyle {
            return .custom(name, size: size, relativeTo: textStyle).weight(weight)
        }
        return .custom(name, size: size).weight(weight)
    }
}

/// Registers fonts shipped inside the package's `Resources/Fonts/` directory
/// with CoreText so that `Font.custom(...)` can resolve them by PostScript name.
///
/// Registration is idempotent and runs at most once per process.
enum KhmerFontRegistrar {

    private static var didRegister = false
    private static let lock = NSLock()

    /// File names (without extension) of fonts shipped in `Resources/Fonts/`.
    private static let bundledFontFiles: [String] = [
        "KantumruyPro-Regular",
        "KantumruyPro-Italic"
    ]

    static func registerBundledFontsIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        guard !didRegister else { return }
        didRegister = true

        #if canImport(CoreText)
        let bundle = Bundle.module
        for name in bundledFontFiles {
            guard let url = bundle.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            var error: Unmanaged<CFError>?
            let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            // Already-registered is benign — happens when the host app also
            // registers the same font, or when this module is loaded twice.
            if !ok, let cfError = error?.takeRetainedValue() {
                let code = CFErrorGetCode(cfError)
                let alreadyRegistered =
                    code == CTFontManagerError.alreadyRegistered.rawValue
                if !alreadyRegistered {
                    #if DEBUG
                    print("[KhmerDatePicker] failed to register \(name): \(cfError)")
                    #endif
                }
            }
        }
        #endif
    }
}
