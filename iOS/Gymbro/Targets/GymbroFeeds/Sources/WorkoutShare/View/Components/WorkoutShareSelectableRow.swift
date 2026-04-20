import SwiftUI
import GymbroTypes

struct WorkoutShareSelectableRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let iconName: String
    let iconTint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconTint.opacity(0.9), iconTint.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.62))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.appPurple : .white.opacity(0.42))
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }
}
