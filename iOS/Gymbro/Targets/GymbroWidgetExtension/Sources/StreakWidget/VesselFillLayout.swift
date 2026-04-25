import SwiftUI
struct VesselFillLayout: Layout {
    let fillRatio: CGFloat

    init(fillRatio: Double) {
        self.fillRatio = max(0, min(1, fillRatio))
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        CGSize(
            width: proposal.width ?? 74,
            height: proposal.height ?? 96
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard subviews.count >= 3 else { return }

        let background = subviews[0]
        let backgroundOverlay = subviews[1]
        let fill = subviews[2]

        background.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(bounds.size)
        )
        
        backgroundOverlay.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(bounds.size)
        )

        let fillHeight = bounds.height * fillRatio

        let fillRect = CGRect(
            x: bounds.minX,
            y: bounds.maxY - fillHeight,
            width: bounds.width,
            height: fillHeight
        )

        fill.place(
            at: fillRect.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(fillRect.size)
        )
    }
}
