import SwiftUI
import GymbroTypes

struct LeaderboardStatusBadgeView: View {
    
    let status: ChallengeParticipationStatus
    
    var body: some View {
        Text(status.title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(status.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(status.accentColor.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(status.accentColor.opacity(0.24), lineWidth: 1)
            )
    }
}
