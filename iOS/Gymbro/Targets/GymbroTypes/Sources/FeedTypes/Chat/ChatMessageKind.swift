import Foundation

public enum ChatMessageKind: Hashable {
    case text(String)
    case workout(
        sessionID: String,
        title: String,
        subtitle: String,
        duration: String,
        category: String
    )
    case challengeSystem(
        challengeID: String,
        title: String,
        message: String,
        status: ChallengeParticipationStatus
    )
}
