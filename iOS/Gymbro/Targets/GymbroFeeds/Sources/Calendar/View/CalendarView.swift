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
        .confirmationDialog(
            "Choose workout",
            isPresented: $viewModel.isShowingDayWorkoutChoices,
            titleVisibility: .visible
        ) {
            if viewModel.selectedDayForActions?.myWorkoutID != nil {
                Button(String(localized: "feeds.calendar.action_my_workout", bundle: .module)) {
                    viewModel.openMyWorkoutFromSelectedDay()
                }
            }
            
            if viewModel.selectedDayForActions?.partnerWorkoutID != nil {
                Button(String(localized: "feeds.calendar.action_partner_workout", bundle: .module)) {
                    viewModel.openPartnerWorkoutFromSelectedDay()
                }
            }
            
            Button(String(localized: "feeds.calendar.cancel", bundle: .module), role: .cancel) {
                viewModel.clearDayWorkoutChoices()
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
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                Spacer(minLength: 24)
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
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
