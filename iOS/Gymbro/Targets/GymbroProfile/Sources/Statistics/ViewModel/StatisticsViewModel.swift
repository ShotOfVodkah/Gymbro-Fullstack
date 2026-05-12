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
    private let invalidationCenter: ProfileStateInvalidationCenter

    private var invalidationTask: Task<Void, Never>?
    private var didTrackScreenOpen = false
    private var lastRefreshAt: Date?
    private var isRefreshing = false

    init(
        mode: ProfileViewMode,
        service: any ProfileStatisticsServiceProtocol,
        router: any Router,
        analytics: any AnalyticsService,
        invalidationCenter: ProfileStateInvalidationCenter? = nil
    ) {
        self.mode = mode
        self.service = service
        self.router = router
        self.analytics = analytics
        self.invalidationCenter = invalidationCenter ?? .shared

        bindInvalidationEvents()
    }

    deinit {
        invalidationTask?.cancel()
    }

    func loadIfNeeded() async {
        if !didTrackScreenOpen {
            didTrackScreenOpen = true
            analytics.track(.profileStatisticsScreenViewed(isOwnProfile: mode == .myProfile))
        }

        guard model == nil else { return }
        await loadStatistics(showLoading: true)
    }

    func onAppear() {
        Task {
            await refreshIfStale()
        }
    }

    func refresh() async {
        await loadStatistics(showLoading: false)
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
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.profileStatistics.rawValue))
            await loadStatisticsAfterResettingSelection()
        }
    }

    private func refreshIfStale(maxAgeSeconds: TimeInterval = 15) async {
        let age = Date().timeIntervalSince(lastRefreshAt ?? .distantPast)
        guard age > maxAgeSeconds else { return }
        await refresh()
    }

    private func bindInvalidationEvents() {
        invalidationTask?.cancel()

        invalidationTask = Task { [weak self] in
            guard let self else { return }

            for await reason in invalidationCenter.events() {
                await self.handleInvalidation(reason)
            }
        }
    }

    private func handleInvalidation(_ reason: ProfileInvalidationReason) async {
        switch reason {
        case .accountChanged:
            await refresh()
        case .ownProfileDataChanged:
            guard mode == .myProfile else { return }
            await refresh()
        }
    }

    func reportChartSelection(chartKind: String, selectionId: String) {
        analytics.track(.statisticsChartSelected(chartKind: chartKind, selectionId: selectionId))
    }
    
    private func loadStatisticsAfterResettingSelection() async {
        selectedWeeklyBarID = nil
        selectedMonthlyPointID = nil
        selectedMonthCountID = nil
        visibleSectionIDs = []
        await loadStatistics(showLoading: true)
    }

    private func loadStatistics(showLoading: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        if showLoading || screenState != .loaded {
            screenState = .loading
        }

        do {
            model = try await service.fetchStatistics(mode: mode)
            screenState = .loaded
            lastRefreshAt = Date()
            animateSectionsIn()
        } catch {
            if model == nil {
                model = nil
                screenState = .error
                analytics.track(
                    .errorOccurred(
                        screen: AnalyticsScreen.profileStatistics.rawValue,
                        message: error.localizedDescription
                    )
                )
            }
        }
    }
}
