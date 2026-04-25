import SwiftUI

struct GlassCapsule: View {
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.18))
            .overlay(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func glassCapsuleStyle() -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(GlassCapsule())
    }
}
