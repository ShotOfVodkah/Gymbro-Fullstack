import SwiftUI
import GymbroCommonUI

struct ProfileStatisticsView: View {
    
    init(viewModel: ProfileStatisticsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ProfileStatisticsViewStub()
                    
                case .loaded:
                    contentView
                    
                case .error:
                    VStack(alignment: .center, spacing: 16) {
                        Text("Something went wrong, oopsie...")
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton("Refresh", size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.selectedWeeklyBarID) { _, newValue in
            if let newValue {
                viewModel.reportChartSelection(chartKind: "weekly_activity", selectionId: newValue)
            }
        }
        .onChange(of: viewModel.selectedMonthlyPointID) { _, newValue in
            if let newValue {
                viewModel.reportChartSelection(chartKind: "monthly_trend", selectionId: newValue)
            }
        }
        .onChange(of: viewModel.selectedMonthCountID) { _, newValue in
            if let newValue {
                viewModel.reportChartSelection(chartKind: "workouts_by_month", selectionId: newValue)
            }
        }
        .overlay(alignment: .topLeading) {
            if viewModel.screenState == .loaded {
                UITestMarker(id: "profile.statistics.screen")
            }
        }
    }
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                if let summary = viewModel.summary {
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .named("statisticsScroll")).minY
                        let offset = minY > 0 ? minY * 0.15 : minY * 0.05
                        
                        StatisticsHeroSection(summary: summary)
                            .offset(y: offset)
                            .statisticsSectionReveal(isVisible: sectionVisible("hero"), yOffset: 10)
                    }
                    .frame(height: 250)
                }

                if !viewModel.weeklyActivity.isEmpty {
                    ProfileSectionContainer {
                        StatisticsWeeklyBarChart(
                            items: viewModel.weeklyActivity,
                            selectedBarID: $viewModel.selectedWeeklyBarID
                        )
                    }
                    .statisticsSectionReveal(isVisible: sectionVisible("weekly"))
                }
                
                if !viewModel.monthlyTrend.isEmpty {
                    ProfileSectionContainer {
                        StatisticsMonthlyTrendChart(
                            items: viewModel.monthlyTrend,
                            selectedPointID: $viewModel.selectedMonthlyPointID
                        )
                    }
                    .statisticsSectionReveal(isVisible: sectionVisible("monthly"))
                }
                
                if !viewModel.workoutsByMonth.isEmpty {
                    ProfileSectionContainer {
                        StatisticsMonthlyCountChart(
                            items: viewModel.workoutsByMonth,
                            selectedItemID: $viewModel.selectedMonthCountID
                        )
                    }
                    .statisticsSectionReveal(isVisible: sectionVisible("volume"))
                }
                
                detailStatsSection
                    .statisticsSectionReveal(isVisible: sectionVisible("details"))
                insightsSection
                    .statisticsSectionReveal(isVisible: sectionVisible("insights"))
                
                if !viewModel.categories.isEmpty {
                    StatisticsCategoryBarsSection(items: viewModel.categories)
                        .statisticsSectionReveal(isVisible: sectionVisible("categories"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .coordinateSpace(name: "statisticsScroll")
    }
    
    private var detailStatsSection: some View {
        guard let summary = viewModel.summary else { return AnyView(EmptyView()) }
        
        return AnyView(
            ProfileSectionContainer(
                title: "Detailed Stats",
                subtitle: "Short-term performance overview"
            ) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: "This Week",
                            value: "\(summary.workoutsThisWeek)",
                            subtitle: "workouts",
                            iconSystemName: "medal.fill"
                        )

                        ProfileStatCardView(
                            title: "This Month",
                            value: "\(summary.workoutsThisMonth)",
                            subtitle: "workouts",
                            iconSystemName: "trophy.fill"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: "Avg Duration",
                            value: "\(summary.averageWorkoutDurationMinutes)m",
                            subtitle: "per workout",
                            iconSystemName: "bolt.fill"
                        )
                        ProfileStatCardView(
                            title: "Completion",
                            value: "\(summary.completionRate)%",
                            subtitle: "plan completion",
                            iconSystemName: "chart.pie.fill"
                        )
                    }
                }
            }
        )
    }
    
    private var insightsSection: some View {
        guard let summary = viewModel.summary else { return AnyView(EmptyView()) }
        
        return AnyView(
            ProfileSectionContainer(
                title: "Insights",
                subtitle: "Quick takeaways from training activity"
            ) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: "Fav muscle group",
                            value: "\(summary.favoriteMuscleGroup)",
                            iconSystemName: "heart.fill"
                        )

                        ProfileStatCardView(
                            title: "Most active day",
                            value: "\(summary.mostActiveDay)",
                            iconSystemName: "1.calendar"
                        )
                    }
                }
            }
        )
    }
    
    private func sectionVisible(_ id: String) -> Bool {
        viewModel.visibleSectionIDs.contains(id)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 10.0 / 255.0, green: 16.0 / 255.0, blue: 34.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: ProfileStatisticsViewModel
}
