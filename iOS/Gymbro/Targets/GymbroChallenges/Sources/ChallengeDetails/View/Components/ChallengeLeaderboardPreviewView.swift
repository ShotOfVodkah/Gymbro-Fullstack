import SwiftUI
import GymbroTypes

struct ChallengeLeaderboardPreviewView: View {
    
    let teams: [ChallengeLeaderboardTeamModel]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                sectionTitle(
                    String(localized: "challenges.preview.leaderboard_title", bundle: .module),
                    String(localized: "challenges.preview.leaderboard_subtitle", bundle: .module)
                )
                
                Spacer()
                
                Button(String(localized: "challenges.preview.view_all", bundle: .module)) {
                    onTap()
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.purple.opacity(0.95))
                .accessibilityIdentifier("challenges.details.leaderboard.viewAll")
            }
            
            VStack(spacing: 10) {
                ForEach(teams) { team in
                    HStack(spacing: 12) {
                        Text("#\(team.rank)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(team.rank == 1 ? .yellow : .white.opacity(0.58))
                            .frame(width: 34, alignment: .leading)
                        
                        Image(systemName: team.teamAvatar)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(team.isCurrentUserTeam ? .purple : .white.opacity(0.72))
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(team.isCurrentUserTeam ? .purple.opacity(0.16) : .white.opacity(0.07))
                            )
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(team.teamName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("\(team.currentValue)/\(team.targetValue)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        
                        Spacer()
                        
                        Text("\(Int(team.progressPercent * 100))%")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .padding(13)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(team.isCurrentUserTeam ? .purple.opacity(0.12) : .white.opacity(0.06))
                    )
                }
            }
        }
    }
}
