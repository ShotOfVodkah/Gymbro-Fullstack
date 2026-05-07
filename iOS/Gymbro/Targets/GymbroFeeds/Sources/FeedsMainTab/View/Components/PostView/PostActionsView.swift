import SwiftUI

struct PostActionsView: View {
    
    let postID: String
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
    let onLikeTap: () -> Void
    let onCommentTap: () -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            Button(action: onLikeTap) {
                HStack(spacing: 8) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                    Text("\(likesCount)")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isLiked ? Color.pink : Color.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("feeds.post.\(postID).like")
            .accessibilityValue(isLiked ? "liked" : "unliked")

            Button(action: onCommentTap) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.right.fill")
                    Text("\(commentsCount)")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("feeds.post.\(postID).comments")

            Spacer()
        }
    }
}
