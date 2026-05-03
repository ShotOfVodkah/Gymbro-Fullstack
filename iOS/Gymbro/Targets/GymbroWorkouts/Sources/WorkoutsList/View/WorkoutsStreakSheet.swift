import SwiftUI
import GymbroCommonUI

struct WorkoutsStreakSheet: View {

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
        return isDangerState ? Color.appRed : Color.appPurple
    }

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
        VStack(spacing: 10) {
            Text(String(localized: "workout.streak.title", bundle: .module))
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 15)
            ZStack {
                Image("streak", bundle: .module)
                    .renderingMode(.template)
                    .foregroundStyle(accentColor)
                    .scaleEffect(0.23)
                Text("\(value)")
                    .foregroundStyle(.white)
                    .font(.system(size: 50))
                    .fontWeight(.semibold)
                    .offset(y: 15)
            }
            .frame(width: 130, height: 130)

            SegmentedPillProgress(
                total: total,
                current: current,
                daysLeft: daysLeft,
                color: accentColor
            )

            Text(streakText)
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appDarkGray.ignoresSafeArea(.all))
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
        VStack {
            HStack(spacing: spacing) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < current ? color: Color.white.opacity(0.18))
                        .overlay(
                            Capsule()
                                .stroke(borderGradient, lineWidth: 0.5)
                        )
                        .overlay(
                            Capsule()
                                .fill(highlightGradient)
                                .blendMode(.screen)
                        )
                        .frame(height: height)
                }
            }

            Text(WorkoutL10n.streakDaysLeft(daysLeft))
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.all, 7)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 15)
    }
}
