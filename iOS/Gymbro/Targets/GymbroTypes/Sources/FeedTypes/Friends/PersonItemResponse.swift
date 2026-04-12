import Foundation

public struct PersonItemResponse: Decodable {
    let id: String
    let name: String
    let username: String
    let status: String
    let subtitle: String
    let avatar_system_name: String
    let is_following: Bool
    let is_current_friend: Bool
    let badge: String?
    let workouts_this_month: Int
}
