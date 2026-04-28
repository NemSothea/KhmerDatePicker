import SwiftUI

struct KhmerMonthYearSelectorView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel
    @Environment(\.khmerFont) private var khmerFont

    var body: some View {
        HStack {
            Button(action: viewModel.goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .frame(width: 32, height: 32)
            }
            .disabled(!viewModel.canGoToPreviousMonth)
            .accessibilityLabel(Text(viewModel.locale == .khmer ? "ខែមុន" : "Previous month"))

            Spacer()

            Text(viewModel.monthLabel)
                .font(.khmer(khmerFont, size: 17, weight: .semibold, relativeTo: .headline))
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button(action: viewModel.goToNextMonth) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .frame(width: 32, height: 32)
            }
            .disabled(!viewModel.canGoToNextMonth)
            .accessibilityLabel(Text(viewModel.locale == .khmer ? "ខែបន្ទាប់" : "Next month"))
        }
        .padding(.horizontal, 4)
    }
}
