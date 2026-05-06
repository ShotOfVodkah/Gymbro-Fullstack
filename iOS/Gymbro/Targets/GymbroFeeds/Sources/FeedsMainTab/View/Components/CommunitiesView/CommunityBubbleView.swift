import SwiftUI
import GymbroTypes

struct CommunityBubbleView: View {
    
    let community: FeedCommunity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPurple.opacity(0.8), Color.purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 82, height: 82)
                            .overlay(circleContent)
                        
                        if community.kind == .joinedGroup {
                            Circle()
                                .fill(Color.appPurple)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .overlay(
                                    Circle().stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                    if community.unreadCount > 0 {
                        Text("\(community.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.appRed)
                            .clipShape(Capsule())
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 2)
                            )
                            .offset(x: 4, y: 2)
                    }
                }

                Text(community.displayTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(width: 84)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("feeds.community.\(community.id)")
    }

    @ViewBuilder
    private var circleContent: some View {
        if community.isSystemImage {
            Image(systemName: community.icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        } else {
            Image(systemName: "xmark.square")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
