import SwiftUI

struct StrengthInputsView: View {
    @Binding var sets: Int
    @Binding var reps: Int
    @Binding var weightKg: Double

    var body: some View {
        HStack(spacing: 10) {
            IntField(title: "Sets", value: $sets, range: 1...12)
            IntField(title: "Reps", value: $reps, range: 1...30)
            DoubleField(title: "Kg", value: $weightKg, range: 0...300, step: 2.5)
        }
    }
}
