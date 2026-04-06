import Foundation
import SwiftUI
import GymbroCommonUI

struct FeedsMainTabView: View {
    
    init(viewModel: FeedsMainTabViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    FeedsViewStub()
                    
                case .loaded:
                    contentView
                    
                case .error:
                    VStack(alignment: .center) {
                        Text("Something went wrong, oopsie...")
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton("Refresh", size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                FeedsTopBar(
                    onPeopleTap: viewModel.didTapOpenFriends,
                    onCalendarTap: viewModel.didTapCalendarButton
                )
                
                CommunitiesSegmentPicker(selectedTab: $viewModel.selectedTab)
                
                if viewModel.shouldShowCommunities {
                    CommunitiesScrollView(
                        communities: viewModel.visibleCommunities,
                        onCreateTap: viewModel.didTapCreateCommunity,
                        onTap: viewModel.didTapCommunity(_:)
                    )
                } else {
                    CreateCommunityButtonView(onTap: viewModel.didTapCreateCommunity)
                }
                
                LazyVStack(spacing: 15) {                    
                    ForEach(viewModel.visiblePosts) { post in
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
    
    @ObservedObject private var viewModel: FeedsMainTabViewModel
}
