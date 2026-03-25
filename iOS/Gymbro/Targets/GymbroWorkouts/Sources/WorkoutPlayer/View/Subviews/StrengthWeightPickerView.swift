import SwiftUI

struct WeightPickerView: View {

    @Binding var weight: Double
    let accentColor: Color

    @State private var scrollIndex: Int?

    private let step: Double = 2.5
    private let maxKg: Double = 300.0
    private let itemWidth: CGFloat = 64

    private var itemCount: Int { Int(maxKg / step) + 1 }
    private func kg(at index: Int) -> Double { Double(index) * step }
    private func index(for kg: Double) -> Int {
        max(0, min(Int(round(kg / step)), itemCount - 1))
    }

    init(weight: Binding<Double>, accentColor: Color) {
        self._weight = weight
        self.accentColor = accentColor
        _scrollIndex = State(initialValue: max(0, min(Int(round(weight.wrappedValue / 2.5)), Int(300.0 / 2.5))))
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Update your weight")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.6))

            GeometryReader { geo in
                let sidePad = (geo.size.width - itemWidth) / 2
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(0..<itemCount, id: \.self) { idx in
                                Text(formatKg(kg(at: idx)))
                                    .font(.system(.callout, design: .rounded).weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: itemWidth, height: 44)
                                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(1.0 - min(abs(phase.value), 1.0) * 0.72)
                                            .scaleEffect(1.0 - min(abs(phase.value), 1.0) * 0.28)
                                    }
                                    .id(idx)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, sidePad, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollIndex)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accentColor.opacity(0.18))
                            .strokeBorder(
                                LinearGradient(
                                    colors: [accentColor.opacity(0.7), accentColor.opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: itemWidth, height: 44)
                            .allowsHitTesting(false)
                    )
                    .onAppear {
                        proxy.scrollTo(index(for: weight), anchor: .center)
                    }
                    .onChange(of: scrollIndex) { old, newIdx in
                        guard let newIdx, old != nil else { return }
                        weight = kg(at: newIdx)
                    }
                }
            }
            .frame(height: 44)
        }
    }
    
    private func formatKg(_ kg: Double) -> String {
        kg.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(kg)) kg"
            : String(format: "%.1f kg", kg)
    }
}
