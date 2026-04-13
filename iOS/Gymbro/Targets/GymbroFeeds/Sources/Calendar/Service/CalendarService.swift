import Foundation
import GymbroNetwork
import GymbroTypes

protocol FeedsCalendarService {
    func fetchInitialScreen(input: CalendarScreenInput, month: Date) async throws -> FeedsCalendarScreenData
    func fetchMonth(input: CalendarScreenInput, month: Date, selectedPersonID: String?) async throws -> FeedsCalendarMonthData
}

struct FeedsCalendarScreenData {
    let people: [CalendarPerson]
    let selectedPerson: CalendarPerson?
    let monthData: FeedsCalendarMonthData
}

struct FeedsCalendarMonthData {
    let monthTitle: String
    let myWorkoutMap: [Date: String]
    let partnerWorkoutMap: [Date: String]
}

final class FeedsCalendarServiceImpl: FeedsCalendarService {
    
    init(client: FeedsClient) {
        self.client = client
    }
    
    func fetchInitialScreen(
        input: CalendarScreenInput,
        month: Date
    ) async throws -> FeedsCalendarScreenData {
        let peopleResponse = try await client.fetchCalendarPeople(context: input.context)
        let people = peopleResponse.map(CalendarPerson.init(response:))
        let selectedPerson = resolveInitialSelectedPerson(from: people, input: input)
        
        let monthData = try await fetchMonth(
            input: input,
            month: month,
            selectedPersonID: selectedPerson?.id
        )
        
        return FeedsCalendarScreenData(
            people: people,
            selectedPerson: selectedPerson,
            monthData: monthData
        )
    }
    
    func fetchMonth(
        input: CalendarScreenInput,
        month: Date,
        selectedPersonID: String?
    ) async throws -> FeedsCalendarMonthData {
        let response = try await client.fetchCalendarMonth(
            context: input.context,
            month: month,
            selectedPersonID: selectedPersonID
        )
        
        return FeedsCalendarMonthData(
            monthTitle: monthFormatter.string(from: month),
            myWorkoutMap: makeWorkoutMap(from: response.my_workouts),
            partnerWorkoutMap: makeWorkoutMap(from: response.partner_workouts)
        )
    }
    
    private let client: FeedsClient
    
    private let calendar = Calendar.current
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }
    
    private func resolveInitialSelectedPerson(
        from people: [CalendarPerson],
        input: CalendarScreenInput
    ) -> CalendarPerson? {
        switch input.context {
        case .mine:
            return people.first
            
        case .person(let personID, _):
            return people.first(where: { $0.id == personID }) ?? people.first
            
        case .directChat(_, _, let initialPersonID):
            if let initialPersonID {
                return people.first(where: { $0.id == initialPersonID }) ?? people.first
            }
            return people.first
            
        case .groupChat(_, _, let initialPersonID):
            if let initialPersonID {
                return people.first(where: { $0.id == initialPersonID }) ?? people.first
            }
            return people.first
        }
    }
    
    private func makeWorkoutMap(from items: [CalendarWorkoutDayResponse]) -> [Date: String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        var result: [Date: String] = [:]
        for item in items {
            guard let date = formatter.date(from: item.date) else { continue }
            let normalizedDate = calendar.startOfDay(for: date)
            result[normalizedDate] = item.workout_id
        }
        return result
    }
}
