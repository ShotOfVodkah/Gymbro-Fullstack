import SwiftUI

struct FeedsTopBar: View {
    
    let onPeopleTap: () -> Void
    let onCalendarTap: () -> Void
    
    var body: some View {
        HStack {
            circleButton(systemName: "person.2.badge.plus", action: onPeopleTap)

            Spacer()
            
            HStack(spacing: 10) {
                Text("GymBro")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            circleButton(systemName: "calendar", action: onCalendarTap)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func circleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.appPurple.opacity(0.7))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: systemName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white)
                )
        }
        .buttonStyle(.plain)
    }
}
