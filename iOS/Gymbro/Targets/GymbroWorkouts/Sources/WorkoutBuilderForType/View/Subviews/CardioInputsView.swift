import SwiftUI
import GymbroTypes

struct CardioInputsView: View {
    @Binding var duration: Int
    @Binding var pace: PaceType

    var body: some View {
        HStack(spacing: 10) {
            IntField(title: "Min", value: $duration, range: 1...240)

            Text("Pace")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            Picker("", selection: $pace) {
                ForEach(PaceType.allCases, id: \.self) { p in
                    Text(String(describing: p)).tag(p)
                }
            }
            .pickerStyle(.menu)
            .tint(.white.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06), in: Capsule())
        }
    }
}
