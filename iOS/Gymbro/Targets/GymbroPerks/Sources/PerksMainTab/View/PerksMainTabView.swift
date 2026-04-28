import Foundation
import SwiftUI
import GymbroCommonUI

struct PerksMainTabView: View {
    
    init(viewModel: PerksMainTabViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    PerksViewStub()
                    
                case .loaded:
                    if let dashboard = viewModel.dashboard {
                        PerksDashboardView(dashboard: dashboard,
                                           onOpenStreakSettings: { viewModel.openStreakSettings() },
                                           onUseStreakFreeze: { viewModel.useStreakFreeze()},
                                           onRefresh: { await viewModel.refresh() },
                                           onLeaderboardFilterChanged: { filter in viewModel.trackLeaderboardFilterChanged(filter) },
                                           onLeaderboardSortChanged: { sort in viewModel.trackLeaderboardSortChanged(sort) },
                                           onAchievementOpened: { achievement in viewModel.trackAchievementOpened(achievement) })
                    } else {
                        PerksViewStub()
                    }
                    
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
        .task {
            await viewModel.loadIfNeeded()
        }
        .sheet(isPresented: $viewModel.isStreakSettingsPresented) {
            if let streak = viewModel.dashboard?.streak {
                StreakSettingsSheetView(
                    currentGoal: streak.weeklyGoal,
                    scheduledGoal: streak.nextWeeklyGoal,
                    isSaving: viewModel.isUpdatingWeeklyGoal,
                    onSave: { goal in
                        viewModel.updateWeeklyGoal(goal)
                    },
                    onCancel: {
                        viewModel.closeStreakSettings()
                    }
                )
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
            }
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
    
    @ObservedObject private var viewModel: PerksMainTabViewModel
}
