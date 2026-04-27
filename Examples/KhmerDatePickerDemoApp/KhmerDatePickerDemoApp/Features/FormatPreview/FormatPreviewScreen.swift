import SwiftUI
import KhmerDatePicker

struct FormatPreviewScreen: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = FormatPreviewViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LocaleToggle()

                    SectionCard(
                        title: title("ជ្រើសរើស​ម៉ោង​និង​ថ្ងៃ", "Pick a date + time"),
                        subtitle: title("ផ្លាស់​ប្ដូរ​ដើម្បី​មើល​លទ្ធផល", "Change to see every Style update live")
                    ) {
                        KhmerDatePickerView(
                            selection: $viewModel.selectedDate,
                            mode: .dateAndTime,
                            locale: environment.locale,
                            firstWeekday: environment.firstWeekday,
                            showsSeconds: false
                        )
                        .accessibilityIdentifier("picker.formatPreview")
                    }

                    HStack {
                        Button(action: viewModel.resetToSpecSample) {
                            Label(title("Spec sample", "Spec sample"), systemImage: "doc.text.magnifyingglass")
                        }
                        .accessibilityIdentifier("button.specSample")
                        Spacer()
                        Text(specHint)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    SectionCard(
                        title: "Khmer (km_KH)",
                        subtitle: "KhmerDateFormatter.string(from:, style:, locale: .khmer)"
                    ) {
                        styleTable(for: .khmer)
                    }

                    SectionCard(
                        title: "English (en_US)",
                        subtitle: "KhmerDateFormatter.string(from:, style:, locale: .english)"
                    ) {
                        styleTable(for: .english)
                    }
                }
                .padding()
            }
            .navigationTitle(title("ទម្រង់​ទាំង​អស់", "All formats"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var specHint: String {
        environment.locale == .khmer
            ? "ព្រហស្បតិ៍ ទី ១ មករា ២០២៦ ម៉ោង ១៤:៣០"
            : "Thu Jan 1 2026 14:30"
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }

    @ViewBuilder
    private func styleTable(for locale: KhmerLocale) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(viewModel.styles, id: \.self) { style in
                LabeledRow(
                    label: viewModel.styleLabel(style),
                    value: viewModel.format(style, in: locale),
                    identifier: "preview.\(locale.rawValue).\(String(describing: style))"
                )
            }
        }
    }
}

struct FormatPreviewScreen_Previews: PreviewProvider {
    static var previews: some View {
        FormatPreviewScreen()
            .environmentObject(AppEnvironment(locale: .khmer))
    }
}
