import Foundation

public struct ProfileStatisticsResponse: Decodable, Hashable {
    public let user_id: Int?
    public let summary: StatisticsSummaryResponse
    public let weekly_activity: [StatisticsBarItemResponse]
    public let monthly_trend: [StatisticsPointItemResponse]
    public let workouts_by_month: [StatisticsMonthCountItemResponse]
    public let categories: [StatisticsCategoryItemResponse]
    
    public init(
        user_id: Int?,
        summary: StatisticsSummaryResponse,
        weekly_activity: [StatisticsBarItemResponse],
        monthly_trend: [StatisticsPointItemResponse],
        workouts_by_month: [StatisticsMonthCountItemResponse],
        categories: [StatisticsCategoryItemResponse]
    ) {
        self.user_id = user_id
        self.summary = summary
        self.weekly_activity = weekly_activity
        self.monthly_trend = monthly_trend
        self.workouts_by_month = workouts_by_month
        self.categories = categories
    }
}
