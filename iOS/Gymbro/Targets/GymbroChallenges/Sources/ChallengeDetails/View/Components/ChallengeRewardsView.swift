import SwiftUI
import GymbroTypes

struct ChallengeRewardsView: View {
    
    let rewards: [ChallengeRewardModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle(
                String(localized: "challenges.details.rewards.title", bundle: .module),
                String(localized: "challenges.details.rewards.subtitle", bundle: .module)
            )
            
            VStack(spacing: 10) {
                ForEach(rewards) { reward in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(reward.isUnlocked ? .green.opacity(0.16) : .white.opacity(0.07))
                                .frame(width: 46, height: 46)
                            
                            Image(systemName: reward.iconName)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(reward.isUnlocked ? .green : .white.opacity(0.72))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(reward.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text(reward.description)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        
                        Spacer()
                    }
                    .padding(13)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                }
            }
        }
    }
}
