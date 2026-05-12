import SwiftUI
import GymbroTypes

struct ChallengeTeamSectionView: View {
    
    let details: ChallengeDetailsModel
    let onActionTap: () -> Void
    let onJoinAnotherTeamTap: () -> Void
    
    private var team: ChallengeTeamModel? {
        details.team
    }
    
    private var title: String {
        if details.participationStatus == .notJoined {
            return String(localized: "challenges.details.team.choose_title", bundle: .module)
        }
        return String(localized: "challenges.details.team.title", bundle: .module)
    }
    
    private var subtitle: String {
        if details.participationStatus == .notJoined {
            return String(localized: "challenges.details.team.choose_subtitle", bundle: .module)
        }
        return String(localized: "challenges.details.team.joined_subtitle", bundle: .module)
    }
    
    private var buttonTitle: String {
        if details.participationStatus == .notJoined {
            return String(localized: "challenges.details.team.join_button", bundle: .module)
        }
        return String(localized: "challenges.details.team.open_chat", bundle: .module)
    }
    
    private var buttonIcon: String {
        if details.participationStatus == .notJoined {
            return "plus.circle.fill"
        }
        
        return "bubble.left.and.bubble.right.fill"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle(title, subtitle)
            
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(details.accentColor.opacity(0.18))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: team?.teamAvatar ?? "person.3.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(details.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team?.teamName ?? String(localized: "challenges.details.team.select_chat_placeholder", bundle: .module))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(teamDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.56))
                }
                
                Spacer()
                
                Button {
                    onActionTap()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: buttonIcon)
                            .font(.system(size: 13, weight: .bold))
                        
                        Text(buttonTitle)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(details.accentColor.opacity(0.22))
                    )
                    .overlay(
                        Capsule()
                            .stroke(details.accentColor.opacity(0.28), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(baseCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.07), lineWidth: 1)
            )
        }
    }
    
    private var teamDescription: String {
        if let team {
            return String(
                format: String(localized: "challenges.details.team.members_progress", bundle: .module),
                locale: .current,
                team.membersCount,
                Int(team.progressPercent * 100)
            )
        }
        return String(localized: "challenges.details.team.empty_hint", bundle: .module)
    }
}
