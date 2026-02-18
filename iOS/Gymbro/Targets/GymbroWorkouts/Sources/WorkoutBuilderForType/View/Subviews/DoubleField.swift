import SwiftUI

struct DoubleField: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double? = nil
    var width: CGFloat? = 35

    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            TextField("", text: Binding(
                get: { text.isEmpty ? format(value) : text },
                set: { newValue in
                    let cleaned = newValue
                        .replacingOccurrences(of: ",", with: ".")
                        .filter { $0.isNumber || $0 == "." }

                    let normalized = keepSingleDot(cleaned)
                    text = normalized

                    if let d = Double(normalized) {
                        var next = clamp(d, range)
                        if let step {
                            next = snap(next, step: step)
                        }
                        value = next
                    } else if normalized.isEmpty {
                    }
                }
            ))
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: width)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white.opacity(0.06), in: Capsule())
            .onAppear { text = format(value) }
            .onChange(of: value) { _, newValue in
                let formatted = format(newValue)
                if text != formatted { text = formatted }
            }
        }
    }

    private func clamp(_ v: Double, _ r: ClosedRange<Double>) -> Double {
        min(max(v, r.lowerBound), r.upperBound)
    }

    private func keepSingleDot(_ s: String) -> String {
        var sawDot = false
        return s.filter { ch in
            if ch == "." {
                if sawDot { return false }
                sawDot = true
                return true
            }
            return true
        }
    }

    private func snap(_ v: Double, step: Double) -> Double {
        guard step > 0 else { return v }
        return (v / step).rounded() * step
    }

    private func format(_ v: Double) -> String {
        let isInt = abs(v.rounded() - v) < 0.0001
        return isInt ? String(Int(v)) : String(format: "%.1f", v)
    }
}

