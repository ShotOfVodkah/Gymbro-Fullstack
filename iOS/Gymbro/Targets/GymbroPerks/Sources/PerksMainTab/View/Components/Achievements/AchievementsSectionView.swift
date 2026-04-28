import SwiftUI
import GymbroTypes

struct AchievementsSectionView: View {
    
    let achievements: [Achievement]
    let onAchievementOpened: (Achievement) -> Void
    
    @State private var selectedCategory: AchievementCategory = .all
    @State private var selectedAchievement: Achievement?
    
    private var filteredAchievements: [Achievement] {
        selectedCategory == .all
        ? achievements
        : achievements.filter { $0.category == selectedCategory }
    }
    
    private var pages: [[Achievement]] {
        stride(from: 0, to: filteredAchievements.count, by: 6).map {
            Array(filteredAchievements[$0..<min($0 + 6, filteredAchievements.count)])
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                categoryChipsView
                if filteredAchievements.isEmpty {
                    emptyAchievementsView
                } else {
                    achievementsPagerView
                }
            }
            .padding(20)
            .background(sectionBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(sectionBorder)
            .opacity(selectedAchievement == nil ? 1 : 0.22)
            
            if let selectedAchievement {
                AchievementExpandedCardView(
                    achievement: selectedAchievement,
                    onClose: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            self.selectedAchievement = nil
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.25).combined(with: .opacity),
                    removal: .scale(scale: 0.92).combined(with: .opacity)
                ))
                .zIndex(2)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: selectedAchievement)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Achievements")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            Text("\(achievements.filter { $0.isUnlocked }.count)/\(achievements.count) unlocked")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.64))
        }
    }
    
    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AchievementCategory.allCases) { category in
                    categoryChip(category)
                }
            }
        }
    }
    
    private func categoryChip(_ category: AchievementCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedCategory = category
                selectedAchievement = nil
            }
        } label: {
            Text(category.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(selectedCategory == category ? Color.purple.opacity(0.4) : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
    
    private var achievementsPagerView: some View {
        TabView {
            ForEach(Array(pages.enumerated()), id: \.offset) { _, page in
                achievementPage(page)
            }
        }
        .frame(height: 222)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private func achievementPage(_ achievements: [Achievement]) -> some View {
        VStack(spacing: 10) {
            achievementRow(Array(achievements.prefix(3)))
            achievementRow(Array(achievements.dropFirst(3).prefix(3)))
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func achievementRow(_ achievements: [Achievement]) -> some View {
        HStack(spacing: 10) {
            ForEach(achievements) { achievement in
                AchievementCardView(
                    achievement: achievement,
                    isSelected: selectedAchievement?.id == achievement.id,
                    onTap: {
                        onAchievementOpened(achievement)
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            selectedAchievement = achievement
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
            
            if achievements.count < 3 {
                ForEach(0..<(3 - achievements.count), id: \.self) { _ in
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
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
    
    private var emptyAchievementsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("No achievements here yet")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Try another category or keep training to unlock more.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
    }
}
