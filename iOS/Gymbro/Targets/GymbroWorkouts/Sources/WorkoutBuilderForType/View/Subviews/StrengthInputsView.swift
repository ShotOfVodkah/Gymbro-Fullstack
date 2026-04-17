import SwiftUI

struct StrengthInputsView: View {
    @Binding var sets: Int
    @Binding var reps: Int
    @Binding var weightKg: Double

    var body: some View {
        HStack(spacing: 10) {
            IntField(title: String(localized: "workout.field.sets", bundle: .module), value: $sets, range: 1...12)
            IntField(title: String(localized: "workout.field.reps", bundle: .module), value: $reps, range: 1...30)
            DoubleField(title: String(localized: "workout.field.kg", bundle: .module), value: $weightKg, range: 0...300, step: 2.5)
        }
    }
}
