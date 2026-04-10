import SwiftUI

struct MessageReactionsView: View {
    
    let reactions: [ChatReaction]
    let onReactionTap: (String) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(reactions) { reaction in
                Button {
                    onReactionTap(reaction.emoji)
                } label: {
                    HStack(spacing: 4) {
                        Text(reaction.emoji)
                        Text("\(reaction.count)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(reaction.isSelectedByMe ? Color.appPurple.opacity(0.45) : Color.white.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
