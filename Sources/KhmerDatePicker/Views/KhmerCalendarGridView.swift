import SwiftUI

struct KhmerCalendarGridView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel
    @Environment(\.khmerFont) private var khmerFont

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.weekdayHeader, id: \.self) { symbol in
                    Text(symbol)
                        .font(.khmer(khmerFont, size: 12, weight: .medium, relativeTo: .caption))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.dayCells) { cell in
                    DayCellView(cell: cell, khmerFont: khmerFont) {
                        viewModel.selectDate(cell.date)
                    }
                }
            }
        }
    }
}

private struct DayCellView: View {
    let cell: KhmerDatePickerViewModel.DayCell
    let khmerFont: KhmerFont
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(cell.label)
                .font(.khmer(
                    khmerFont,
                    size: 17,
                    weight: cell.isSelected ? .semibold : .regular,
                    relativeTo: .body
                ))
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(background)
                .foregroundColor(foreground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!cell.isEnabled)
        .opacity(opacity)
        .accessibilityLabel(Text(cell.accessibilityLabel))
        .accessibilityAddTraits(accessibilityTraits)
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

    private var opacity: Double {
        if !cell.isEnabled { return 0.25 }
        return cell.isInDisplayedMonth ? 1.0 : 0.35
    }

    private var accessibilityTraits: AccessibilityTraits {
        cell.isSelected ? .isSelected : []
    }
}
