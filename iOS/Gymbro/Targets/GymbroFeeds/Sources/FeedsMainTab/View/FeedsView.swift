import Foundation
import SwiftUI
import GymbroCommonUI

struct FeedsMainTabView: View {

    @ObservedObject private var viewModel: FeedsMainTabViewModel
    @State private var feedsScrollSafeAreaTop: CGFloat = 0

    init(viewModel: FeedsMainTabViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    FeedsViewStub(topSafeInset: feedsScrollSafeAreaTop)
                    
                case .loaded:
                    contentView
                    
                case .error:
                    VStack(alignment: .center) {
                        Text(GymbroCommonStrings.genericError)
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton(GymbroCommonStrings.refresh, size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: FeedsContentSafeAreaTopKey.self,
                    value: proxy.safeAreaInsets.top
                )
            }
        )
        .onPreferenceChange(FeedsContentSafeAreaTopKey.self) { feedsScrollSafeAreaTop = $0 }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isShowingChatCreation, onDismiss: {
            viewModel.resetChatCreationState()
        }) {
            ChatCreationSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $viewModel.isShowingCommentsSheet, onDismiss: {
            viewModel.dismissCommentsSheet()
        }) {
            FeedCommentsSheetView(
                post: viewModel.selectedPostForComments,
                comments: viewModel.comments,
                draftText: $viewModel.commentsDraftText,
                isLoading: viewModel.isCommentsLoading,
                onSendTap: viewModel.sendComment
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
    }

    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                FeedsTopBar(
                    onPeopleTap: viewModel.didTapOpenFriends,
                    onCalendarTap: viewModel.didTapCalendarButton
                )
                .padding(.top, feedsScrollSafeAreaTop + 4)

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
                            mode: .full,
                            onAuthorTap: { viewModel.didTapAuthor(post) },
                            onLikeTap: { viewModel.toggleLike(for: post.id) },
                            onCommentTap: { viewModel.didTapComments(for: post) },
                            onExerciseTap: { exercise in viewModel.didTapExercise(exercise, in: post) },
                            onShowAllExercisesTap: { viewModel.didTapShowAllExercises(in: post) },
                            onDoubleTapLike: { viewModel.doubleTapLike(for: post.id) },
                        )
                        .onAppear {
                            viewModel.loadNextPageIfNeeded(currentPost: post)
                        }
                    }
                    
                    if viewModel.isLoadingNextPage {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 7)
                .padding(.bottom, 120)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "feeds.content.loaded")
        }
        .refreshable {
            await viewModel.refresh(showLoading: true)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0 / 255.0, green: 18.0 / 255.0, blue: 36.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
