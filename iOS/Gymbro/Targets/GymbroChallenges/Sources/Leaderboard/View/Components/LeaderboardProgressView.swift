import SwiftUI
import GymbroTypes

struct LeaderboardProgressView: View {
    
    let team: ChallengeLeaderboardTeamModel
    let color: Color
    
    private var progress: Double {
        min(max(team.progressPercent, 0), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.10))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.95),
                                    color.opacity(0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress)
                        .shadow(color: color.opacity(0.35), radius: 7)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("\(team.currentValue) current")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.48))
                
                Spacer()
                
                Text("\(team.targetValue) target")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.48))
            }
        }
    }
}
