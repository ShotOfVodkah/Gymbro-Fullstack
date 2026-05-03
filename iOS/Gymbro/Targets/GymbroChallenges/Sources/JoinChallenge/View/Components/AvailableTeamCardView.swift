import SwiftUI
import GymbroTypes

struct AvailableTeamCardView: View {
    
    let team: AvailableChallengeTeamModel
    let onTap: () -> Void
    
    private var accentColor: Color {
        team.canJoin ? .blue : .red
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: team.avatarSystemName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(team.chatName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("\(team.membersCount) members")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.56))
                    
                    if let reason = team.reason, !team.canJoin {
                        Text(reason)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.red.opacity(0.82))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if team.canJoin {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.48))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white.opacity(0.34))
                }
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        team.canJoin ? .white.opacity(0.07) : .red.opacity(0.52),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!team.canJoin)
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255).opacity(team.canJoin ? 0.76 : 0.52),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255).opacity(team.canJoin ? 0.62 : 0.42)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
