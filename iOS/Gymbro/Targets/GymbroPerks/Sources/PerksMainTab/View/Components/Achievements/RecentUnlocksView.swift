import SwiftUI
import GymbroTypes

struct RecentUnlocksView: View {
    
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            if achievements.isEmpty {
                emptyView
            } else {
                unlocksView
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
        .accessibilityIdentifier("perks.recentUnlocks.section")
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Recent Unlocks")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Your latest earned achievements")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.64))
        }
    }
    
    // MARK: - Content
    
    private var unlocksView: some View {
        HStack(spacing: 10) {
            ForEach(Array(achievements.prefix(3))) { achievement in
                recentUnlockCard(achievement)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var emptyView: some View {
        Text("No achievements unlocked yet.")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white.opacity(0.58))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(emptyCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
    
    // MARK: - Card
    
    private func recentUnlockCard(_ achievement: Achievement) -> some View {
        GeometryReader { proxy in
            let side = proxy.size.width
            
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: side * 0.36, height: side * 0.36)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: side * 0.2, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 4) {
                    Text(achievement.category.title.uppercased())
                        .font(.system(size: side * 0.075, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    Text(achievement.name)
                        .font(.system(size: side * 0.105, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.55)
                    
                    Text(achievement.rarity.title.uppercased())
                        .font(.system(size: side * 0.075, weight: .bold))
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(10)
            .frame(width: side, height: side)
            .background(cardBackground(for: achievement))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(cardBorder)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Styles
    
    private func cardBackground(for achievement: Achievement) -> some View {
        LinearGradient(
            colors: [
                categoryColor(for: achievement.rarity),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var emptyCardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.7)
    }
    
    private var sectionBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.7)
    }
    
    private var sectionBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.42),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.42),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    
    // MARK: - Colors
    
    private func categoryColor(for category: AchievementRarity) -> Color {
        switch category {
        case .common:
            return .green
        case .rare:
            return .blue
        case .epic:
            return .orange
        case .legendary:
            return .yellow
        }
    }
}
