import SwiftUI
import GymbroTypes

struct JoinChallengeConfirmationView: View {
    
    let team: AvailableChallengeTeamModel
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.blue.opacity(0.18))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: team.avatarSystemName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "challenges.join.confirm.title", bundle: .module))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text(team.chatName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
                Text(String(localized: "challenges.join.confirm.body", bundle: .module))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 10) {
                    Button {
                        onCancel()
                    } label: {
                        Text(String(localized: "challenges.join.confirm.cancel", bundle: .module))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white.opacity(0.76))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.white.opacity(0.08))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("challenges.join.confirm.cancel")
                    
                    Button {
                        onConfirm()
                    } label: {
                        Text(String(localized: "challenges.join.confirm.join", bundle: .module))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.blue.opacity(0.32))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.blue.opacity(0.24), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("challenges.join.confirm")
                }
            }
            .padding(20)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 12 / 255, green: 18 / 255, blue: 36 / 255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
