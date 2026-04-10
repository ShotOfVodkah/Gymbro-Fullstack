import Foundation
import GymbroTypes

struct ChatGroupInfo: Hashable {
    var title: String
    var description: String
    var participants: [ChatParticipant]
}
