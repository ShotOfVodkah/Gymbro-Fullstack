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
    
    private let input: CalendarScreenInput
    private let router: any Router
    private let service: any FeedsCalendarService
    private let analytics: any AnalyticsService
    private let calendar = Calendar.current
    
    private let invalidationCenter: FeedsStateInvalidationCenter
    private var invalidationTask: Task<Void, Never>?
    
    init(
        input: CalendarScreenInput,
        router: any Router,
        service: any FeedsCalendarService,
        analytics: any AnalyticsService,
        invalidationCenter: FeedsStateInvalidationCenter? = nil
    ) {
        self.input = input
        self.router = router
        self.analytics = analytics
        self.service = service
        self.invalidationCenter = invalidationCenter ?? FeedsStateInvalidationCenter.shared
        
        bindInvalidationEvents()
        reload()
        
        analytics.track(.screenViewed(screen: .feedsCalendar))
    }
    
    deinit {
        invalidationTask?.cancel()
    }
    
    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.feedsCalendar.rawValue))
            await loadCalendar()
        }
    }
    
    func refresh() async {
        await loadCalendar()
    }

    func clearUserScopedState() {
        selectedPerson = nil
        availablePeople = []
        days = []
        selectedDayForActions = nil
        screenState = .loading
    }
    
    func didTapBack() {
        router.pop()
    }
    
    func didTapPreviousMonth() {
        guard let previous = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthDate) else { return }
        currentMonthDate = previous
        selectedDayForActions = nil
        analytics.track(.calendarMonthChanged(direction: "prev"))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func didTapNextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthDate) else { return }
        currentMonthDate = next
        selectedDayForActions = nil
        analytics.track(.calendarMonthChanged(direction: "next"))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func didSelectPerson(_ person: CalendarPerson) {
        selectedPerson = person
        selectedDayForActions = nil
        analytics.track(.calendarPersonSelected(personId: person.id))
        Task {
            await reloadMonthOnly()
        }
    }
    
    func openWorkout(_ workout: CalendarWorkoutPreview, owner: CalendarWorkoutOwner) {
        selectedDayForActions = nil
        rebuildSelection()
        router.navigate(to: .workoutInfo(id: workout.id, type: .session))
        
        switch owner {
        case .mine:
            analytics.track(.calendarMyWorkoutOpened)
        case .partner:
            analytics.track(.calendarPartnerWorkoutOpened)
        }
    }

    func clearDayWorkoutChoices() {
        selectedDayForActions = nil
        rebuildSelection()
    }
    
    func didTapDay(_ day: CalendarDayItem) {
        let hasMy = !day.myWorkouts.isEmpty
        let hasPartner = !day.partnerWorkouts.isEmpty
        
        analytics.track(.calendarDayTapped(hasMyWorkout: hasMy, hasPartnerWorkout: hasPartner))
        
        guard hasMy || hasPartner else {
            selectedDayForActions = nil
            rebuildSelection()
            return
        }
        
        if selectedDayForActions?.date == day.date {
            selectedDayForActions = nil
        } else {
            selectedDayForActions = day
        }
        
        rebuildSelection()
    }

    var hasAnyWorkoutsInMonth: Bool {
        days.contains { !$0.myWorkouts.isEmpty || !$0.partnerWorkouts.isEmpty }
    }
    
    private func rebuildSelection() {
        let selectedDate = selectedDayForActions?.date
        days = days.map { day in
            CalendarDayItem(
                date: day.date,
                dayNumber: day.dayNumber,
                isInCurrentMonth: day.isInCurrentMonth,
                myWorkouts: day.myWorkouts,
                partnerWorkouts: day.partnerWorkouts,
                isToday: day.isToday,
                isSelected: selectedDate == day.date
            )
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
        myWorkoutMap: [Date: [CalendarWorkoutPreview]],
        selectedPersonWorkoutMap: [Date: [CalendarWorkoutPreview]]
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
            
            let myWorkouts = myWorkoutMap[normalizedDate] ?? []
            let partnerWorkouts = selectedPersonWorkoutMap[normalizedDate] ?? []
            let isSelected = selectedDayForActions?.date == normalizedDate
            
            result.append(
                CalendarDayItem(
                    date: normalizedDate,
                    dayNumber: dayNumber,
                    isInCurrentMonth: isInCurrentMonth,
                    myWorkouts: myWorkouts,
                    partnerWorkouts: partnerWorkouts,
                    isToday: isToday,
                    isSelected: isSelected
                )
            )
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = nextDay
        }
        
        days = result
    }
    
    private func bindInvalidationEvents() {
        invalidationTask?.cancel()

        invalidationTask = Task { [weak self] in
            guard let self else { return }

            for await reason in invalidationCenter.events() {
                await self.handleInvalidation(reason)
            }
        }
    }

    private func handleInvalidation(_ reason: FeedsInvalidationReason) async {
        switch reason {
        case .calendarChanged, .chatChanged, .communitiesChanged:
            await reloadMonthOnly()

        case .accountChanged, .all:
            clearUserScopedState()
            await refresh()

        default:
            break
        }
    }
}
