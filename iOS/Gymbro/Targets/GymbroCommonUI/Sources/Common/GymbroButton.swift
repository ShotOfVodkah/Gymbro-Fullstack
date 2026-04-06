import SwiftUI

public struct AppButton: View {
    
    public enum AppButtonSize {
        case xl
        case l
        case m

        var horizontalPadding: CGFloat {
            switch self {
            case .xl: return 24
            case .l:  return 20
            case .m:  return 16
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .xl: return 18
            case .l:  return 14
            case .m:  return 10
            }
        }

        var font: Font {
            switch self {
            case .xl: return .system(size: 18, weight: .semibold)
            case .l:  return .system(size: 16, weight: .semibold)
            case .m:  return .system(size: 14, weight: .semibold)
            }
        }

        var minHeight: CGFloat {
            switch self {
            case .xl: return 56
            case .l:  return 48
            case .m:  return 40
            }
        }
        
        var lineWidth: CGFloat {
            switch self {
            case .xl: return 2
            case .l:  return 1
            case .m:  return 1
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .xl: return 22
            case .l:  return 20
            case .m:  return 18
            }
        }
    }

    private let title: String?
    private let systemImage: String?
    private let size: AppButtonSize
    private let action: () -> Void
    private let wrapContent: Bool
    
    private let borderGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.85),
            Color.white.opacity(0.25),
            Color.white.opacity(0.0)
        ],
        startPoint: .bottomTrailing,
        endPoint: .topLeading
    )

    private let highlightGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.35),
            Color.white.opacity(0.15),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public init(
        _ title: String,
        size: AppButtonSize = .l,
        action: @escaping () -> Void,
        wrapContent: Bool = true
    ) {
        self.title = title
        self.systemImage = nil
        self.size = size
        self.action = action
        self.wrapContent = wrapContent
    }
    
    public init(
        systemImage: String,
        size: AppButtonSize = .l,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.systemImage = systemImage
        self.size = size
        self.action = action
        self.wrapContent = true
    }

    public var body: some View {
        Button(action: action) {
            content
                .frame(minHeight: size.minHeight)
                .frame(maxWidth: wrapContent ? nil : .infinity)
                .overlay(
                    Capsule()
                        .stroke(borderGradient, lineWidth: size.lineWidth)
                )
                .overlay(
                    Capsule()
                        .fill(highlightGradient)
                        .blendMode(.screen)
                )
                .background(Color.appPurple)
                .clipShape(Capsule())
        }
        .buttonStyle(PressScaleButtonStyle())
    }
    
    @ViewBuilder
    private var content: some View {
        if let title {
            Text(title)
                .font(size.font)
                .foregroundColor(.white)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
        } else if let systemImage {
            Image(systemName: systemImage)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size.minHeight, height: size.minHeight)
        }
    }
}

public struct PressScaleButtonStyle: ButtonStyle {
    private let pressedScale: CGFloat
    private let animation: Animation


    public init(
        pressedScale: CGFloat = 0.90,
        animation: Animation = .easeInOut(duration: 0.12)
    ) {
        self.pressedScale = pressedScale
        self.animation = animation
    }


    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

