import SwiftUI
import GymbroTypes

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
                
                VStack(spacing: 4) {
                    Text("\(day.dayNumber)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(textColor)
                    
                    HStack(spacing: 4) {
                        if day.hasMyWorkout {
                            Circle()
                                .fill(Color.appPurple)
                                .frame(width: 6, height: 6)
                        }
                        
                        if day.hasPartnerWorkout {
                            Circle()
                                .fill(Color.blue.opacity(0.9))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .frame(height: 42)
            .opacity(day.isInCurrentMonth ? 1 : 0.22)
        }
        .buttonStyle(.plain)
        .disabled(!day.hasMyWorkout && !day.hasPartnerWorkout)
    }
    
    private var backgroundColor: Color {
        if day.isSelected {
            return Color.white.opacity(0.10)
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
        if day.hasMyWorkout || day.hasPartnerWorkout || day.isSelected {
            return .white
        }
        return .white.opacity(0.8)
    }
}
