import Foundation

public enum FeedTab: String, CaseIterable, Identifiable {
    case forYou = "For you"
    case friends = "Friends"
    case personal = "Personal"
    case group = "Groups"

    public var id: String { rawValue }
}
