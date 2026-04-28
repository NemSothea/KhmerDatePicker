import SwiftUI
import KhmerDatePicker

struct DebugScreen: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = DebugViewModel()

    private static let timeStampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LocaleToggle()

                    FontToggle()

                    SectionCard(
                        title: title("ឧបករណ៍​ជ្រើសរើស", "Picker"),
                        subtitle: title("ផ្លាស់ប្ដូរ​ដើម្បី​បង្កើត log", "Change date to append a log entry")
                    ) {
                        KhmerDatePickerView(
                            selection: $viewModel.selectedDate,
                            mode: .dateAndTime,
                            locale: environment.locale,
                            firstWeekday: environment.firstWeekday,
                            showsSeconds: true
                        )
                        .accessibilityIdentifier("picker.debug")
                    }

                    SectionCard(title: title("Date ដើម", "Raw Date")) {
                        VStack(alignment: .leading, spacing: 6) {
                            LabeledRow(label: "epoch s", value: viewModel.epochSeconds, monospaced: true, identifier: "debug.epoch")
                            LabeledRow(label: "ISO-8601", value: viewModel.iso8601, monospaced: true, identifier: "debug.iso")
                            LabeledRow(label: "Date.description", value: viewModel.debugDescription, monospaced: true, identifier: "debug.description")
                        }
                    }

                    SectionCard(
                        title: title("លេខ​ខ្មែរ", "Khmer numerals"),
                        subtitle: title("Arabic ទៅ Khmer", "Component-by-component conversion")
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.components()) { comp in
                                HStack(alignment: .firstTextBaseline) {
                                    Text(comp.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 80, alignment: .leading)
                                    Text(comp.arabic)
                                        .font(.system(.callout, design: .monospaced))
                                        .frame(width: 80, alignment: .leading)
                                    Text("→")
                                        .foregroundColor(.secondary)
                                    Text(comp.khmer)
                                        .font(.callout)
                                }
                                .accessibilityIdentifier("debug.comp.\(comp.name)")
                            }
                        }
                    }

                    SectionCard(
                        title: title("កំណត់​ហេតុ formatter", "Formatter log"),
                        subtitle: title(
                            "ចុង​ក្រោយ​បំផុត ខាង​លើ",
                            "Most recent first — capped at \(AppEnvironment.logLimit)"
                        )
                    ) {
                        logSection
                    }
                }
                .padding()
            }
            .navigationTitle(title("ឌីបុក", "Debug"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: viewModel.selectedDate) { _ in
            environment.appendLog(viewModel.snapshot())
        }
        .onAppear {
            environment.appendLog(viewModel.snapshot())
        }
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }

    @ViewBuilder
    private var logSection: some View {
        if environment.formatterLog.isEmpty {
            Text(title("មិន​មាន​កំណត់​ហេតុ​ទេ", "No log entries yet"))
                .font(.callout)
                .foregroundColor(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title("ចំនួន: ", "Count: ") + "\(environment.formatterLog.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: environment.clearLog) {
                        Label(title("លុប", "Clear"), systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .accessibilityIdentifier("debug.clearLog")
                }
                ForEach(environment.formatterLog.prefix(25)) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Self.timeStampFormatter.string(from: entry.timestamp))
                            .font(.caption2.monospacedDigit())
                            .foregroundColor(.secondary)
                        Text("KM: \(entry.khmer)")
                            .font(.caption)
                        Text("EN: \(entry.english)")
                            .font(.caption)
                    }
                    .padding(.vertical, 2)
                }
            }
            .accessibilityIdentifier("debug.log")
        }
    }
}

struct DebugScreen_Previews: PreviewProvider {
    static var previews: some View {
        DebugScreen()
            .environmentObject(AppEnvironment(locale: .khmer))
    }
}

private struct FontToggle: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.headline)
            Spacer(minLength: 8)
            chip(.system,       title: title("ប្រព័ន្ធ", "System"),       id: "system")
            chip(.kantumruyPro, title: "Kantumruy Pro",                  id: "kantumruyPro")
        }
        .padding(.vertical, 4)
    }

    private var label: String {
        environment.locale == .khmer ? "ពុម្ព​អក្សរ" : "Font"
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }

    private func chip(_ font: KhmerFont, title: String, id: String) -> some View {
        Button(action: { environment.khmerFont = font }) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(environment.khmerFont == font ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(environment.khmerFont == font ? Color.accentColor : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(BorderlessButtonStyle())
        .accessibilityIdentifier("font.\(id)")
    }
}
