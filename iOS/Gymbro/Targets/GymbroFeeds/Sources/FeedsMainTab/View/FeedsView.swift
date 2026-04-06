import SwiftUI

struct FeedsView: View {
    
    @ObservedObject var viewModel: FeedsMainTabViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    FeedsTopBar(
                        onPeopleTap: viewModel.didTapOpenFriends,
                        onCalendarTap: viewModel.didTapCalendarButton
                    )
                    
                    CommunitiesSegmentPicker(selectedTab: $viewModel.selectedTab)
                    
                    CommunitiesScrollView(
                        communities: viewModel.communities,
                        onCreateTap: viewModel.didTapCreateCommunity,
                        onTap: viewModel.didTapCommunity(_:)
                    )
                    
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.posts) { post in
                            PostCardView(
                                post: post,
                                onTap: { viewModel.didTapPost(post) },
                                onLikeTap: { viewModel.toggleLike(for: post.id) },
                                onCommentTap: { viewModel.didTapComments(for: post) },
                                onExerciseTap: { exercise in
                                    viewModel.didTapExercise(exercise)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.bottom, 120)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0/255.0, green: 18.0/255.0, blue: 36.0/255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
