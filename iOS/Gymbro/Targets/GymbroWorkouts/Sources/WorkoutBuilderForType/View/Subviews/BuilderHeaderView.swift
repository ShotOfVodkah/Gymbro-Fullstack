import SwiftUI

import GymbroCommonUI

struct BuilderHeaderView: View {
    let title: String
    @Binding var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.stackSpacing) {
            Text(title)
                .foregroundStyle(.white)
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading, Layout.titleLeading)
                .padding(Layout.titlePadding)
                .frame(maxWidth: .infinity, alignment: .leading)

            AppTextField(
                placeholder: "Workout name",
                text: $name
            )
            .padding(.vertical, Layout.fieldVertical)
            .padding(.horizontal, Layout.fieldHorizontal)
        }
    }

    private enum Layout {
        static let stackSpacing: CGFloat = 8
        static let titleLeading: CGFloat = 40
        static let titlePadding = EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 5)
        static let fieldHorizontal: CGFloat = 16
        static let fieldVertical: CGFloat = 10
    }
}


