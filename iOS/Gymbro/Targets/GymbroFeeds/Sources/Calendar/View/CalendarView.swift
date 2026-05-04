import SwiftUI
import GymbroCommonUI

struct FeedsCalendarView: View {
    
    init(viewModel: FeedsCalendarViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    FeedsCalendarViewStub()
                    
                case .loaded:
                    contentView
                    
                case .error:
                    VStack(alignment: .center) {
                        Text(GymbroCommonStrings.genericError)
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton(GymbroCommonStrings.refresh, size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                CalendarHeaderView(onBackTap: viewModel.didTapBack)
                
                if viewModel.availablePeople.count > 1 {
                    CalendarPersonPickerView(
                        people: viewModel.availablePeople,
                        selectedPerson: viewModel.selectedPerson,
                        onSelect: viewModel.didSelectPerson(_:)
                    )
                }
                
                VStack(spacing: 16) {
                    CalendarMonthNavigationView(
                        title: viewModel.monthTitle,
                        onPreviousTap: viewModel.didTapPreviousMonth,
                        onNextTap: viewModel.didTapNextMonth
                    )
                    
                    CalendarWeekdayRowView()
                    
                    CalendarMonthGridView(
                        days: viewModel.days,
                        onDayTap: viewModel.didTapDay(_:)
                    )
                    
                    CalendarLegendView()
                    
                    if let selectedDay = viewModel.selectedDayForActions,
                       !selectedDay.myWorkouts.isEmpty || !selectedDay.partnerWorkouts.isEmpty {
                        CalendarWorkoutChoicesView(
                            day: selectedDay,
                            onWorkoutTap: viewModel.openWorkout(_:owner:),
                            onCloseTap: viewModel.clearDayWorkoutChoices
                        )
                        .padding(.horizontal, -4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.selectedDayForActions?.date)
                .padding(18)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                Spacer(minLength: 24)
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.7)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0/255.0, green: 18.0/255.0, blue: 36.0/255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: FeedsCalendarViewModel
}
