import SwiftUI
import KhmerDatePickerSwiftUI

struct DatePickerScreen: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = DatePickerViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LocaleToggle()

                    SectionCard(title: title("ប្រតិទិន", "Calendar")) {
                        KhmerDatePickerView(
                            selection: $viewModel.selectedDate,
                            mode: .date,
                            locale: environment.locale,
                            firstWeekday: environment.firstWeekday
                        )
                        .accessibilityIdentifier("picker.date")
                    }

                    SectionCard(
                        title: title("ទម្រង់ខ្មែរ", "Khmer formats"),
                        subtitle: title("បង្ហាញគ្រប់ Style", "All six Style cases — Khmer locale")
                    ) {
                        formatList(for: .khmer)
                    }

                    SectionCard(
                        title: title("ទម្រង់​អង់គ្លេស", "English formats"),
                        subtitle: title("បង្ហាញគ្រប់ Style", "All six Style cases — English locale")
                    ) {
                        formatList(for: .english)
                    }
                }
                .padding()
            }
            .navigationTitle(title("ប្រតិទិន​ខ្មែរ", "Khmer DatePicker"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }

    @ViewBuilder
    private func formatList(for locale: KhmerLocale) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.allStyles, id: \.label) { entry in
                LabeledRow(
                    label: entry.label,
                    value: viewModel.formatted(in: locale, style: entry.style),
                    identifier: DatePickerViewModel.identifier(for: entry.style, locale: locale)
                )
            }
        }
    }
}

struct DatePickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DatePickerScreen()
                .environmentObject(AppEnvironment(locale: .khmer))
                .previewDisplayName("Khmer")
            DatePickerScreen()
                .environmentObject(AppEnvironment(locale: .english))
                .previewDisplayName("English")
        }
    }
}
