import SwiftUI
import GymbroTypes

struct ChallengeParticipantsView: View {
    
    let participants: [ChallengeParticipantModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle(
                String(localized: "challenges.details.participants.title", bundle: .module),
                String(localized: "challenges.details.participants.subtitle", bundle: .module)
            )
            
            VStack(spacing: 10) {
                ForEach(participants.sorted { $0.rankInTeam < $1.rankInTeam }) { participant in
                    HStack(spacing: 12) {
                        Text("#\(participant.rankInTeam)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.58))
                            .frame(width: 32, alignment: .leading)
                        
                        ZStack {
                            Circle()
                                .fill(participant.isMVP ? .yellow.opacity(0.18) : .white.opacity(0.08))
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: participant.avatarSystemName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(participant.isMVP ? .yellow : .white.opacity(0.76))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(participant.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                if participant.isMVP {
                                    Text(String(localized: "challenges.details.participants.mvp", bundle: .module))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.yellow)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(.yellow.opacity(0.14)))
                                }
                            }
                            
                            Text("\(participant.contributionValue) \(participant.contributionUnit.rawValue)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        
                        Spacer()
                    }
                    .padding(13)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(participant.isMVP ? 0.09 : 0.06))
                    )
                }
            }
        }
    }
}
