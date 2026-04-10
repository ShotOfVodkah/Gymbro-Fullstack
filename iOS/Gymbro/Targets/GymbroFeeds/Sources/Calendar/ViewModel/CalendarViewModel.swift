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
    @Published var selectedDayForActions: CalendarDayItem?
    @Published var isShowingDayWorkoutChoices: Bool = false
    
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
    
    func openMyWorkoutFromSelectedDay() {
        guard let workoutID = selectedDayForActions?.myWorkoutID else { return }
        print("workout info")
    }

    func openPartnerWorkoutFromSelectedDay() {
        guard let workoutID = selectedDayForActions?.partnerWorkoutID else { return }
        print("workout info")
    }

    func clearDayWorkoutChoices() {
        selectedDayForActions = nil
    }
    
    func didTapDay(_ day: CalendarDayItem) {
        let hasMy = day.myWorkoutID != nil
        let hasPartner = day.partnerWorkoutID != nil
        
        if hasMy && hasPartner {
            selectedDayForActions = day
            isShowingDayWorkoutChoices = true
            return
        }
        
        if let partnerWorkoutID = day.partnerWorkoutID {
            print("workout info")
            return
        }
        
        if let myWorkoutID = day.myWorkoutID {
            print("workout info")
        }
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }
    
    private func currentMyWorkoutMap() -> [Date: String] {
        switch input.context {
        case .mine, .directChat, .groupChat:
            return FeedsCalendarMockData.workoutsByPerson["me"] ?? [:]
        case .person:
            return [:]
        }
    }
    
//    private func currentSelectedPersonWorkoutMap() -> [Date: String] {
//        guard let selectedPerson else { return [:] }
//        
//        switch input.context {
//        case .mine:
//            return [:]
//            
//        case .person:
//            return FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
//            
//        case .directChat:
//            if selectedPerson.id == "me" {
//                return [:]
//            }
//            return FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
//            
//        case .groupChat:
//            if selectedPerson.id == "me" {
//                return [:]
//            }
//            return FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
//        }
//    }
    
    private func currentSelectedPersonWorkoutMap() -> [Date: String] {
        guard let selectedPerson else { return [:] }
        
        switch input.context {
        case .mine:
            return [:]
            
        case .person:
            return FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
            
        case .directChat, .groupChat:
            if selectedPerson.id == "me" {
                return [:]
            }
            return FeedsCalendarMockData.workoutsByPerson[selectedPerson.id] ?? [:]
        }
    }

    private func rebuildCalendar() {
        monthTitle = monthFormatter.string(from: currentMonthDate)
        
        let myWorkoutMap = currentMyWorkoutMap()
        let selectedPersonWorkoutMap = currentSelectedPersonWorkoutMap()
        
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
            
            let myWorkoutID = myWorkoutMap[normalizedDate]
            let partnerWorkoutID = selectedPersonWorkoutMap[normalizedDate]
            
            result.append(
                CalendarDayItem(
                    date: normalizedDate,
                    dayNumber: dayNumber,
                    isInCurrentMonth: isInCurrentMonth,
                    hasMyWorkout: myWorkoutID != nil,
                    myWorkoutID: myWorkoutID,
                    hasPartnerWorkout: partnerWorkoutID != nil,
                    partnerWorkoutID: partnerWorkoutID,
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
