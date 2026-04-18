import Foundation

public enum PeopleScreenInput: Equatable, Hashable {
    case mine
    case user(userID: Int, userName: String)
}
