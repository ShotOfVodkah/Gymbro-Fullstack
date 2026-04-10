import Foundation
import GymbroNavigation

@MainActor
final class FeedsCalendarViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    @Published var monthTitle: String = ""
    @Published var currentMonthDate: Date = Date()
    @Published var selectedPerson: CalendarPerson?
    @Published var availablePeople: [CalendarPerson] = []
    @Published var days: [CalendarDayItem] = []
    
    private let input: CalendarScreenInput
    private let router: any Router
    private let calendar = Calendar.current
    
    init(input: CalendarScreenInput, router: any Router) {
        self.input = input
        self.router = router
        loadMockData()
    }
    
    func reload() { loadMockData() }
    
    func didTapBack() {
        router.pop()
    }
    
    func didTapPreviousMonth() {
        guard let previous = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) else { return }
        currentMonthDate = previous
        rebuildCalendar()
    }
    
    func didTapNextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) else { return }
        currentMonthDate = next
        rebuildCalendar()
    }
    
    func didSelectPerson(_ person: CalendarPerson) {
        selectedPerson = person
        rebuildCalendar()
    }
    
    func didTapDay(_ day: CalendarDayItem) {
        print("перенаправление на воркаут инфо")
        //        guard day.hasWorkout, let workoutID = day.workoutID else { return }
        //        router.navigate(to: .feedsPost(title: "Workout \(workoutID)"))
        //        перенаправление на воркаут инфо
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }

    private func rebuildCalendar() {
        monthTitle = monthFormatter.string(from: currentMonthDate)

        guard let selectedPerson else {
            days = []
            return
        }
        
        let workoutMap = FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonthDate),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: lastDayOfMonth)
        else {
            days = []
            return
        }
        
        var result: [CalendarDayItem] = []
        var cursor = firstWeekInterval.start
        
        while cursor < lastWeekInterval.end {
            let dayNumber = calendar.component(.day, from: cursor)
            let isInCurrentMonth = calendar.isDate(cursor, equalTo: currentMonthDate, toGranularity: .month)
            let isToday = calendar.isDateInToday(cursor)
            
            let normalizedDate = calendar.startOfDay(for: cursor)
            let workoutID = workoutMap[normalizedDate]
            
            result.append(
                CalendarDayItem(
                    date: normalizedDate,
                    dayNumber: dayNumber,
                    isInCurrentMonth: isInCurrentMonth,
                    hasWorkout: workoutID != nil,
                    workoutID: workoutID,
                    isToday: isToday,
                    isSelected: false
                )
            )
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = nextDay
        }
        
        days = result
    }
    
    private func loadMockData() {
        switch input.context {
        case .mine:
            availablePeople = [FeedsCalendarMockData.people[0]]
            selectedPerson = availablePeople.first
            
        case .person(let personID, let personName):
            availablePeople = [
                CalendarPerson(id: personID, name: personName, avatarSystemName: "person.fill")
            ]
            selectedPerson = availablePeople.first
            
        case .directChat(_, let participantIDs, let initialPersonID):
            availablePeople = FeedsCalendarMockData.people.filter { participantIDs.contains($0.id) }
            selectedPerson = availablePeople.first(where: { $0.id == initialPersonID }) ?? availablePeople.first
            
        case .groupChat(_, _, let initialPersonID):
            availablePeople = FeedsCalendarMockData.people
            selectedPerson = availablePeople.first(where: { $0.id == initialPersonID }) ?? availablePeople.first
        }
        
        rebuildCalendar()
        screenState = .loaded
    }
}
