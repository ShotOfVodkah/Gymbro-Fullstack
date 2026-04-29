import SwiftUI
import GymbroTypes

struct ChallengeHeaderView: View {
    
    let details: ChallengeDetailsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(details.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(details.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.64))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(details.accentColor.opacity(0.18))
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: details.iconName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(details.accentColor)
                }
            }
            
            HStack(spacing: 8) {
                ChallengeStatusBadgeView(status: details.participationStatus)
                ChallengeDifficultyBadgeView(difficulty: details.difficulty)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(details.accentColor)
                
                Text(details.dateRangeText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.62))
                
                Spacer()
                
                Text(details.timeLeftText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(details.accentColor)
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        details.accentColor.opacity(0.18),
                        Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.22),
                                details.accentColor.opacity(0.78),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
