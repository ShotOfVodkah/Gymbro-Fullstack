import Foundation

public enum FeedTab: String, CaseIterable, Identifiable {
    case forYou
    case friends
    case personal
    case group

    public var id: String { rawValue }

    public var localizedTitle: String {
        switch self {
        case .forYou:
            return String(localized: "feed.tab.forYou", bundle: .module)
        case .friends:
            return String(localized: "feed.tab.friends", bundle: .module)
        case .personal:
            return String(localized: "feed.tab.personal", bundle: .module)
        case .group:
            return String(localized: "feed.tab.group", bundle: .module)
        }
    }
}
