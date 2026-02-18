import SwiftUI

struct YogaInputsView: View {
    @Binding var holdSeconds: Int
    @Binding var breathCount: Int

    var body: some View {
        HStack(spacing: 10) {
            IntField(title: "Hold", value: $holdSeconds, range: 5...300)
            IntField(title: "Breath", value: $breathCount, range: 1...50)
        }
    }
}
