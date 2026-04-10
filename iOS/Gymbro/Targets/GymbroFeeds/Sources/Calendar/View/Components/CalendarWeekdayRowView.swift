import SwiftUI

struct CalendarWeekdayRowView: View {
    
    private let symbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
