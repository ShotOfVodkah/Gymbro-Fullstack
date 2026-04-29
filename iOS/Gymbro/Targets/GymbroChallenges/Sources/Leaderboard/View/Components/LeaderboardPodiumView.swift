import SwiftUI
import GymbroTypes

struct LeaderboardPodiumView: View {
    
    let teams: [ChallengeLeaderboardTeamModel]
    let onTap: (ChallengeLeaderboardTeamModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Top Teams")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("The current podium of this challenge")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.52))
            }
            
            VStack(spacing: 12) {
                ForEach(teams) { team in
                    LeaderboardPodiumCardView(team: team) {
                        onTap(team)
                    }
                }
            }
        }
    }
}
