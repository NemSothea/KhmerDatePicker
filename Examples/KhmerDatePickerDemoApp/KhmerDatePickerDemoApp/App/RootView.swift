import SwiftUI
import KhmerDatePickerSwiftUI

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            DatePickerScreen()
                .tabItem { Label(tab(.date), systemImage: "calendar") }
                .accessibilityIdentifier("tab.date")

            TimePickerScreen()
                .tabItem { Label(tab(.time), systemImage: "clock") }
                .accessibilityIdentifier("tab.time")

            FormatPreviewScreen()
                .tabItem { Label(tab(.formats), systemImage: "textformat") }
                .accessibilityIdentifier("tab.formats")

            EdgeCasesScreen()
                .tabItem { Label(tab(.edge), systemImage: "exclamationmark.triangle") }
                .accessibilityIdentifier("tab.edge")

            DebugScreen()
                .tabItem { Label(tab(.debug), systemImage: "ladybug") }
                .accessibilityIdentifier("tab.debug")
        }
        .khmerFont(environment.khmerFont)
    }

    private enum Tab { case date, time, formats, edge, debug }

    private func tab(_ tab: Tab) -> String {
        switch (environment.locale, tab) {
        case (.khmer, .date):    return "ប្រតិទិន"
        case (.khmer, .time):    return "ម៉ោង"
        case (.khmer, .formats): return "ទម្រង់"
        case (.khmer, .edge):    return "ករណីពិសេស"
        case (.khmer, .debug):   return "ឌីបុក"
        case (.english, .date):    return "Date"
        case (.english, .time):    return "Time"
        case (.english, .formats): return "Formats"
        case (.english, .edge):    return "Edge"
        case (.english, .debug):   return "Debug"
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppEnvironment(locale: .khmer))
        RootView()
            .environmentObject(AppEnvironment(locale: .english))
    }
}
