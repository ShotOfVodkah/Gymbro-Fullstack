import SwiftUI
import GymbroCommonUI

struct BlurredBackground: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Circle()
                .fill(Color.strengthColor)
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: -90, y: -250)

            Circle()
                .fill(Color.cardioColor)
                .frame(width: 300, height: 300)
                .blur(radius: 140)
                .offset(x: 90, y: 0)

            Circle()
                .fill(Color.yogaColor)
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: -90, y: 260)

            Color.black.opacity(0.3)
                .ignoresSafeArea()
        }
    }
}
