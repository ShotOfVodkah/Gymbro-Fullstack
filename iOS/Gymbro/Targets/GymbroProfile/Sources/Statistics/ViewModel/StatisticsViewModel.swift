import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class ProfileStatisticsViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var model: ProfileStatisticsScreenModel?
    @Published var selectedWeeklyBarID: String?
    @Published var selectedMonthlyPointID: String?
    @Published var selectedMonthCountID: String?
    @Published var visibleSectionIDs: Set<String> = []
    
    private let mode: ProfileViewMode
    private let service: any ProfileStatisticsServiceProtocol
    private let router: any Router
    private let analytics: any AnalyticsService
    
    init(
        mode: ProfileViewMode,
        service: any ProfileStatisticsServiceProtocol,
        router: any Router,
        analytics: any AnalyticsService
    ) {
        self.mode = mode
        self.service = service
        self.router = router
        self.analytics = analytics
        
        load()
    }
    
    var summary: StatisticsSummaryModel? {
        model?.summary
    }
    
    var weeklyActivity: [StatisticsBarItem] {
        model?.weeklyActivity ?? []
    }
    
    var monthlyTrend: [StatisticsPointItem] {
        model?.monthlyTrend ?? []
    }
    
    var categories: [StatisticsCategoryItem] {
        model?.categories ?? []
    }
    
    var navigationTitle: String {
        switch mode {
        case .myProfile:
            return "My Statistics"
        case .otherUserProfile:
            return "User Statistics"
        }
    }
    
    var selectedWeeklyBar: StatisticsBarItem? {
        guard let selectedWeeklyBarID else { return nil }
        return weeklyActivity.first(where: { $0.id == selectedWeeklyBarID })
    }
    
    var selectedMonthlyPoint: StatisticsPointItem? {
        guard let selectedMonthlyPointID else { return nil }
        return monthlyTrend.first(where: { $0.id == selectedMonthlyPointID })
    }
    
    var workoutsByMonth: [StatisticsMonthCountItem] {
        model?.workoutsByMonth ?? []
    }

    var selectedMonthCount: StatisticsMonthCountItem? {
        guard let selectedMonthCountID else { return nil }
        return workoutsByMonth.first(where: { $0.id == selectedMonthCountID })
    }

    func animateSectionsIn() {
        visibleSectionIDs = []
        let order = ["hero", "weekly", "monthly", "volume", "details", "insights", "categories"]
        for (index, id) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) { [weak self] in
                self?.visibleSectionIDs.insert(id)
            }
        }
    }
    
    func reload() {
        selectedWeeklyBarID = nil
        selectedMonthlyPointID = nil
        selectedMonthCountID = nil
        visibleSectionIDs = []
        load()
    }
    
    private func load() {
        Task {
            screenState = .loading
            
            do {
                model = try await service.fetchStatistics(mode: mode)
                screenState = .loaded
                animateSectionsIn()
            } catch {
                model = nil
                screenState = .error
            }
        }
    }
}
