import SwiftUI
import GymbroTypes

struct ChallengeSectionView: View {
    
    let title: String
    let subtitle: String
    let challenges: [ChallengeCardModel]
    let onTap: (ChallengeCardModel) -> Void
    let onJoinTap: (ChallengeCardModel) -> Void
    
    var body: some View {
        if !challenges.isEmpty {
            VStack(alignment: .leading, spacing: 13) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.52))
                }
                
                VStack(spacing: 12) {
                    ForEach(challenges) { challenge in
                        ChallengeCardView(
                            challenge: challenge,
                            onTap: {
                                onTap(challenge)
                            },
                            onJoinTap: challenge.isJoined ? nil : {
                                onJoinTap(challenge)
                            }
                        )
                    }
                }
            }
        }
    }
}
