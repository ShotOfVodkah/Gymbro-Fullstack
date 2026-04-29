import Foundation

public struct ChallengesListResponse: Decodable {
    public let challenges: [ChallengeResponse]
}

public struct ChallengeResponse: Decodable {
    public let id: String
    public let title: String
    public let description: String
    public let type: String
    public let status: String
    public let participationStatus: String
    public let difficulty: String
    public let coverIcon: String
    public let accentColor: String?
    public let startDate: Date
    public let endDate: Date
    public let targetValue: Int
    public let currentValue: Int
    public let progressPercent: Double
    public let unit: String
    public let team: ChallengeTeamPreviewResponse?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, type, status, difficulty, unit, team
        case participationStatus = "participation_status"
        case coverIcon = "cover_icon"
        case accentColor = "accent_color"
        case startDate = "start_date"
        case endDate = "end_date"
        case targetValue = "target_value"
        case currentValue = "current_value"
        case progressPercent = "progress_percent"
    }
}

public struct ChallengeDetailsResponse: Decodable {
    public let id: String
    public let title: String
    public let description: String
    public let rules: [String]
    public let type: String
    public let status: String
    public let participationStatus: String
    public let difficulty: String
    public let coverIcon: String
    public let accentColor: String?
    public let startDate: Date
    public let endDate: Date
    public let targetValue: Int
    public let currentValue: Int
    public let progressPercent: Double
    public let unit: String
    public let team: ChallengeTeamResponse?
    public let participants: [ChallengeParticipantResponse]
    public let rewards: [ChallengeRewardResponse]?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, rules, type, status, difficulty, unit, team, participants, rewards
        case participationStatus = "participation_status"
        case coverIcon = "cover_icon"
        case accentColor = "accent_color"
        case startDate = "start_date"
        case endDate = "end_date"
        case targetValue = "target_value"
        case currentValue = "current_value"
        case progressPercent = "progress_percent"
    }
}

public struct ChallengeTeamPreviewResponse: Decodable {
    public let teamID: String
    public let chatID: String
    public let teamName: String
    
    private enum CodingKeys: String, CodingKey {
        case teamID = "team_id"
        case chatID = "chat_id"
        case teamName = "team_name"
    }
}

public struct ChallengeTeamResponse: Decodable {
    public let teamID: String
    public let challengeID: String
    public let chatID: String
    public let teamName: String
    public let teamAvatar: String
    public let membersCount: Int
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    public let status: String
    public let joinedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case status
        case teamID = "team_id"
        case challengeID = "challenge_id"
        case chatID = "chat_id"
        case teamName = "team_name"
        case teamAvatar = "team_avatar"
        case membersCount = "members_count"
        case currentValue = "current_value"
        case targetValue = "target_value"
        case progressPercent = "progress_percent"
        case joinedAt = "joined_at"
    }
}

public struct ChallengeParticipantResponse: Decodable {
    public let userID: Int
    public let name: String
    public let avatarSystemName: String
    public let contributionValue: Int
    public let contributionUnit: String
    public let rankInTeam: Int
    public let lastActivityAt: Date?
    public let isMVP: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case userID = "user_id"
        case avatarSystemName = "avatar_system_name"
        case contributionValue = "contribution_value"
        case contributionUnit = "contribution_unit"
        case rankInTeam = "rank_in_team"
        case lastActivityAt = "last_activity_at"
        case isMVP = "is_mvp"
    }
}

public struct ChallengeActivityResponse: Decodable {
    public let id: String
    public let userID: Int
    public let userName: String
    public let avatarSystemName: String
    public let action: String
    public let value: Int
    public let unit: String
    public let sourceID: String?
    public let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id, action, value, unit
        case userID = "user_id"
        case userName = "user_name"
        case avatarSystemName = "avatar_system_name"
        case sourceID = "source_id"
        case createdAt = "created_at"
    }
}

public struct ChallengeLeaderboardResponse: Decodable {
    public let challengeID: String
    public let leaderboard: [ChallengeLeaderboardTeamResponse]
    
    private enum CodingKeys: String, CodingKey {
        case challengeID = "challenge_id"
        case leaderboard
    }
}

public struct ChallengeLeaderboardTeamResponse: Decodable {
    public let rank: Int
    public let teamID: String
    public let chatID: String
    public let teamName: String
    public let teamAvatar: String?
    public let membersCount: Int
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    public let status: String
    public let isCurrentUserTeam: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case rank, status
        case teamID = "team_id"
        case chatID = "chat_id"
        case teamName = "team_name"
        case teamAvatar = "team_avatar"
        case membersCount = "members_count"
        case currentValue = "current_value"
        case targetValue = "target_value"
        case progressPercent = "progress_percent"
        case isCurrentUserTeam = "is_current_user_team"
    }
}

public struct AvailableChallengeTeamsResponse: Decodable {
    public let teams: [AvailableChallengeTeamResponse]
}

public struct AvailableChallengeTeamResponse: Decodable {
    public let chatID: String
    public let chatName: String
    public let avatarSystemName: String
    public let membersCount: Int
    public let canJoin: Bool
    public let reason: String?
    
    private enum CodingKeys: String, CodingKey {
        case reason
        case chatID = "chat_id"
        case chatName = "chat_name"
        case avatarSystemName = "avatar_system_name"
        case membersCount = "members_count"
        case canJoin = "can_join"
    }
}

public struct JoinChallengeResponse: Decodable {
    public let teamID: String
    public let challengeID: String
    public let chatID: String
    public let teamName: String
    public let status: String
    public let currentValue: Int
    public let targetValue: Int
    public let progressPercent: Double
    
    private enum CodingKeys: String, CodingKey {
        case status
        case teamID = "team_id"
        case challengeID = "challenge_id"
        case chatID = "chat_id"
        case teamName = "team_name"
        case currentValue = "current_value"
        case targetValue = "target_value"
        case progressPercent = "progress_percent"
    }
}

public struct LeaveChallengeResponse: Decodable {
    public let status: String
}

public struct ChallengeRewardResponse: Decodable {
    public let id: String
    public let title: String
    public let description: String
    public let iconName: String
    public let isUnlocked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description
        case iconName = "icon_name"
        case isUnlocked = "is_unlocked"
    }
}




