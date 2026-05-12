import Foundation
import SwiftUI
import GymbroTypes

struct LeaderboardTeamRowView: View {
    
    let team: ChallengeLeaderboardTeamModel
    let onTap: () -> Void
    
    private var accentColor: Color {
        team.isCurrentUserTeam ? .purple : team.status.accentColor
    }
    
    var body: some View {
        Button {
            guard team.isCurrentUserTeam else { return }
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 12) {
                    Text("#\(team.rank)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(team.rank <= 3 ? podiumColor : .white.opacity(0.58))
                        .frame(width: 38, alignment: .leading)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accentColor.opacity(0.16))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: team.teamAvatar)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(team.teamName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        
                        Text(String(format: String(localized: "challenges.join.members_count", bundle: .module), team.membersCount))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.52))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(Int(team.progressPercent * 100))%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("\(team.currentValue)/\(team.targetValue)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                LeaderboardProgressView(team: team, color: accentColor)
                
                HStack {
                    LeaderboardStatusBadgeView(status: team.status)
                    if team.isCurrentUserTeam {
                        Text(String(localized: "challenges.leaderboard.you", bundle: .module))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.purple.opacity(0.14))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.purple.opacity(0.24), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    if team.isCurrentUserTeam {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.38))
                    }
                }
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(team.isCurrentUserTeam ? .purple.opacity(0.26) : .white.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var podiumColor: Color {
        switch team.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .white.opacity(0.58)
        }
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                accentColor.opacity(team.isCurrentUserTeam ? 0.15 : 0.08),
                Color(red: 19 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.68)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
