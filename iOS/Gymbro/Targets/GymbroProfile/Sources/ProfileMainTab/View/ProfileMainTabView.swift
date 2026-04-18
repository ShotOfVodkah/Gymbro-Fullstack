import Foundation
import SwiftUI
import GymbroCommonUI

struct ProfileMainTabView: View {
    
    init(viewModel: ProfileMainTabViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ProfileViewStub()
                    
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
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                if let model = viewModel.screenModel {
                    ProfileHeaderView(model: model.header)
                    
                    if viewModel.shouldShowRelationshipActions {
                        ProfileRelationshipActionsView(
                            followTitle: viewModel.followButtonTitle,
                            onFollowTap: viewModel.didTapFollowButton,
                            onWriteTap: viewModel.didTapWrite,
                            onPostsTap: viewModel.didTapViewPosts
                        )
                    }
                    
                    ProfilePrimaryActionsView(
                        actions: viewModel.actions,
                        onTap: viewModel.handleAction(_:)
                    )
                    
                    ProfileSectionContainer(title: "Quick Stats") {
                        VStack(spacing: 12) {
                            if let stats = viewModel.statsPreview {
                                HStack(spacing: 12) {
                                    ProfileStatCardView(
                                        title: "This Month",
                                        value: "\(stats.workoutsThisMonth)",
                                        subtitle: "workouts completed",
                                        iconSystemName: "medal.fill"
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    ProfileStatCardView(
                                        title: "Total Workouts",
                                        value: "\(stats.totalWorkouts)",
                                        subtitle: "all time",
                                        iconSystemName: "dumbbell"
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                
                                HStack(spacing: 12) {
                                    ProfileStatChipView(
                                        title: "Hours",
                                        value: "\(stats.totalHours)"
                                    )
                                    
                                    ProfileStatChipView(
                                        title: "Favorite Type",
                                        value: stats.favoriteWorkoutType
                                    )
                                    
                                    ProfileStatChipView(
                                        title: "Best Day",
                                        value: stats.mostActiveWeekday
                                    )
                                }
                            }
                        }
                    }
                    
                    if !viewModel.weeklyActivity.isEmpty {
                        ProfileSectionContainer(
                            title: "Weekly Activity",
                            subtitle: "Your training rhythm this week"
                        ) {
                            ProfileMiniChartView(items: viewModel.weeklyActivity)
                        }
                    }
                    
                    ProfileSectionContainer(title: "About") {
                        if let about = viewModel.about, !about.bio.isEmpty {
                            Text(about.bio)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                        } else {
                            ProfileEmptyStateView(
                                title: "No bio yet",
                                subtitle: "This user has not added any profile description."
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
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
    
    @ObservedObject private var viewModel: ProfileMainTabViewModel
}
