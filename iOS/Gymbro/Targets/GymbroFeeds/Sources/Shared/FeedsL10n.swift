import Foundation

import GymbroTypes

extension PeopleTab {
    public var localizedTitle: String {
        switch self {
        case .friends:
            return String(localized: "feeds.people.tab.friends", bundle: .module)
        case .following:
            return String(localized: "feeds.people.tab.following", bundle: .module)
        case .discover:
            return String(localized: "feeds.people.tab.discover", bundle: .module)
        }
    }
}

enum FeedsL10n {
    static func groupSelectedLine(count: Int) -> String {
        let fmt = String(localized: "feeds.chat.group.selected_line", bundle: .module)
        return String(format: fmt, locale: .current, count)
    }

    static func workoutsThisMonth(_ count: Int) -> String {
        let fmt = String(localized: "feeds.person.workouts_month", bundle: .module)
        return String(format: fmt, locale: .current, count)
    }
}
