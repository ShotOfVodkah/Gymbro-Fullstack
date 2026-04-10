import SwiftUI

struct CalendarLegendView: View {
    
    var body: some View {
        HStack(spacing: 18) {
            legendDot(
                color: Color.appPurple,
                title: "You"
            )
            
            legendDot(
                color: Color.blue.opacity(0.9),
                title: "Chat partner"
            )
            
            legendItem(
                fill: Color.white.opacity(0.10),
                stroke: Color.white.opacity(0.8),
                title: "Selected"
            )
            
            legendItem(
                fill: Color.white.opacity(0.04),
                stroke: Color.white.opacity(0.35),
                title: "Today"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func legendDot(color: Color, title: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private func legendItem(fill: Color, stroke: Color, title: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(fill)
                .frame(width: 16, height: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(stroke, lineWidth: stroke == .clear ? 0 : 1)
                )
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
