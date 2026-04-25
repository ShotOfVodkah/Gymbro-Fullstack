import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct StreakWidgetView: View {
    let payload: StreakWidgetPayload

    private var tintColor: Color {
        payload.isDangerState ? .appRed : .appPurple
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
            
            Text(WidgetStreakL10n.daysLeft(payload.daysUntilBurn))
                .font(.caption)
                .foregroundStyle(payload.isDangerState ? Color.appRed : .white)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
                .glassCapsuleStyle()
        }
        .containerBackground(for: .widget) {
            VesselFillLayout(fillRatio: payload.progressRatio) {
                Color.appDarkGray
                tintColor.opacity(0.4)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                tintColor.opacity(0.85),
                                tintColor,
                                tintColor.opacity(0.75)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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
