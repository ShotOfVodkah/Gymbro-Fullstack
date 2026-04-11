import SwiftUI
import GymbroTypes

struct CommunitiesScrollView: View {
    
    let communities: [FeedCommunity]
    let onCreateTap: () -> Void
    let onTap: (FeedCommunity) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                CreateCommunityButtonView(onTap: onCreateTap)
                
                ForEach(communities) { community in
                    CommunityBubbleView(community: community) {
                        onTap(community)
                    }
                }
            }
            .padding(.horizontal, 7)
        }
    }
}
