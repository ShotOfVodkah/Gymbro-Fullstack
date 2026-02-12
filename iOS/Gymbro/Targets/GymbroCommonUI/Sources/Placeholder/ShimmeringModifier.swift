import SwiftUI

public struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = -0.6


    public func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    GeometryReader { proxy in
                        let w = proxy.size.width
                        let h = proxy.size.height


                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(0.18), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: w * 0.9, height: h * 2)
                        .rotationEffect(.degrees(20))
                        .offset(x: w * phase, y: 0)
                        .blendMode(.screen)
                        .allowsHitTesting(false)
                        .onAppear {
                            withAnimation(.linear(duration: 1.25).repeatForever(autoreverses: false)) {
                                phase = 1.2
                            }
                        }
                    }
                }
            }
            .mask(content)
    }
}


extension View {
    public func shimmer(active: Bool) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}
