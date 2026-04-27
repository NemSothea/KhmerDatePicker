import SwiftUI

struct KhmerTimePickerView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel

    var body: some View {
        HStack(spacing: 12) {
            timeColumn(
                title: KhmerCalendarSymbols.hour,
                values: viewModel.hourComponents,
                selection: hourBinding,
                label: viewModel.label(forHour:)
            )

            timeColumn(
                title: KhmerCalendarSymbols.minute,
                values: viewModel.minuteComponents,
                selection: minuteBinding,
                label: viewModel.label(forMinute:)
            )

            if viewModel.showsSeconds {
                timeColumn(
                    title: KhmerCalendarSymbols.second,
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
        title: String,
        values: [Int],
        selection: Binding<Int>,
        label: @escaping (Int) -> String
    ) -> some View {
        VStack(spacing: 4) {
            Text(viewModel.locale == .khmer ? title : englishTitle(for: title))
                .font(.caption)
                .foregroundColor(.secondary)

            Picker(selection: selection, label: EmptyView()) {
                ForEach(values, id: \.self) { value in
                    Text(label(value)).tag(value)
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
        }
    }

    private func englishTitle(for khmerTitle: String) -> String {
        switch khmerTitle {
        case KhmerCalendarSymbols.hour:   return "Hour"
        case KhmerCalendarSymbols.minute: return "Minute"
        case KhmerCalendarSymbols.second: return "Second"
        default: return khmerTitle
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
