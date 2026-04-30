import SwiftUI
import KhmerDatePickerSwiftUI

struct EdgeCasesScreen: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = EdgeCasesViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LocaleToggle()

                    SectionCard(
                        title: title("ករណី​ពិសេស", "Edge case fixtures"),
                        subtitle: title("ចុច​ដើម្បី​ប្ដូរ​ថ្ងៃ", "Tap to jump the picker to a known boundary")
                    ) {
                        VStack(spacing: 8) {
                            ForEach(EdgeCasesViewModel.Fixture.allCases) { fixture in
                                Button(action: { viewModel.apply(fixture) }) {
                                    HStack {
                                        Image(systemName: icon(for: fixture))
                                            .frame(width: 20)
                                        Text(label(for: fixture))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .accessibilityIdentifier("edge.\(fixture.rawValue)")
                            }
                        }
                    }

                    SectionCard(title: title("ការ​បង្ហាញ​ថ្ងៃ", "Selected fixture")) {
                        KhmerDatePickerView(
                            selection: $viewModel.selectedDate,
                            mode: .dateAndTime,
                            locale: environment.locale,
                            firstWeekday: environment.firstWeekday,
                            showsSeconds: true
                        )
                        .accessibilityIdentifier("picker.edge")
                    }

                    SectionCard(title: title("លទ្ធផល​ខ្មែរ", "Khmer outputs")) {
                        outputs(for: .khmer)
                    }

                    SectionCard(title: title("លទ្ធផល​អង់គ្លេស", "English outputs")) {
                        outputs(for: .english)
                    }
                }
                .padding()
            }
            .navigationTitle(title("ករណី​ពិសេស", "Edge cases"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func outputs(for locale: KhmerLocale) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            LabeledRow(
                label: ".full",
                value: viewModel.format(.full, in: locale),
                identifier: "edge.\(locale.rawValue).full"
            )
            LabeledRow(
                label: ".dateTime",
                value: viewModel.format(.dateTime, in: locale),
                identifier: "edge.\(locale.rawValue).dateTime"
            )
            LabeledRow(
                label: ".short",
                value: viewModel.format(.short, in: locale),
                monospaced: true,
                identifier: "edge.\(locale.rawValue).short"
            )
        }
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }

    private func label(for fixture: EdgeCasesViewModel.Fixture) -> String {
        let pair = fixture.title
        return environment.locale == .khmer ? pair.km : pair.en
    }

    private func icon(for fixture: EdgeCasesViewModel.Fixture) -> String {
        switch fixture {
        case .leapDay:      return "calendar.badge.exclamationmark"
        case .endOfMonth:   return "calendar"
        case .endOfYear:    return "fireworks"
        case .timeBoundary: return "clock.badge.exclamationmark"
        case .midnight:     return "moon.stars"
        case .today:        return "sun.max"
        }
    }
}

struct EdgeCasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        EdgeCasesScreen()
            .environmentObject(AppEnvironment(locale: .khmer))
    }
}
