import Foundation

public struct ProfileStatisticsScreenModel: Equatable, Hashable {
    public let userID: Int?
    
    public let summary: StatisticsSummaryModel
    public let weeklyActivity: [StatisticsBarItem]
    public let monthlyTrend: [StatisticsPointItem]
    public let workoutsByMonth: [StatisticsMonthCountItem]
    public let categories: [StatisticsCategoryItem]
    
    public init(
        userID: Int?,
        summary: StatisticsSummaryModel,
        weeklyActivity: [StatisticsBarItem],
        monthlyTrend: [StatisticsPointItem],
        workoutsByMonth: [StatisticsMonthCountItem],
        categories: [StatisticsCategoryItem],
    ) {
        self.userID = userID
        self.summary = summary
        self.weeklyActivity = weeklyActivity
        self.monthlyTrend = monthlyTrend
        self.workoutsByMonth = workoutsByMonth
        self.categories = categories
    }
}
