import SwiftUI

public struct SkeletonFill: ShapeStyle {
    
    public init() {}
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        Color.white.opacity(0.34)
    }
}

public struct RoundedRectLine: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    public init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: height)
    }
}
