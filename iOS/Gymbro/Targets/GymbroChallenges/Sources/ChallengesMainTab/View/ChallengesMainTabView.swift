import Foundation
import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct ChallengesMainTabView: View {
    
    init(viewModel: ChallengesMainTabViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ChallengesViewStub()
                    
                case .loaded:
                    contentView
                    
                case .empty:
                    emptyView
                    
                case .error:
                    errorView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                
                if let featured = viewModel.featuredChallenge {
                    VStack(alignment: .leading, spacing: 13) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Featured Challenge")
                                .font(.system(size: 21, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("The most relevant challenge for your team right now")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        
                        ChallengeCardView(
                            challenge: featured,
                            onTap: {
                                viewModel.challengeTapped(featured)
                            },
                            onJoinTap: featured.isJoined ? nil : {
                                viewModel.joinChallengeTapped(featured)
                            }
                        )
                    }
                }
                
                ChallengeStatsSummaryView(
                    activeCount: viewModel.activeCountText,
                    completedCount: viewModel.completedCountText,
                    teamsCount: viewModel.teamsCountText,
                    availableCount: viewModel.availableCountText
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    ChallengeFilterChipsView(
                        selectedFilter: viewModel.selectedFilter,
                        onSelect: viewModel.selectFilter
                    )
                    
                    ChallengeCategoryChipsView(
                        selectedCategory: viewModel.selectedCategory,
                        onSelect: viewModel.selectCategory
                    )
                }
                
                ChallengeSectionView(
                    title: "Active Challenges",
                    subtitle: "Keep pushing with your team",
                    challenges: viewModel.activeChallenges,
                    onTap: viewModel.challengeTapped,
                    onJoinTap: viewModel.joinChallengeTapped
                )
                
                ChallengeSectionView(
                    title: "Available Challenges",
                    subtitle: "Join with one of your group chats",
                    challenges: viewModel.availableChallenges,
                    onTap: viewModel.challengeTapped,
                    onJoinTap: viewModel.joinChallengeTapped
                )
                
                ChallengeSectionView(
                    title: "Completed History",
                    subtitle: "Your team story so far",
                    challenges: viewModel.completedHistory,
                    onTap: viewModel.challengeTapped,
                    onJoinTap: viewModel.joinChallengeTapped
                )
            }
            .padding(.horizontal, 15)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .refreshable {
            viewModel.refresh()
        }
        .overlay(alignment: .topLeading) {
            UITestMarker(id: "challenges.list.loaded")
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Challenges")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Turn your group chats into teams and conquer fitness goals together.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("No challenges yet")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            
            Text("When new team challenges appear, they will be waiting here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            AppButton(GymbroCommonStrings.refresh, size: .xl) {
                viewModel.reload()
            }
        }
        .padding(.horizontal, 38)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Text(GymbroCommonStrings.genericError)
                .font(.title3)
                .foregroundStyle(.white)
            
            AppButton(GymbroCommonStrings.refresh, size: .xl) {
                viewModel.reload()
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12 / 255, green: 18 / 255, blue: 36 / 255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: ChallengesMainTabViewModel
}
