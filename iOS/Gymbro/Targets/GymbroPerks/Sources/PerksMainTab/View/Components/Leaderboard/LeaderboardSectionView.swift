import SwiftUI
import GymbroTypes

struct LeaderboardSectionView: View {
    
    let entries: [LeaderboardEntry]
    let myRank: MyRank?
    
    let onFilterChanged: (LeaderboardFilter) -> Void
    let onSortChanged: (LeaderboardSort) -> Void
    
    @State private var selectedFilter: LeaderboardFilter = .all
    @State private var selectedSort: LeaderboardSort = .streak
    
    private var visibleEntries: [LeaderboardEntry] {
        let filteredEntries: [LeaderboardEntry]
        
        switch selectedFilter {
        case .all:
            filteredEntries = entries
        case .following:
            filteredEntries = entries.filter { $0.isFollowing || $0.isCurrentUser }
        case .friends:
            filteredEntries = entries.filter { $0.isFriend || $0.isCurrentUser }
        }
        
        let sortedEntries: [LeaderboardEntry]
        
        switch selectedSort {
        case .streak:
            sortedEntries = filteredEntries.sorted { $0.currentStreakWeeks > $1.currentStreakWeeks }
        case .workouts:
            sortedEntries = filteredEntries.sorted { $0.completedWorkouts > $1.completedWorkouts }
        }
        
        return sortedEntries.enumerated().map { index, entry in
            LeaderboardEntry(
                id: entry.id,
                rank: index + 1,
                userID: entry.userID,
                name: entry.name,
                username: entry.username,
                avatarSystemName: entry.avatarSystemName,
                currentStreakWeeks: entry.currentStreakWeeks,
                completedWorkouts: entry.completedWorkouts,
                isCurrentUser: entry.isCurrentUser,
                isFollowing: entry.isFollowing,
                isFriend: entry.isFriend
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            filterPickerView
            sortPickerView
            
            if let myRank {
                MyRankCardView(myRank: myRank)
            }
            
            if visibleEntries.isEmpty {
                emptyLeaderboardView
            } else {
                leaderboardPreviewView
            }
        }
        .padding(20)
        .background(sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(sectionBorder)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Leaderboard")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Compare your streak and workout progress")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.64))
        }
    }
    
    private var filterPickerView: some View {
        HStack(spacing: 10) {
            ForEach(LeaderboardFilter.allCases) { filter in
                pickerChip(
                    title: filter.title,
                    isSelected: selectedFilter == filter
                ) {
                    selectedFilter = filter
                    onFilterChanged(filter)
                }
            }
        }
    }
    
    private var sortPickerView: some View {
        HStack(spacing: 10) {
            ForEach(LeaderboardSort.allCases) { sort in
                pickerChip(
                    title: sort.title,
                    isSelected: selectedSort == sort
                ) {
                    selectedSort = sort
                    onSortChanged(sort)
                }
            }
        }
    }
    
    private func pickerChip(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple.opacity(0.4) : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
    
    private var leaderboardPreviewView: some View {
        VStack(spacing: 10) {
            ForEach(visibleEntries.prefix(5)) { entry in
                LeaderboardRowView(
                    entry: entry,
                    selectedSort: selectedSort
                )
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
    
    private var emptyLeaderboardView: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("No users found")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Try switching the leaderboard filter.")
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
