import SwiftUI
import GymbroCommonUI

struct WorkoutsStreakSheet: View {
    
    private let total: Int
    private let current: Int
    private let daysLeft: Int
    private let value: Int
    private let streakText: String
    
    init(
        total: Int,
        current: Int,
        daysLeft: Int,
        value: Int
    ) {
        self.total = total
        self.daysLeft = daysLeft
        self.current = current
        self.value = value
        self.streakText = (daysLeft <= 2)
        ? "Your streak is in danger! Let's get to work and keep on pushing!"
        : "Doing great! Keep those reps going and lock in! \nMaintaining your streak gives you achievements, unlock them all!"
    }
    var body: some View {
        VStack(spacing: 10) {
            Text("Your streak")
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 15)
            ZStack {
                Image("streak", bundle: .module)
                    .renderingMode(.template)
                    .foregroundStyle((daysLeft <= 2) ? Color.appRed : Color.appPurple)
                    .scaleEffect(0.23)
                Text("\(value)")
                    .foregroundStyle(.white)
                    .font(.system(size: 50))
                    .fontWeight(.semibold)
                    .offset(y: 15)
            }
            .frame(width: 130, height: 130)
            
            SegmentedPillProgress(
                total: total,
                current: current,
                daysLeft: daysLeft,
                color: (daysLeft <= 2) ? Color.appRed : Color.appPurple
            )
            
            Text(streakText)
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appDarkGray.ignoresSafeArea(.all))
    }
}

public struct SegmentedPillProgress: View {
    private let total: Int
    private let current: Int
    private let daysLeft: Int
    private let height: CGFloat
    private let spacing: CGFloat
    private let color: Color
    
    private let borderGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.85),
            Color.white.opacity(0.25),
            Color.white.opacity(0.0)
        ],
        startPoint: .bottomTrailing,
        endPoint: .topLeading
    )

    private let highlightGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.35),
            Color.white.opacity(0.15),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public init(
        total: Int,
        current: Int,
        daysLeft: Int,
        height: CGFloat = 10,
        spacing: CGFloat = 5,
        color: Color
    ) {
        self.total = max(1, total)
        self.current = min(max(0, current), self.total)
        self.daysLeft = daysLeft
        self.height = height
        self.spacing = spacing
        self.color = color
    }


    public var body: some View {
        VStack {
            HStack(spacing: spacing) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < current ? color: Color.white.opacity(0.18))
                        .overlay(
                            Capsule()
                                .stroke(borderGradient, lineWidth: 0.5)
                        )
                        .overlay(
                            Capsule()
                                .fill(highlightGradient)
                                .blendMode(.screen)
                        )
                        .frame(height: height)
                }
            }
            
            Text("\(daysLeft) days left")
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.all, 7)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 15)
    }
}

