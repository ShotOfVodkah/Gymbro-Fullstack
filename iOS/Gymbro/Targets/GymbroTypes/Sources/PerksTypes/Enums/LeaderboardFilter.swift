import Foundation

public enum LeaderboardFilter: String, CaseIterable, Identifiable {
    case all
    case following
    case friends
    
    public var id: String {
        rawValue
    }
    
    public var title: String {
        switch self {
        case .all:
            return String(localized: "leaderboard.filter.all", bundle: .module)
        case .following:
            return String(localized: "leaderboard.filter.following", bundle: .module)
        case .friends:
            return String(localized: "leaderboard.filter.friends", bundle: .module)
        }
    }
}

public enum LeaderboardSort: String, CaseIterable, Identifiable {
    case streak
    case workouts
    
    public var id: String {
        rawValue
    }
    
    public var title: String {
        switch self {
        case .streak:
            return String(localized: "leaderboard.sort.streak", bundle: .module)
        case .workouts:
            return String(localized: "leaderboard.sort.workouts", bundle: .module)
        }
    }
}
