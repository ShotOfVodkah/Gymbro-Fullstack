import SwiftUI
import GymbroCommonUI

struct ChallengesViewStub: View {
    
    var body: some View {
        ZStack {
            Text("Loading...")
        }
        .shimmer(active: true)
    }
}
