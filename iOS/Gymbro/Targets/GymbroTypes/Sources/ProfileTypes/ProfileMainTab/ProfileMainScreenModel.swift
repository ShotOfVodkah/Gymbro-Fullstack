import Foundation

public struct ProfileMainScreenModel: Equatable, Hashable {
    public let header: ProfileHeaderModel
    public let actions: [ProfileActionModel]
    public let statsPreview: ProfileStatsPreviewModel
    public let about: ProfileAboutModel
    public let quickInsights: [ProfileQuickInsightModel]
    public let weeklyActivity: [ProfileWeeklyActivityItem]
    public let relationshipState: ProfileRelationshipState?
    
    public init(
        header: ProfileHeaderModel,
        actions: [ProfileActionModel],
        statsPreview: ProfileStatsPreviewModel,
        about: ProfileAboutModel,
        quickInsights: [ProfileQuickInsightModel],
        weeklyActivity: [ProfileWeeklyActivityItem],
        relationshipState: ProfileRelationshipState?
    ) {
        self.header = header
        self.actions = actions
        self.statsPreview = statsPreview
        self.about = about
        self.quickInsights = quickInsights
        self.weeklyActivity = weeklyActivity
        self.relationshipState = relationshipState
    }
}
