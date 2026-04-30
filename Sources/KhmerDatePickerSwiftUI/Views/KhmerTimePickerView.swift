import SwiftUI

struct KhmerTimePickerView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel
    @Environment(\.khmerFont) private var khmerFont

    private enum TimeUnit {
        case hour, minute, second
    }

    var body: some View {
        HStack(spacing: 12) {
            timeColumn(
                unit: .hour,
                values: viewModel.hourComponents,
                selection: hourBinding,
                label: viewModel.label(forHour:)
            )

            timeColumn(
                unit: .minute,
                values: viewModel.minuteComponents,
                selection: minuteBinding,
                label: viewModel.label(forMinute:)
            )

            if viewModel.showsSeconds {
                timeColumn(
                    unit: .second,
                    values: viewModel.secondComponents,
                    selection: secondBinding,
                    label: viewModel.label(forSecond:)
                )
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func timeColumn(
        unit: TimeUnit,
        values: [Int],
        selection: Binding<Int>,
        label: @escaping (Int) -> String
    ) -> some View {
        VStack(spacing: 4) {
            Text(displayTitle(for: unit))
                .font(.khmer(khmerFont, size: 12, weight: .medium, relativeTo: .caption))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Picker(selection: selection, label: EmptyView()) {
                ForEach(values, id: \.self) { value in
                    Text(label(value))
                        .font(.khmer(khmerFont, size: 20, relativeTo: .title3))
                        .tag(value)
                }
            }
            #if os(iOS)
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .clipped()
            #else
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            #endif
            .accessibilityLabel(Text(accessibilityTitle(for: unit)))
        }
    }

    private func displayTitle(for unit: TimeUnit) -> String {
        switch (viewModel.locale, unit) {
        case (.khmer, .hour):    return KhmerCalendarSymbols.hour
        case (.khmer, .minute):  return KhmerCalendarSymbols.minute
        case (.khmer, .second):  return KhmerCalendarSymbols.second
        case (.english, .hour):   return "Hour"
        case (.english, .minute): return "Minute"
        case (.english, .second): return "Second"
        }
    }

    private func accessibilityTitle(for unit: TimeUnit) -> String {
        // VoiceOver always reads the English label so it's understandable to
        // assistive-tech users regardless of the visible locale; the visible
        // Khmer label is shown beside it.
        switch unit {
        case .hour:   return "Hour"
        case .minute: return "Minute"
        case .second: return "Second"
        }
    }

    private var hourBinding: Binding<Int> {
        Binding(
            get: { viewModel.selectedHour },
            set: { viewModel.selectedHour = $0 }
        )
    }

    private var minuteBinding: Binding<Int> {
        Binding(
            get: { viewModel.selectedMinute },
            set: { viewModel.selectedMinute = $0 }
        )
    }

    private var secondBinding: Binding<Int> {
        Binding(
            get: { viewModel.selectedSecond },
            set: { viewModel.selectedSecond = $0 }
        )
    }
}
