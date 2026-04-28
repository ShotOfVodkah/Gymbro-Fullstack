import Foundation

public struct LeaderboardEntry: Identifiable, Hashable {
    public let id: String
    public let rank: Int
    
    public let userID: String
    public let name: String
    public let username: String
    public let avatarSystemName: String
    
    public let currentStreakWeeks: Int
    public let completedWorkouts: Int
    
    public let isCurrentUser: Bool
    
    public let isFollowing: Bool
    public let isFriend: Bool
    
    public init(
        id: String,
        rank: Int,
        userID: String,
        name: String,
        username: String,
        avatarSystemName: String,
        currentStreakWeeks: Int,
        completedWorkouts: Int,
        isCurrentUser: Bool,
        isFollowing: Bool,
        isFriend: Bool
    ) {
        self.id = id
        self.rank = rank
        self.userID = userID
        self.name = name
        self.username = username
        self.avatarSystemName = avatarSystemName
        self.currentStreakWeeks = currentStreakWeeks
        self.completedWorkouts = completedWorkouts
        self.isCurrentUser = isCurrentUser
        self.isFollowing = isFollowing
        self.isFriend = isFriend
    }
}

public extension LeaderboardResponse {
    
    func toModel() -> LeaderboardEntry {
        LeaderboardEntry(
            id: id,
            rank: rank,
            userID: userID,
            name: name,
            username: username,
            avatarSystemName: avatarSystemName,
            currentStreakWeeks: currentStreakWeeks,
            completedWorkouts: completedWorkouts,
            isCurrentUser: isCurrentUser,
            isFollowing: isFollowing,
            isFriend: isFriend
        )
    }
}

public struct MyRank: Equatable {
    public let rank: Int
    public let currentStreakWeeks: Int
    public let completedWorkouts: Int
    
    public init(
        rank: Int,
        currentStreakWeeks: Int,
        completedWorkouts: Int
    ) {
        self.rank = rank
        self.currentStreakWeeks = currentStreakWeeks
        self.completedWorkouts = completedWorkouts
    }
}

public extension MyRankResponse {
    
    func toModel() -> MyRank {
        MyRank(
            rank: rank,
            currentStreakWeeks: currentStreakWeeks,
            completedWorkouts: completedWorkouts
        )
    }
}
