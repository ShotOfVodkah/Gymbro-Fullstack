import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct StreakWidgetView: View {
    let payload: StreakWidgetPayload

    private var fillGradient: LinearGradient {
        if payload.wasFreezeUsedThisWeek {
            return LinearGradient(
                colors: [
                    Color.cyan.opacity(0.95),
                    Color.blue.opacity(0.72),
                    Color.blue.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        if payload.isGoalCompleted {
            return LinearGradient(
                colors: [
                    Color.green.opacity(0.95),
                    Color.mint.opacity(0.78),
                    Color.mint.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        let tint = payload.isDangerState ? Color.appRed : Color.appPurple
        return LinearGradient(
            colors: [
                tint.opacity(0.85),
                tint,
                tint.opacity(0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var rimTint: Color {
        if payload.wasFreezeUsedThisWeek { return .cyan }
        if payload.isGoalCompleted { return .mint }
        return payload.isDangerState ? .appRed : .appPurple
    }

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(WidgetStreakL10n.streakTitle)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .glassCapsuleStyle()

            Spacer()

            ZStack {
                Image("streak", bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .scaleEffect(1.55)
                Text("\(payload.streakValue)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .scaleEffect(0.75)
                    .offset(y: 10)
            }

            Spacer()

            VStack(spacing: 4) {
                Text(WidgetStreakL10n.daysLeft(payload.daysUntilBurn))
                    .font(.caption)
                    .foregroundStyle(payload.isDangerState ? Color.appRed : .white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
                    .glassCapsuleStyle()

                if payload.wasFreezeUsedThisWeek {
                    Text(WidgetStreakL10n.streakFreezeProtected)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .containerBackground(for: .widget) {
            VesselFillLayout(fillRatio: payload.progressRatio) {
                Color.appDarkGray
                rimTint.opacity(0.4)
                RoundedRectangle(cornerRadius: 16)
                    .fill(fillGradient)
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.15),
                                        Color.clear
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
            }
        }
    }
}
