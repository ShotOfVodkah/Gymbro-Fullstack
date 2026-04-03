import Foundation

enum FeedTab: String, CaseIterable, Identifiable {
    case forYou = "For you"
    case friends = "Friends"
    case personal = "Personal"
    case group = "Groups"

    var id: String { rawValue }
}
