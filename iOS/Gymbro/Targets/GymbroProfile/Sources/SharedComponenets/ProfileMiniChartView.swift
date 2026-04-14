import SwiftUI
import GymbroTypes

struct ProfileMiniChartView: View {
    
    init(items: [ProfileWeeklyActivityItem]) {
        self.items = items
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(items) { item in
                VStack(spacing: 8) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 88)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appPurple.opacity(0.85),
                                        Color.white.opacity(0.65)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: filledHeight(for: item))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(item.dayTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func filledHeight(for item: ProfileWeeklyActivityItem) -> CGFloat {
        guard item.maxValue > 0 else { return 0 }
        let ratio = max(0, min(CGFloat(item.value) / CGFloat(item.maxValue), 1))
        return max(8, 88 * ratio)
    }
    
    private let items: [ProfileWeeklyActivityItem]
}
