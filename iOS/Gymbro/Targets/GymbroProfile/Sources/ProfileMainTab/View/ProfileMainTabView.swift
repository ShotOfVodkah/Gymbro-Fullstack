import Foundation
import SwiftUI
import GymbroCommonUI
import GymbroTypes

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

            if viewModel.screenState == .loaded, viewModel.isOwnProfile {
                UITestMarker(id: "profile.my.loaded")
            }

            if case .otherUserProfile = viewModel.mode {
                UITestMarker(id: "profile.other.user.screen")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .task {
            await viewModel.loadIfNeeded()
        }
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
                    
                    ProfileSectionContainer(title: String(localized: "profile.main.quick_stats", bundle: .module)) {
                        VStack(spacing: 12) {
                            if let stats = viewModel.statsPreview {
                                HStack(spacing: 12) {
                                    ProfileStatCardView(
                                        title: String(localized: "profile.main.this_month", bundle: .module),
                                        value: "\(stats.workoutsThisMonth)",
                                        subtitle: String(localized: "profile.main.workouts_completed", bundle: .module),
                                        iconSystemName: "medal.fill"
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    ProfileStatCardView(
                                        title: String(localized: "profile.main.total_workouts", bundle: .module),
                                        value: "\(stats.totalWorkouts)",
                                        subtitle: String(localized: "profile.main.all_time", bundle: .module),
                                        iconSystemName: "dumbbell"
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                
                                HStack(spacing: 12) {
                                    ProfileStatChipView(
                                        title: String(localized: "profile.main.hours", bundle: .module),
                                        value: "\(stats.totalHours)"
                                    )
                                    
                                    ProfileStatChipView(
                                        title: String(localized: "profile.main.favorite_type", bundle: .module),
                                        value: stats.favoriteWorkoutType
                                    )
                                    
                                    ProfileStatChipView(
                                        title: String(localized: "profile.main.best_day", bundle: .module),
                                        value: stats.mostActiveWeekday
                                    )
                                }
                            }
                        }
                    }
                    
                    if !viewModel.weeklyActivity.isEmpty {
                        ProfileSectionContainer(
                            title: String(localized: "profile.main.weekly_activity", bundle: .module),
                            subtitle: String(localized: "profile.main.weekly_activity_sub", bundle: .module)
                        ) {
                            ProfileMiniChartView(items: viewModel.weeklyActivity)
                        }
                    }
                    
                    ProfileSectionContainer(title: String(localized: "profile.main.about", bundle: .module)) {
                        if let about = viewModel.about, !about.bio.isEmpty {
                            Text(about.bio)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                        } else {
                            ProfileEmptyStateView(
                                title: String(localized: "profile.main.no_bio_title", bundle: .module),
                                subtitle: String(localized: "profile.main.no_bio_sub", bundle: .module)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .refreshable {
            await viewModel.refresh()
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
