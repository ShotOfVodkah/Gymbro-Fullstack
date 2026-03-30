import SwiftUI
import Lottie
import Foundation

public struct GymbroLottieView: View {
    var name: String
    var loopMode: LottieLoopMode = .loop

    public init(
        name: String,
        loopMode: LottieLoopMode = .loop
    ) {
        self.name = name
        self.loopMode = loopMode
    }

    public var body: some View {
        LottieView(animation: .named(name))
            .playing(loopMode: loopMode)
            .allowsHitTesting(false)
    }
}
