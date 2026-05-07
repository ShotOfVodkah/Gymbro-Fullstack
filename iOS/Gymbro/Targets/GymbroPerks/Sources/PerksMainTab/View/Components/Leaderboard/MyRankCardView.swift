import SwiftUI
import GymbroTypes

struct MyRankCardView: View {
    
    let myRank: MyRank
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Your Rank")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("#\(myRank.rank) • \(myRank.currentStreakWeeks)w streak • \(myRank.completedWorkouts) workouts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(LinearGradient(
            colors: [Color.appPurple.opacity(0.3), Color.purple.opacity(0.3)],
            startPoint: .leading,
            endPoint: .trailing
        ))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(cardBorder)
        .accessibilityIdentifier("perks.leaderboard.myRank")
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.24),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
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
}
