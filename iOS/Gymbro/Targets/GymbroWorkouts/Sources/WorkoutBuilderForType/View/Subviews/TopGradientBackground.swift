import SwiftUI

struct TopGradientBackground: View {
    var body: some View {
        VStack {
            LinearGradient(
                colors: [Color.appPurple, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: Layout.height, alignment: .top)

            Spacer()
        }
    }

    private enum Layout {
        static let height: CGFloat = 120
    }
}
