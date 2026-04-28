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
            return "All"
        case .following:
            return "Following"
        case .friends:
            return "Friends"
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
            return "Streak"
        case .workouts:
            return "Workouts"
        }
    }
}
