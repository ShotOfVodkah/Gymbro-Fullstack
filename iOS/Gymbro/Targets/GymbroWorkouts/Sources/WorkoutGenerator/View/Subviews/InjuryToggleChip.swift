import SwiftUI

import GymbroCommonUI

struct InjuryToggleChip: View {

    init(
        label: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(
                            isSelected ? .white : Color.white.opacity(0.25),
                            lineWidth: 1.5
                        )
                        .frame(width: 18, height: 18)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.appPurple.opacity(0.45) : Color.appDarkGray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color.appPurple.opacity(0.7) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PressScaleButtonStyle(pressedScale: 0.96))
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private let label: String
    private let isSelected: Bool
    private let action: () -> Void
}
