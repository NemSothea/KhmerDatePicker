import SwiftUI

private struct KhmerFontKey: EnvironmentKey {
    static let defaultValue: KhmerFont = .system
}

public extension EnvironmentValues {
    /// The Khmer font family used by `KhmerDatePickerView` and its subviews.
    var khmerFont: KhmerFont {
        get { self[KhmerFontKey.self] }
        set { self[KhmerFontKey.self] = newValue }
    }
}

public extension View {
    /// Set the Khmer font family used by `KhmerDatePickerView`.
    ///
    ///     KhmerDatePickerView(selection: $date)
    ///         .khmerFont(.kantumruyPro)
    func khmerFont(_ font: KhmerFont) -> some View {
        environment(\.khmerFont, font)
    }
}
