import SwiftUI
import GymbroCommonUI

struct WorkoutsStreakSheet: View {

    init(
        total: Int,
        current: Int,
        daysLeft: Int,
        value: Int,
        wasFreezeUsedThisWeek: Bool,
        isGoalCompleted: Bool
    ) {
        self.total = total
        self.daysLeft = daysLeft
        self.current = current
        self.value = value
        self.wasFreezeUsedThisWeek = wasFreezeUsedThisWeek
        self.isGoalCompleted = isGoalCompleted
        if wasFreezeUsedThisWeek {
            self.streakText = WorkoutL10n.streakMotivationFreeze
        } else if isGoalCompleted {
            self.streakText = WorkoutL10n.streakMotivationSafe
        } else {
            self.streakText = !isGoalCompleted && !wasFreezeUsedThisWeek && daysLeft <= 2 && current < total
                ? WorkoutL10n.streakMotivationDanger
                : WorkoutL10n.streakMotivationSafe
        }
    }

    var body: some View {
        ZStack {
            sheetBackdrop

            VStack(spacing: 0) {

                VStack(spacing: 18) {
                    Text(String(localized: "workout.streak.title", bundle: .module))
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.bold)

                    flameHero

                    SegmentedPillProgress(
                        total: total,
                        current: current,
                        daysLeft: daysLeft,
                        color: accentColor
                    )

                    Text(streakText)
                        .foregroundStyle(.white.opacity(0.92))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .lineSpacing(3)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.white.opacity(0.07))
                                .background {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(accentGradient.opacity(0.12))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.22),
                                                    accentColor.opacity(0.35),
                                                    Color.white.opacity(0.06)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .padding(.horizontal, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var sheetBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [
                    backdropTopColor,
                    Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255),
                    Color.appDarkGray
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    accentColor.opacity(0.38),
                    accentColor.opacity(0.12),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.22),
                startRadius: 12,
                endRadius: 200
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.42)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea(.all)
    }

    private var flameHero: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accentColor.opacity(0.5),
                            accentColor.opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 72
                    )
                )
                .frame(width: 156, height: 156)

            Image("streak", bundle: .module)
                .renderingMode(.template)
                .foregroundStyle(accentGradient)
                .scaleEffect(0.23)

            Text("\(value)")
                .foregroundStyle(.white)
                .font(.system(size: 50, weight: .semibold, design: .rounded))
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                .offset(y: 15)
        }
        .frame(height: 148)
    }
    
    private let total: Int
    private let current: Int
    private let daysLeft: Int
    private let value: Int
    private let wasFreezeUsedThisWeek: Bool
    private let isGoalCompleted: Bool
    private let streakText: String

    private var isDangerState: Bool {
        !isGoalCompleted && !wasFreezeUsedThisWeek && daysLeft <= 2 && current < total
    }

    private var accentColor: Color {
        if wasFreezeUsedThisWeek {
            return Color.cyan
        }
        if isGoalCompleted {
            return Color.mint
        }
        if isDangerState {
            return Color.appRed
        }
        return Color.appPurple
    }

    private var accentGradient: LinearGradient {
        if wasFreezeUsedThisWeek {
            return LinearGradient(
                colors: [
                    Color.cyan.opacity(0.95),
                    Color.blue.opacity(0.72)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        if isGoalCompleted {
            return LinearGradient(
                colors: [
                    Color.green.opacity(0.95),
                    Color.mint.opacity(0.78)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        if isDangerState {
            return LinearGradient(
                colors: [
                    Color.red.opacity(0.95),
                    Color.orange.opacity(0.75)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        return LinearGradient(
            colors: [
                Color.appPurple.opacity(0.98),
                Color(red: 168 / 255, green: 120 / 255, blue: 255 / 255).opacity(0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var backdropTopColor: Color {
        if wasFreezeUsedThisWeek {
            return Color(red: 14 / 255, green: 28 / 255, blue: 42 / 255)
        }
        if isGoalCompleted {
            return Color(red: 14 / 255, green: 36 / 255, blue: 30 / 255)
        }
        if isDangerState {
            return Color(red: 38 / 255, green: 14 / 255, blue: 26 / 255)
        }
        return Color(red: 26 / 255, green: 16 / 255, blue: 44 / 255)
    }
}

public struct SegmentedPillProgress: View {
    private let total: Int
    private let current: Int
    private let daysLeft: Int
    private let height: CGFloat
    private let spacing: CGFloat
    private let color: Color

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
        total: Int,
        current: Int,
        daysLeft: Int,
        height: CGFloat = 10,
        spacing: CGFloat = 5,
        color: Color
    ) {
        self.total = max(1, total)
        self.current = min(max(0, current), self.total)
        self.daysLeft = daysLeft
        self.height = height
        self.spacing = spacing
        self.color = color
    }


    public var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: spacing) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < current ? color: Color.white.opacity(0.14))
                        .overlay(
                            Capsule()
                                .stroke(borderGradient, lineWidth: 0.5)
                        )
                        .overlay(
                            Capsule()
                                .fill(highlightGradient)
                                .blendMode(.screen)
                        )
                        .shadow(color: index < current ? color.opacity(0.35) : .clear, radius: 4, y: 1)
                        .frame(height: height)
                }
            }

            Text(WorkoutL10n.streakDaysLeft(daysLeft))
                .foregroundStyle(.white.opacity(0.95))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .padding(.horizontal, 10)
    }
}
