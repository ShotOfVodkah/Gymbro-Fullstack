import SwiftUI
import GymbroCommonUI

struct CardioTimerView: View {

    let durationSeconds: Int
    let accentColor: Color
    let onNext: (() -> Void)?

    @State private var timeRemaining: Int
    @State private var isFinished = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(durationSeconds: Int, accentColor: Color, onNext: (() -> Void)?) {
        self.durationSeconds = durationSeconds
        self.accentColor = accentColor
        self.onNext = onNext
        _timeRemaining = State(initialValue: durationSeconds)
    }

    var body: some View {
        VStack(spacing: 0) {

            if isFinished, let onNext {
                AppButton("Next →", action: onNext)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .frame(height: 120)
            } else {
                ZStack {
                    Capsule()
                        .stroke(accentColor.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 60)

                    Capsule()
                        .trim(from: 0, to: progress)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    Text(timeString)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35), value: isFinished)
        .onReceive(ticker) { _ in
            guard !isFinished else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isFinished = true
            }
        }
    }

    private var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return Double(timeRemaining) / Double(durationSeconds)
    }

    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
}
