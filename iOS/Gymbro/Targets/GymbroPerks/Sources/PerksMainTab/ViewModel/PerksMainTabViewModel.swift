import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class PerksMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    @Published private(set) var screenState: ScreenState = .loading
    @Published private(set) var dashboard: PerksDashboard?
    
    @Published var isStreakSettingsPresented = false
    @Published private(set) var isUpdatingWeeklyGoal = false
    @Published private(set) var isUsingStreakFreeze = false
    
    private let router: any Router
    private let service: any PerksMainTabService
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        service: any PerksMainTabService,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
    }
    
    func loadIfNeeded() async {
        guard dashboard == nil else { return }
        await loadDashboard()
    }
    
    func reload() {
        Task {
            await loadDashboard()
        }
    }
    
    func openStreakSettings() {
        isStreakSettingsPresented = true
    }
    
    func closeStreakSettings() {
        isStreakSettingsPresented = false
    }
    
    func updateWeeklyGoal(_ goal: Int) {
        guard !isUpdatingWeeklyGoal else { return }
        
        isUpdatingWeeklyGoal = true
        
        Task {
            do {
                dashboard = try await service.updateWeeklyGoal(goal)
                isStreakSettingsPresented = false
            } catch {
                screenState = .error
            }
            
            isUpdatingWeeklyGoal = false
        }
    }
    
    func useStreakFreeze() {
        guard !isUsingStreakFreeze else { return }
        guard dashboard?.streak.canUseStreakFreeze == true else { return }
        
        isUsingStreakFreeze = true
        
        Task {
            do {
                dashboard = try await service.useStreakFreeze()
            } catch {
                screenState = .error
            }
            
            isUsingStreakFreeze = false
        }
    }
    
    func refresh() async {
        await loadDashboard()
    }
    
    private func loadDashboard() async {
        screenState = .loading
        
        do {
            dashboard = try await service.fetchDashboard()
            screenState = .loaded
        } catch {
            if dashboard == nil {
                screenState = .error
            }
        }
    }
}
