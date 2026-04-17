import SwiftUI
import DivKit

struct AvailableExercisesSection: View {
    @Binding var isCollapsed: Bool
    let divkitComponents: DivKitComponents
    let source: DivViewSource

    var body: some View {
        VStack(spacing: 0) {
            header

            DivHostingView(divkitComponents: divkitComponents, source: source)
                .frame(maxWidth: .infinity)
                .frame(height: isCollapsed ? Layout.collapsedHeight : nil, alignment: .top)
                .opacity(isCollapsed ? 0.0 : 1.0)
                .clipped()
                .animation(Layout.animation, value: isCollapsed)
        }
    }

    private var header: some View {
        HStack(spacing: Layout.headerSpacing) {
            Text(String(localized: "workout.available_exercises", bundle: .module))
                .foregroundStyle(.white)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            Button {
                withAnimation(Layout.animation) {
                    isCollapsed.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: Layout.chevronSize, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .rotationEffect(.degrees(isCollapsed ? -180 : 0))
                    .animation(Layout.animation, value: isCollapsed)
                    .padding(Layout.chevronPadding)
                    .background(.white.opacity(0.06), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, Layout.headerLeading)
        .padding(.trailing, Layout.headerTrailing)
        .padding(.vertical, Layout.headerVertical)
    }

    private enum Layout {
        static let collapsedHeight: CGFloat = 90

        static let headerSpacing: CGFloat = 12
        static let headerLeading: CGFloat = 16
        static let headerTrailing: CGFloat = 12
        static let headerVertical: CGFloat = 5

        static let chevronSize: CGFloat = 16
        static let chevronPadding: CGFloat = 10

        static let animation: Animation = .spring(response: 0.28, dampingFraction: 0.85)
    }
}
