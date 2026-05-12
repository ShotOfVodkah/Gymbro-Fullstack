import Foundation
import SwiftUI
import GymbroTypes

struct LeaderboardPodiumCardView: View {
    
    let team: ChallengeLeaderboardTeamModel
    let onTap: () -> Void
    
    private var rankColor: Color {
        switch team.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .white.opacity(0.6)
        }
    }
    
    private var rankIcon: String {
        switch team.rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "star.fill"
        default: return "number"
        }
    }
    
    var body: some View {
        Button {
            guard team.isCurrentUserTeam else { return }
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(rankColor.opacity(0.18))
                            .frame(width: 58, height: 58)
                        
                        Image(systemName: rankIcon)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(rankColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Text("#\(team.rank)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(rankColor)
                            
                            Text(team.teamName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        
                        Text(String(format: String(localized: "challenges.join.members_count", bundle: .module), team.membersCount))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.56))
                    }
                    
                    Spacer()
                    
                    Image(systemName: team.teamAvatar)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(team.isCurrentUserTeam ? .purple : .white.opacity(0.64))
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(team.isCurrentUserTeam ? .purple.opacity(0.15) : .white.opacity(0.07))
                        )
                }
                
                LeaderboardProgressView(team: team, color: rankColor)
                
                HStack {
                    LeaderboardStatusBadgeView(status: team.status)
                    
                    if team.isCurrentUserTeam {
                        Text(String(localized: "challenges.leaderboard.your_team", bundle: .module))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.purple.opacity(0.14)))
                    }
                    
                    Spacer()
                    
                    if team.isCurrentUserTeam {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.44))
                    }
                }
            }
            .padding(18)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.18),
                                rankColor.opacity(0.42),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                rankColor.opacity(team.rank == 1 ? 0.17 : 0.11),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
