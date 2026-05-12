import Foundation
import SwiftUI
import GymbroTypes

struct PerksDashboardView: View {
    
    let dashboard: PerksDashboard
    let onOpenStreakSettings: () -> Void
    let onUseStreakFreeze: () -> Void
    let onRefresh: () async -> Void
    let onAchievementOpened: (Achievement) -> Void
    let onLeaderboardSelectionChanged: (LeaderboardFilter, LeaderboardSort) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                streakSection
                
                recentUnlocksSection
                
                achievementsSection
                
                leaderboardSection
            }
            .padding(.horizontal, 15)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .refreshable {
            await onRefresh()
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "perks.dashboard.title", bundle: .module))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
            
            Text(String(localized: "perks.dashboard.subtitle", bundle: .module))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var streakSection: some View {
        WeeklyStreakCardView(streak: dashboard.streak,
                             onChangeGoal: onOpenStreakSettings,
                             onUseFreeze: onUseStreakFreeze
        )
    }
    
    private var recentUnlocksSection: some View {
        RecentUnlocksView(achievements: dashboard.recentUnlocks)
    }
    
    private var achievementsSection: some View {
        AchievementsSectionView(achievements: dashboard.achievements,
                                onAchievementOpened: onAchievementOpened)
    }
    
    private var leaderboardSection: some View {
        LeaderboardSectionView(
            entries: dashboard.leaderboardPreview,
            myRank: dashboard.myRank,
            onSelectionChanged: { filter, sort in onLeaderboardSelectionChanged(filter, sort) }
        )
    }
    
    private func dashboardBlock(
        title: String,
        subtitle: String,
        iconName: String
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.10))
                    .frame(width: 52, height: 52)
                
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.075))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
}
