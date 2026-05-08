import Foundation
import SwiftUI
import GymbroCommonUI

struct FeedsMainTabView: View {

    @ObservedObject private var viewModel: FeedsMainTabViewModel
    @State private var feedsScrollSafeAreaTop: CGFloat = 0
    private let scrollToTopID = "feeds.scroll.top"

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
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    FeedsTopBar(
                        onPeopleTap: viewModel.didTapOpenFriends,
                        onCalendarTap: viewModel.didTapCalendarButton
                    )
                    .padding(.top, 4)
                    .id(scrollToTopID)

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
                    
                    if viewModel.visiblePosts.isEmpty {
                        FeedsEmptyStateView(
                            systemImage: "square.stack.3d.up",
                            title: emptyFeedTitle,
                            subtitle: String(localized: "feeds.feed.empty.subtitle", bundle: .module)
                        )
                        .padding(.horizontal, 12)
                        .frame(minHeight: 320)
                    } else {
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
            }
            .tint(.white)
            .refreshable {
                await viewModel.refresh(showLoading: false)
            }
            .overlay(alignment: .bottom) {
                if viewModel.hasNewPostsAvailable {
                    Button {
                        Task {
                            await viewModel.refresh(showLoading: false)
                            await MainActor.run {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(scrollToTopID, anchor: .top)
                                }
                            }
                        }
                    } label: {
                        Text(String(localized: "feeds.feed.new_posts", bundle: .module))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.appPurple))
                            .overlay(
                                Capsule()
                                    .stroke(LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2), Color.clear],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing
                                                          ),
                                            lineWidth: 1
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .fill(LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .blendMode(.screen)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 120)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "feeds.content.loaded")
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    private var emptyFeedTitle: String {
        switch viewModel.selectedTab {
        case .forYou:
            return String(localized: "feeds.feed.empty.foryou.title", bundle: .module)
        case .friends:
            return String(localized: "feeds.feed.empty.friends.title", bundle: .module)
        case .personal:
            return String(localized: "feeds.feed.empty.personal.title", bundle: .module)
        case .group:
            return String(localized: "feeds.feed.empty.group.title", bundle: .module)
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
