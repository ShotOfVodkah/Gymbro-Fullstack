import SwiftUI
import GymbroTypes

struct LeaderboardRowView: View {
    
    let entry: LeaderboardEntry
    let selectedSort: LeaderboardSort
    
    var body: some View {
        HStack(spacing: 12) {
            rankView(entry.rank)
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 46, height: 46)
                
                Image(systemName: entry.avatarSystemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("@\(entry.username)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.54))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(selectedSort == .streak ? "\(entry.currentStreakWeeks)w" : "\(entry.completedWorkouts)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(selectedSort == .streak ? "streak" : "workouts")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.48))
                    .textCase(.uppercase)
            }
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(cardBorder)
    }
    
    private func rankView(_ rank: Int) -> some View {
        Text("#\(rank)")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(rankColor(rank))
            .frame(width: 38, alignment: .leading)
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return .yellow
        case 2:
            return .white.opacity(0.9)
        case 3:
            return .orange
        default:
            return .white.opacity(0.58)
        }
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                entry.isCurrentUser
                ? Color.appPurple.opacity(0.3)
                : Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(entry.isCurrentUser ? 0.42 : 0.18),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}
