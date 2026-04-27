import SwiftUI

struct KhmerMonthYearSelectorView: View {
    @ObservedObject var viewModel: KhmerDatePickerViewModel

    var body: some View {
        HStack {
            Button(action: viewModel.goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel(Text(viewModel.locale == .khmer ? "ខែមុន" : "Previous month"))

            Spacer()

            Text(viewModel.monthLabel)
                .font(.headline)

            Spacer()

            Button(action: viewModel.goToNextMonth) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel(Text(viewModel.locale == .khmer ? "ខែបន្ទាប់" : "Next month"))
        }
        .padding(.horizontal, 4)
    }
}
