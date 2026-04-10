import SwiftUI

struct CalendarMonthGridView: View {
    
    let days: [CalendarDayItem]
    let onDayTap: (CalendarDayItem) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days) { day in
                CalendarDayCellView(day: day) {
                    onDayTap(day)
                }
            }
        }
    }
}
