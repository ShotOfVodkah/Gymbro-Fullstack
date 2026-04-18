import SwiftUI
import GymbroTypes

struct StatisticsCategoryBarRow: View {
    
    init(
        item: StatisticsCategoryItem,
        maxValue: Int
    ) {
        self.item = item
        self.maxValue = max(maxValue, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.86))
                
                Spacer()
                
                Text("\(item.value)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.66))
                    .contentTransition(.numericText())
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 12)
                    
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPurple, Color.purple, Color.white.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: animateBars ? geometry.size.width * progress : 10,
                            height: 12
                        )
                        .shadow(color: Color.appPurple.opacity(0.25), radius: 8, x: 0, y: 4)
                }
            }
            .frame(height: 12)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.86)) {
                animateBars = true
            }
        }
    }
    
    private var progress: CGFloat {
        CGFloat(item.value) / CGFloat(maxValue)
    }
    
    @State private var animateBars: Bool = false
    
    private let item: StatisticsCategoryItem
    private let maxValue: Int
}
