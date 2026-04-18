import SwiftUI

struct StatisticsSectionRevealModifier: ViewModifier {
    let isVisible: Bool
    let yOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : yOffset)
            .scaleEffect(isVisible ? 1 : 0.98)
            .animation(.spring(response: 0.45, dampingFraction: 0.84), value: isVisible)
    }
}

extension View {
    func statisticsSectionReveal(isVisible: Bool, yOffset: CGFloat = 16) -> some View {
        modifier(StatisticsSectionRevealModifier(isVisible: isVisible, yOffset: yOffset))
    }
}
