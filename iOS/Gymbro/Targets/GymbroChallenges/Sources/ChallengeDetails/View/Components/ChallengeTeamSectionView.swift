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
            return "Choose Team"
        }
        
        return "Team"
    }
    
    private var subtitle: String {
        if details.participationStatus == .notJoined {
            return "Pick one of your group chats to join this challenge"
        }
        
        return "Group chat participating in this challenge"
    }
    
    private var buttonTitle: String {
        if details.participationStatus == .notJoined {
            return "Join"
        }
        
        return "Open Chat"
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
                    Text(team?.teamName ?? "Select group chat")
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
            
            if details.participationStatus == .inProgress {
                Button {
                    onJoinAnotherTeamTap()
                } label: {
                    HStack(spacing: 9) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text("Join with another team")
                            .font(.system(size: 14, weight: .bold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(details.accentColor)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(details.accentColor.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(details.accentColor.opacity(0.18), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var teamDescription: String {
        if let team {
            return "\(team.membersCount) members • \(Int(team.progressPercent * 100))% completed"
        }
        
        return "Your group chat will become the challenge team"
    }
}
