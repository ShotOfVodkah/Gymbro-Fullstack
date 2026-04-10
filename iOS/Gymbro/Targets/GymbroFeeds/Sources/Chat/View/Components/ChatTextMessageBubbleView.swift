import SwiftUI

struct ChatTextMessageBubbleView: View {
    
    let message: ChatMessage
    let onReactionTap: (String) -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        HStack {
            if message.isMine {
                Spacer(minLength: 44)
            }
            
            VStack(alignment: message.isMine ? .trailing : .leading) {
                Text(messageText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .onLongPressGesture { onLongPress() }
                HStack {
                    if !message.reactions.isEmpty {
                        MessageReactionsView(
                            reactions: message.reactions,
                            onReactionTap: onReactionTap
                        )
                    }
                    if !message.isMine {
                        Spacer()
                        Text(message.senderName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            if !message.isMine {
                Spacer(minLength: 44)
            }
        }
    }
    
    private var messageText: String {
        if case .text(let text) = message.kind {
            return text
        }
        return ""
    }
    
    private var bubbleBackground: some ShapeStyle {
        if message.isMine {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.appPurple.opacity(0.7), Color.purple.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyShapeStyle(Color.white.opacity(0.07))
        }
    }
}
