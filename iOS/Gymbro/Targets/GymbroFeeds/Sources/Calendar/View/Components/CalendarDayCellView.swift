import SwiftUI

struct CalendarDayCellView: View {
    
    let day: CalendarDayItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                
                Text("\(day.dayNumber)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(textColor)
            }
            .frame(height: 42)
            .opacity(day.isInCurrentMonth ? 1 : 0.22)
        }
        .buttonStyle(.plain)
        .disabled(!day.hasWorkout)
    }
    
    private var backgroundColor: Color {
        if day.isSelected {
            return Color.appPurple.opacity(0.75)
        }
        if day.hasWorkout {
            return Color.appPurple.opacity(0.45)
        }
        return Color.white.opacity(0.04)
    }
    
    private var borderColor: Color {
        if day.isSelected {
            return .white.opacity(0.95)
        }
        if day.isToday {
            return .white.opacity(0.35)
        }
        return .clear
    }
    
    private var borderWidth: CGFloat {
        if day.isSelected { return 1.5 }
        if day.isToday { return 1 }
        return 0
    }
    
    private var textColor: Color {
        day.hasWorkout || day.isSelected ? .white : .white.opacity(0.8)
    }
}
