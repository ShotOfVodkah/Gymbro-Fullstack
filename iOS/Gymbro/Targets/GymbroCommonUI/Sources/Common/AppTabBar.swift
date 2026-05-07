import Foundation
import SwiftUI

public enum AppTab: Hashable {
    case feeds
    case challenge
    case workouts
    case perks
    case profile

    public var title: String {
        switch self {
        case .workouts:
            return String(localized: "tab.workouts", bundle: .module)
        case .feeds:
            return String(localized: "tab.feeds", bundle: .module)
        case .profile:
            return String(localized: "tab.profile", bundle: .module)
        case .challenge:
            return String(localized: "tab.challenge", bundle: .module)
        case .perks:
            return String(localized: "tab.perks", bundle: .module)
        }
    }

    public var icon: String {
        switch self {
        case .workouts: return "figure.strengthtraining.traditional"
        case .feeds: return "plus.square.on.square"
        case .profile: return "person.circle"
        case .challenge: return "bolt"
        case .perks: return "trophy"
        }
    }
    
    public var accessibilityID: String {
        switch self {
        case .workouts: return "tab.workouts"
        case .feeds: return "tab.feeds"
        case .profile: return "tab.profile"
        case .challenge: return "tab.challenge"
        case .perks: return "tab.perks"
        }
    }
}

public struct AppTabBar: View {
    @Binding var selected: AppTab
    
    public init(selected: Binding<AppTab>) {
        self._selected = selected
    }

    public var body: some View {
        HStack(spacing: Layout.itemSpacing) {
            tabItem(.feeds)
            tabItem(.challenge)
            tabItem(.workouts)
            tabItem(.perks)
            tabItem(.profile)
        }
        .padding(.horizontal, Layout.hPadding)
        .padding(.vertical, Layout.vPadding)
        .background(
            RoundedRectangle(cornerRadius: Layout.navBarCornerRadius, style: .continuous)
                .fill(Color.appDarkGray.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.navBarCornerRadius, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.bottom, Layout.bottomPadding)
        .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = (selected == tab)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.86)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))

                Text(tab.title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.itemVPadding)
            .padding(.horizontal, Layout.itemHPadding)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.appPurple)
                        .overlay(
                            Capsule()
                                .stroke(borderGradient, lineWidth: Layout.selectedLineWidth)
                        )
                        .overlay(
                            Capsule()
                                .fill(highlightGradient)
                                .blendMode(.screen)
                        )
                        .shadow(color: Color.appPurple.opacity(0.35), radius: 10, x: 0, y: 6)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(PressScaleButtonStyle(pressedScale: 0.94))
        .accessibilityIdentifier(tab.accessibilityID)
    }

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

    private enum Layout {
        static let itemSpacing: CGFloat = 8
        static let hPadding: CGFloat = 10
        static let vPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 25

        static let navBarCornerRadius: CGFloat = 60

        static let itemVPadding: CGFloat = 6
        static let itemHPadding: CGFloat = 7

        static let selectedLineWidth: CGFloat = 2
    }
}


