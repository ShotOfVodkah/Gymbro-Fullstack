import Foundation
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
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var detailStatsSection: some View {
        guard let summary = viewModel.summary else { return AnyView(EmptyView()) }
        
        return AnyView(
            ProfileSectionContainer(
                title: String(localized: "statistics.detailed_title", bundle: .module),
                subtitle: String(localized: "statistics.detailed_sub", bundle: .module)
            ) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: String(localized: "statistics.this_week", bundle: .module),
                            value: "\(summary.workoutsThisWeek)",
                            subtitle: String(localized: "statistics.sub_workouts", bundle: .module),
                            iconSystemName: "medal.fill"
                        )

                        ProfileStatCardView(
                            title: String(localized: "statistics.this_month", bundle: .module),
                            value: "\(summary.workoutsThisMonth)",
                            subtitle: String(localized: "statistics.sub_workouts", bundle: .module),
                            iconSystemName: "trophy.fill"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: String(localized: "statistics.avg_duration", bundle: .module),
                            value: "\(summary.averageWorkoutDurationMinutes)m",
                            subtitle: String(localized: "statistics.per_workout", bundle: .module),
                            iconSystemName: "bolt.fill"
                        )
                        ProfileStatCardView(
                            title: String(localized: "statistics.completion", bundle: .module),
                            value: "\(summary.completionRate)%",
                            subtitle: String(localized: "statistics.plan_completion", bundle: .module),
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
                title: String(localized: "statistics.insights_title", bundle: .module),
                subtitle: String(localized: "statistics.insights_sub", bundle: .module)
            ) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ProfileStatCardView(
                            title: String(localized: "statistics.fav_muscle", bundle: .module),
                            value: "\(summary.favoriteMuscleGroup)",
                            iconSystemName: "heart.fill"
                        )

                        ProfileStatCardView(
                            title: String(localized: "statistics.most_active_day", bundle: .module),
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
