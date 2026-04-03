import SwiftUI

struct FeedsScreen: View {
    
    @ObservedObject var viewModel: FeedsMainTabViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    FeedsTopBar(
                        onPeopleTap: viewModel.didTapTopLeftButton,
                        onCalendarTap: viewModel.didTapCalendarButton
                    )
                    
                    CommunitiesSegmentPicker(selectedTab: $viewModel.selectedTab)
                    
                    CommunitiesScrollView(
                        communities: viewModel.communities,
                        onCreateTap: viewModel.didTapCreateCommunity,
                        onTap: viewModel.didTapCommunity(_:)
                    )
                    
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.posts) { post in
                            FeedPostCardView(
                                post: post,
                                onTap: { viewModel.didTapPost(post) },
                                onLikeTap: { viewModel.toggleLike(for: post.id) },
                                onCommentTap: {
                                    print("Mock: open comments for \(post.title)")
                                },
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
            
            CreateFeedActionButton(
                title: "Создать пост",
                onTap: viewModel.didTapCreate
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12/255, green: 18/255, blue: 36/255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    FeedsScreen(viewModel: FeedsMainTabViewModel())
}
