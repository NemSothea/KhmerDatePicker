import SwiftUI
import KhmerDatePickerSwiftUI

struct TimePickerScreen: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = TimePickerViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    LocaleToggle()

                    Toggle(isOn: $viewModel.showsSeconds) {
                        Text(title("បង្ហាញវិនាទី", "Show seconds"))
                    }
                    .padding(.horizontal, 4)
                    .accessibilityIdentifier("toggle.showsSeconds")

                    SectionCard(title: title("ជ្រើសរើសម៉ោង", "Time picker")) {
                        KhmerDatePickerView(
                            selection: $viewModel.selectedDate,
                            mode: .time,
                            locale: environment.locale,
                            showsSeconds: viewModel.showsSeconds
                        )
                        .accessibilityIdentifier("picker.time")
                    }

                    SectionCard(title: title("ខ្មែរ", "Khmer")) {
                        Text(viewModel.timeString(in: .khmer))
                            .font(.title3)
                            .accessibilityIdentifier("time.khmer")
                    }

                    SectionCard(title: title("អង់គ្លេស", "English")) {
                        Text(viewModel.timeString(in: .english))
                            .font(.title3)
                            .accessibilityIdentifier("time.english")
                    }

                    SectionCard(
                        title: title("សមាសភាគ", "Components"),
                        subtitle: title("ម៉ោង / នាទី / វិនាទី", "ម៉ោង (hour) / នាទី (minute) / វិនាទី (second)")
                    ) {
                        let comps = viewModel.components()
                        VStack(alignment: .leading, spacing: 6) {
                            LabeledRow(
                                label: "ម៉ោង (hour)",
                                value: viewModel.renderedComponent(comps.hour, in: environment.locale),
                                monospaced: true,
                                identifier: "comp.hour"
                            )
                            LabeledRow(
                                label: "នាទី (minute)",
                                value: viewModel.renderedComponent(comps.minute, in: environment.locale),
                                monospaced: true,
                                identifier: "comp.minute"
                            )
                            LabeledRow(
                                label: "វិនាទី (second)",
                                value: viewModel.renderedComponent(comps.second, in: environment.locale),
                                monospaced: true,
                                identifier: "comp.second"
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(title("ម៉ោង", "Time"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func title(_ km: String, _ en: String) -> String {
        environment.locale == .khmer ? km : en
    }
}

struct TimePickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        TimePickerScreen()
            .environmentObject(AppEnvironment(locale: .khmer))
    }
}
