import Foundation
import GymbroNavigation
import GymbroTypes

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
    private let service: any FeedsCalendarService
    private let analytics: any AnalyticsService
    private let calendar = Calendar.current
    
    init(
        input: CalendarScreenInput,
        router: any Router,
        service: any FeedsCalendarService,
        analytics: any AnalyticsService
    ) {
        self.input = input
        self.router = router
        self.analytics = analytics
        self.service = service
        reload()
        analytics.track(.screenViewed(screen: .feedsCalendar))
    }
    
    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsCalendar.rawValue))
            await loadCalendar()
        }
    }
    
    func didTapBack() {
        router.pop()
    }
    
    func didTapPreviousMonth() {
        guard let previous = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) else { return }
        currentMonthDate = previous
        analytics.track(.calendarMonthChanged(direction: "prev"))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func didTapNextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) else { return }
        currentMonthDate = next
        analytics.track(.calendarMonthChanged(direction: "next"))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func didSelectPerson(_ person: CalendarPerson) {
        selectedPerson = person
        analytics.track(.calendarPersonSelected(personId: person.id))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func openMyWorkoutFromSelectedDay() {
        guard let workoutID = selectedDayForActions?.myWorkoutID else { return }
        print("open my workout:", workoutID)
        analytics.track(.calendarMyWorkoutOpened)
    }

    func openPartnerWorkoutFromSelectedDay() {
        guard let workoutID = selectedDayForActions?.partnerWorkoutID else { return }
        print("open partner workout:", workoutID)
        analytics.track(.calendarPartnerWorkoutOpened)
    }

    func clearDayWorkoutChoices() {
        selectedDayForActions = nil
    }
    
    func didTapDay(_ day: CalendarDayItem) {
        let hasMy = day.myWorkoutID != nil
        let hasPartner = day.partnerWorkoutID != nil

        analytics.track(.calendarDayTapped(hasMyWorkout: hasMy, hasPartnerWorkout: hasPartner))

        if hasMy && hasPartner {
            selectedDayForActions = day
            isShowingDayWorkoutChoices = true
            return
        }
        
        if let partnerWorkoutID = day.partnerWorkoutID {
            analytics.track(.calendarPartnerWorkoutOpened)
            print("open partner workout:", partnerWorkoutID)
            return
        }
        
        if let myWorkoutID = day.myWorkoutID {
            analytics.track(.calendarMyWorkoutOpened)
            print("open my workout:", myWorkoutID)
        }
    }
    
    private func loadCalendar() async {
        screenState = .loading
        
        do {
            let data = try await service.fetchInitialScreen(
                input: input,
                month: currentMonthDate
            )
            
            availablePeople = data.people
            selectedPerson = data.selectedPerson
            monthTitle = data.monthData.monthTitle
            
            rebuildCalendar(
                myWorkoutMap: data.monthData.myWorkoutMap,
                selectedPersonWorkoutMap: data.monthData.partnerWorkoutMap
            )
            
            screenState = .loaded
        } catch {
            print("Failed to load calendar:", error)
            screenState = .error
        }
    }
    
    private func reloadMonthOnly() async {
        do {
            let monthData = try await service.fetchMonth(
                input: input,
                month: currentMonthDate,
                selectedPersonID: selectedPerson?.id
            )
            
            monthTitle = monthData.monthTitle
            
            rebuildCalendar(
                myWorkoutMap: monthData.myWorkoutMap,
                selectedPersonWorkoutMap: monthData.partnerWorkoutMap
            )
            
            screenState = .loaded
        } catch {
            print("Failed to reload calendar month:", error)
            screenState = .error
        }
    }

    private func rebuildCalendar(
        myWorkoutMap: [Date: String],
        selectedPersonWorkoutMap: [Date: String]
    ) {
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
}
