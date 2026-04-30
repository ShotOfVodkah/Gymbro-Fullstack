import SwiftUI
import GymbroTypes

struct ChatChallengeSystemMessageCardView: View {
    
    let message: ChatMessage
    let onTap: () -> Void
    let onReactionTap: (String) -> Void
    let onLongPress: () -> Void
    
    private var accentColor: Color {
        guard case .challengeSystem(_, _, _, let status) = message.kind else {
            return .orange
        }
        return status.accentColor
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: 24)
            
            VStack(alignment: .leading, spacing: 10) {
                challengeCard
                    .onTapGesture {
                        onTap()
                    }
                    .onLongPressGesture {
                        onLongPress()
                    }
                
                if !message.reactions.isEmpty {
                    MessageReactionsView(
                        reactions: message.reactions,
                        onReactionTap: onReactionTap
                    )
                    .padding(.leading, 10)
                }
            }
            
            Spacer(minLength: 24)
        }
    }
    
    private var challengeCard: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 46, height: 46)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(systemText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
                
                Text("Tap to open challenge")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.15),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
    
    private var title: String {
        if case .challengeSystem(_, let title, _, _) = message.kind {
            return title
        }
        return ""
    }
    
    private var systemText: String {
        if case .challengeSystem(_, _, let message, _) = message.kind {
            return message
        }
        return ""
    }
    
    private var iconName: String {
        guard case .challengeSystem(_, _, _, let status) = message.kind else {
            return "flag.checkered"
        }
        
        switch status {
        case .notJoined:
            return "flag.checkered"
        case .inProgress:
            return "flame.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .failed:
            return "xmark.seal.fill"
        }
    }
}
