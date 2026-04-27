// Drop this file into a SwiftUI iOS 14+ app target that depends on the
// KhmerDatePicker Swift Package, then set ContentView as your app's root.

import SwiftUI
import KhmerDatePicker

struct ContentView: View {
    @State private var date: Date = Date()
    @State private var locale: KhmerLocale = .khmer
    @State private var mode: KhmerDatePickerMode = .date
    @State private var showsSeconds: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Picker("Locale", selection: $locale) {
                        ForEach(KhmerLocale.allCases, id: \.self) { value in
                            Text(value.displayName).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Mode", selection: $mode) {
                        Text(locale == .khmer ? "កាលបរិច្ឆេទ" : "Date").tag(KhmerDatePickerMode.date)
                        Text(locale == .khmer ? "ម៉ោង" : "Time").tag(KhmerDatePickerMode.time)
                        Text(locale == .khmer ? "ទាំងពីរ" : "Both").tag(KhmerDatePickerMode.dateAndTime)
                    }
                    .pickerStyle(.segmented)

                    if mode != .date {
                        Toggle(locale == .khmer ? "បង្ហាញវិនាទី" : "Show seconds", isOn: $showsSeconds)
                    }

                    KhmerDatePickerView(
                        selection: $date,
                        mode: mode,
                        locale: locale,
                        showsSeconds: showsSeconds,
                        formatStyle: .full
                    )
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    GroupBox(label: Text(locale == .khmer ? "ទម្រង់ផ្សេងទៀត" : "Other formats")) {
                        VStack(alignment: .leading, spacing: 6) {
                            row(.full)
                            row(.long)
                            row(.medium)
                            row(.short)
                            row(.time)
                            row(.dateTime)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle(locale == .khmer ? "ឧទាហរណ៍" : "KhmerDatePicker")
        }
    }

    private func row(_ style: KhmerDateFormatter.Style) -> some View {
        HStack(alignment: .top) {
            Text(label(for: style))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(KhmerDateFormatter.string(from: date, style: style, locale: locale))
                .font(.callout)
        }
    }

    private func label(for style: KhmerDateFormatter.Style) -> String {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
