import SwiftUI

public struct KhmerDatePickerView: View {

    @Binding private var selection: Date
    private let range: ClosedRange<Date>?
    private let locale: KhmerLocale
    private let mode: KhmerDatePickerMode
    private let firstWeekday: Int
    private let showsSeconds: Bool
    private let formatStyle: KhmerDateFormatter.Style?

    @StateObject private var viewModel: KhmerDatePickerViewModel
    @Environment(\.khmerFont) private var khmerFont

    public init(
        selection: Binding<Date>,
        in range: ClosedRange<Date>? = nil,
        mode: KhmerDatePickerMode = .date,
        locale: KhmerLocale = .khmer,
        firstWeekday: Int = 1,
        showsSeconds: Bool = false,
        formatStyle: KhmerDateFormatter.Style? = nil
    ) {
        self._selection = selection
        self.range = range
        self.locale = locale
        self.mode = mode
        self.firstWeekday = firstWeekday
        self.showsSeconds = showsSeconds
        self.formatStyle = formatStyle
        _viewModel = StateObject(
            wrappedValue: KhmerDatePickerViewModel(
                initialDate: selection.wrappedValue,
                locale: locale,
                mode: mode,
                firstWeekday: firstWeekday,
                showsSeconds: showsSeconds,
                range: range
            )
        )
    }

    public var body: some View {
        VStack(spacing: 16) {
            if let style = formatStyle {
                Text(viewModel.formatted(style: style))
                    .font(.khmer(khmerFont, size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if viewModel.mode.showsCalendar {
                KhmerMonthYearSelectorView(viewModel: viewModel)
                KhmerCalendarGridView(viewModel: viewModel)
            }

            if viewModel.mode.showsTime {
                if viewModel.mode == .dateAndTime {
                    Divider()
                }
                KhmerTimePickerView(viewModel: viewModel)
            }
        }
        .padding()
        .onChange(of: viewModel.selectedDate) { newValue in
            if newValue != selection { selection = newValue }
        }
        .onChange(of: selection) { newValue in
            viewModel.syncSelection(newValue)
        }
        .onChange(of: locale) { newValue in
            viewModel.locale = newValue
        }
        .onChange(of: mode) { newValue in
            viewModel.mode = newValue
        }
        .onChange(of: showsSeconds) { newValue in
            viewModel.showsSeconds = newValue
        }
        .onChange(of: range) { newValue in
            viewModel.range = newValue
            viewModel.syncSelection(viewModel.selectedDate)
        }
    }
}
