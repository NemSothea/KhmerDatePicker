import SwiftUI

struct KhmerCalendarGridView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.weekdayHeader, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.dayCells) { cell in
                    DayCellView(cell: cell) {
                        viewModel.selectDate(cell.date)
                    }
                }
            }
        }
    }
}

private struct DayCellView: View {
    let cell: KhmerDatePickerViewModel.DayCell
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(cell.label)
                .font(.body)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(background)
                .foregroundColor(foreground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .opacity(cell.isInDisplayedMonth ? 1.0 : 0.35)
        .accessibilityAddTraits(cell.isSelected ? .isSelected : [])
    }

    private var background: Color {
        if cell.isSelected { return .accentColor }
        if cell.isToday { return .accentColor.opacity(0.15) }
        return .clear
    }

    private var foreground: Color {
        if cell.isSelected { return .white }
        if cell.isToday { return .accentColor }
        return .primary
    }
}
