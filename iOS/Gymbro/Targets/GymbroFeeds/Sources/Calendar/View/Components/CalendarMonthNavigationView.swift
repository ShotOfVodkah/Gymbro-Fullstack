import SwiftUI

struct CalendarMonthNavigationView: View {
    
    let title: String
    let onPreviousTap: () -> Void
    let onNextTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPreviousTap) {
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: onNextTap) {
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}
