import SwiftUI

struct YogaInputsView: View {
    @Binding var holdSeconds: Int
    @Binding var breathCount: Int

    var body: some View {
        HStack(spacing: 10) {
            IntField(title: String(localized: "workout.field.hold", bundle: .module), value: $holdSeconds, range: 5...300)
            IntField(title: String(localized: "workout.field.breath", bundle: .module), value: $breathCount, range: 1...50)
        }
    }
}
