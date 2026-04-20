import Foundation
import GymbroTypes

public extension FeedsClient {
    
    func fetchCalendarPeople(
        context: CalendarContext
    ) async throws -> [CalendarPersonResponse] {
        try await client.request(
            method: .GET,
            path: "calendar/people",
            queryItems: calendarPeopleQueryItems(for: context),
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [CalendarPersonResponse].self
        )
    }

    func fetchCalendarMonth(
        context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) async throws -> CalendarMonthResponse {
        try await client.request(
            method: .GET,
            path: "calendar/month",
            queryItems: calendarMonthQueryItems(
                for: context,
                month: month,
                selectedPersonID: selectedPersonID
            ),
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: CalendarMonthResponse.self
        )
    }
}

private extension FeedsClient {
    
    func calendarPeopleQueryItems(for context: CalendarContext) -> [URLQueryItem] {
        switch context {
        case .mine:
            return [
                URLQueryItem(name: "context", value: "mine")
            ]

        case .person(let personID, _):
            return [
                URLQueryItem(name: "context", value: "person"),
                URLQueryItem(name: "person_id", value: personID)
            ]

        case .directChat(let chatID, _, _):
            return [
                URLQueryItem(name: "context", value: "direct_chat"),
                URLQueryItem(name: "chat_id", value: chatID)
            ]

        case .groupChat(let chatID, let groupID, _):
            return [
                URLQueryItem(name: "context", value: "group_chat"),
                URLQueryItem(name: "chat_id", value: chatID),
                URLQueryItem(name: "group_id", value: groupID)
            ]
        }
    }
    
    func calendarMonthQueryItems(
        for context: CalendarContext,
        month: Date,
        selectedPersonID: String?
    ) -> [URLQueryItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        var items = [
            URLQueryItem(name: "month", value: formatter.string(from: month))
        ]

        switch context {
        case .mine:
            items.append(URLQueryItem(name: "context", value: "mine"))

        case .person(let personID, _):
            items.append(URLQueryItem(name: "context", value: "person"))
            items.append(URLQueryItem(name: "person_id", value: personID))

        case .directChat(let chatID, _, _):
            items.append(URLQueryItem(name: "context", value: "direct_chat"))
            items.append(URLQueryItem(name: "chat_id", value: chatID))

        case .groupChat(let chatID, let groupID, _):
            items.append(URLQueryItem(name: "context", value: "group_chat"))
            items.append(URLQueryItem(name: "chat_id", value: chatID))
            items.append(URLQueryItem(name: "group_id", value: groupID))
        }

        if let selectedPersonID {
            items.append(URLQueryItem(name: "selected_person_id", value: selectedPersonID))
        }

        return items
    }
}
