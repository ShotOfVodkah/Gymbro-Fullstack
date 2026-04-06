import SwiftUI

struct CalendarHeaderView: View {
    
    let onBackTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBackTap) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            
            Text("Calendar")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
