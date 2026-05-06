import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct WeeklyStreakCardView: View {
    
    let streak: StreakState
    let onChangeGoal: () -> Void
    let onUseFreeze: () -> Void
    
    @State private var freezePulse = false
    
    private var progress: Double {
        guard streak.weeklyGoal > 0 else { return 0 }
        return min(Double(streak.completedThisWeek) / Double(streak.weeklyGoal), 1)
    }
    
    private var daysLeft: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: streak.weekEndDate)
        return max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
    }
    
    private var isDangerState: Bool {
        !streak.isGoalCompleted && !streak.wasFreezeUsedThisWeek && daysLeft <= 2
    }
    
    private var accentGradient: LinearGradient {
        if streak.wasFreezeUsedThisWeek {
            return LinearGradient(
                colors: [
                    Color.cyan.opacity(0.95),
                    Color.blue.opacity(0.72)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        if streak.isGoalCompleted {
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
                Color.orange.opacity(0.95),
                Color.yellow.opacity(0.82)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var accentColor: Color {
        if streak.wasFreezeUsedThisWeek { return .cyan }
        if streak.isGoalCompleted { return .green }
        if isDangerState { return .red }
        return .orange
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerView
            progressView
            statsView
            
            if streak.hasPendingGoalChange, let nextGoal = streak.nextWeeklyGoal {
                pendingGoalView(nextGoal: nextGoal)
            }
            
            freezeView
            actionsView
            footerView
        }
        .padding(20)
        .background(cardBackground)
        .overlay(iceOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "perks.streak.card")
        }
        .scaleEffect(freezePulse ? 1.018 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: freezePulse)
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Weekly Streak")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(headerSubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.64))
                    .lineLimit(2)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accentColor)
            }
        }
    }
    
    private var headerSubtitle: String {
        if streak.wasFreezeUsedThisWeek {
            return "Your streak is protected with a freeze."
        }
        
        if streak.isGoalCompleted {
            return "Goal completed this week."
        }
        
        if isDangerState {
            return "\(daysLeft) day\(daysLeft == 1 ? "" : "s") left and \(streak.remainingToGoal) workout\(streak.remainingToGoal == 1 ? "" : "s") still needed."
        }
        
        return "\(streak.remainingToGoal) workout\(streak.remainingToGoal == 1 ? "" : "s") left to keep the fire alive."
    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text("\(streak.completedThisWeek)")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(accentColor)
                
                Text("/ \(streak.weeklyGoal)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white.opacity(0.58))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                    
                    Text("\(daysLeft)d left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isDangerState ? .red.opacity(0.92) : .white.opacity(0.48))
                }
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.10))
                    
                    Capsule()
                        .fill(accentGradient)
                        .frame(width: proxy.size.width * progress)
                        .shadow(color: accentColor.opacity(0.45), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 12)
            
            Text("Weekly goal progress")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.48))
        }
    }
    
    private var statsView: some View {
        HStack(spacing: 10) {
            statPill(
                title: "Current",
                value: "\(streak.currentStreakWeeks)w",
                iconName: "flame.circle.fill"
            )
            
            statPill(
                title: "Best",
                value: "\(streak.bestStreakWeeks)w",
                iconName: "crown.fill"
            )
            
            statPill(
                title: "Goal",
                value: "\(streak.weeklyGoal)/week",
                iconName: "target"
            )
        }
    }
    
    private func pendingGoalView(nextGoal: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Goal scheduled")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Next week your goal will be \(nextGoal) workout\(nextGoal == 1 ? "" : "s").")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.yellow.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.yellow.opacity(0.18), lineWidth: 1)
        )
    }
    
    private var freezeView: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.cyan.opacity(streak.wasFreezeUsedThisWeek ? 0.28 : 0.16))
                    .frame(width: 42, height: 42)
                
                Image(systemName: "snowflake")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.cyan)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(streak.wasFreezeUsedThisWeek ? "Freezed this week" : "Streak Freeze")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(streak.wasFreezeUsedThisWeek ? "Your streak is protected." : "\(streak.streakFreezeCount) freeze\(streak.streakFreezeCount == 1 ? "" : "s") available")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                
                if streak.wasFreezeUsedThisWeek {
                    Text("\(streak.streakFreezeCount) freeze\(streak.streakFreezeCount == 1 ? "" : "s") remaining")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.cyan.opacity(0.82))
                }
            }
            
            Spacer()
            
            Button {
                freezePulse = true
                onUseFreeze()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    freezePulse = false
                }
            } label: {
                Text(streak.wasFreezeUsedThisWeek ? "Used" : "Use")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(streak.canUseStreakFreeze ? .white : .white.opacity(0.38))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(streak.canUseStreakFreeze ? .cyan.opacity(0.24) : .white.opacity(0.08))
                    )
            }
            .disabled(!streak.canUseStreakFreeze || streak.wasFreezeUsedThisWeek)
            .accessibilityIdentifier("perks.streak.freeze.use")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(streak.wasFreezeUsedThisWeek ? .cyan.opacity(0.11) : .white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(streak.wasFreezeUsedThisWeek ? .cyan.opacity(0.22) : .white.opacity(0.04), lineWidth: 1)
        )
    }
    
    private var actionsView: some View {
        Button {
            onChangeGoal()
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                
                Text("Change weekly goal")
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("perks.streak.changeGoal")
    }
    
    private var footerView: some View {
        HStack(spacing: 8) {
            Image(systemName: footerIconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(footerColor)
            
            Text(footerText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))
            
            Spacer()
        }
        .overlay(alignment: .leading) {
            UITestMarker(id: streakStateAccessibilityId)
        }
    }

    private var streakStateAccessibilityId: String {
        if streak.wasFreezeUsedThisWeek { return "perks.streak.state.freeze" }
        if streak.isGoalCompleted { return "perks.streak.state.completed" }
        if isDangerState { return "perks.streak.state.danger" }
        return "perks.streak.state.normal"
    }
    
    private var footerIconName: String {
        if streak.wasFreezeUsedThisWeek { return "snowflake.circle.fill" }
        if streak.isGoalCompleted { return "checkmark.seal.fill" }
        if isDangerState { return "exclamationmark.triangle.fill" }
        return "clock.fill"
    }
    
    private var footerColor: Color {
        if streak.wasFreezeUsedThisWeek { return .cyan }
        if streak.isGoalCompleted { return .green }
        if isDangerState { return .red }
        return .white.opacity(0.56)
    }
    
    private var footerText: String {
        if streak.wasFreezeUsedThisWeek {
            return "Freeze protected your streak this week."
        }
        
        if streak.isGoalCompleted {
            return "Your streak is safe this week."
        }
        
        return "\(streak.remainingToGoal) more workout\(streak.remainingToGoal == 1 ? "" : "s") needed in \(daysLeft) day\(daysLeft == 1 ? "" : "s")."
    }
    
    private func statPill(
        title: String,
        value: String,
        iconName: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.56))
            
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.04), lineWidth: 1)
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: cardBackgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.7)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                accentColor,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var cardBackgroundColors: [Color] {
        if streak.wasFreezeUsedThisWeek {
            return [
                Color(red: 18 / 255, green: 32 / 255, blue: 46 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        }
        
        if streak.isGoalCompleted {
            return [
                Color(red: 18 / 255, green: 44 / 255, blue: 34 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        }
        
        if isDangerState {
            return [
                Color(red: 44 / 255, green: 18 / 255, blue: 32 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ]
        }
        
        return [
            Color(red: 44 / 255, green: 28 / 255, blue: 18 / 255),
            Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
        ]
    }
    
    @ViewBuilder
    private var iceOverlay: some View {
        if streak.wasFreezeUsedThisWeek {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.85),
                            Color.white.opacity(0.55),
                            Color.cyan.opacity(0.25),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .overlay(alignment: .topLeading) {
                    iceCorner(rotation: 0)
                        .padding(8)
                }
                .overlay(alignment: .topTrailing) {
                    iceCorner(rotation: 90)
                        .padding(8)
                }
                .overlay(alignment: .bottomLeading) {
                    iceCorner(rotation: -90)
                        .padding(8)
                }
                .overlay(alignment: .bottomTrailing) {
                    iceCorner(rotation: 180)
                        .padding(8)
                }
                .allowsHitTesting(false)
        }
    }
    
    private func iceCorner(rotation: Double) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.78),
                                Color.cyan.opacity(0.22)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5, height: CGFloat(18 + index * 7))
                    .offset(x: CGFloat(index * 8), y: CGFloat(index * 3))
                    .rotationEffect(.degrees(Double(index * 9)))
            }
        }
        .frame(width: 52, height: 52, alignment: .topLeading)
        .rotationEffect(.degrees(rotation))
        .blur(radius: 0.15)
    }
}
