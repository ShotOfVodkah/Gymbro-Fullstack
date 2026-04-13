import SwiftUI
import GymbroTypes

struct ChatWorkoutMessageCardView: View {
    
    let message: ChatMessage
    let onTap: () -> Void
    let onReactionTap: (String) -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        HStack {
            if message.isMine {
                Spacer(minLength: 30)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                if !message.isMine {
                    Text(message.senderName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.leading, 14)
                }
                
                workoutCard
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
            
            if !message.isMine {
                Spacer(minLength: 30)
            }
        }
    }
    
    private var workoutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutTitle)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(workoutSubtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.68))
                    HStack(spacing: 8) {
                        tag(workoutCategory)
                        tag(workoutDuration)
                        Spacer()
                        Text("Tap for more info")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.68))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var workoutTitle: String {
        if case .workout(_, let title, _, _, _) = message.kind { return title }
        return ""
    }
    
    private var workoutSubtitle: String {
        if case .workout(_, _, let subtitle, _, _) = message.kind { return subtitle }
        return ""
    }
    
    private var workoutDuration: String {
        if case .workout(_, _, _, let duration, _) = message.kind { return duration }
        return ""
    }
    
    private var workoutCategory: String {
        if case .workout(_, _, _, _, let category) = message.kind { return category }
        return ""
    }
    
    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.88))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.appPurple.opacity(0.22))
            .clipShape(Capsule())
    }
}
