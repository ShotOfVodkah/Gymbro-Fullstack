import SwiftUI

struct IntField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var width: CGFloat? = 35

    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            TextField("", text: Binding(
                get: { text.isEmpty ? String(value) : text },
                set: { newValue in
                    let filtered = newValue.filter(\.isNumber)
                    text = filtered

                    if let intVal = Int(filtered) {
                        value = clamp(intVal, range)
                    } else if filtered.isEmpty {
                    }
                }
            ))
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: width)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06), in: Capsule())
            .onAppear { text = String(value) }
            .onChange(of: value) { _, newValue in
                if Int(text) != newValue { text = String(newValue) }
            }
        }
    }

    private func clamp(_ v: Int, _ r: ClosedRange<Int>) -> Int {
        min(max(v, r.lowerBound), r.upperBound)
    }
}
