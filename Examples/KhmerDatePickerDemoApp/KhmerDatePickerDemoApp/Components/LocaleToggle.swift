import SwiftUI
import KhmerDatePicker

struct LocaleToggle: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.headline)
            Spacer(minLength: 8)
            chip(.khmer, title: "🇰🇭 ភាសាខ្មែរ")
            chip(.english, title: "🇺🇸 English")
        }
        .padding(.vertical, 4)
    }

    private var label: String {
        environment.locale == .khmer ? "ភាសា" : "Locale"
    }

    private func chip(_ locale: KhmerLocale, title: String) -> some View {
        Button(action: { environment.locale = locale }) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(environment.locale == locale ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(environment.locale == locale ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(BorderlessButtonStyle())
        .accessibilityIdentifier("locale.\(locale.rawValue)")
    }
}

struct LocaleToggle_Previews: PreviewProvider {
    static var previews: some View {
        LocaleToggle()
            .environmentObject(AppEnvironment(locale: .khmer))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
