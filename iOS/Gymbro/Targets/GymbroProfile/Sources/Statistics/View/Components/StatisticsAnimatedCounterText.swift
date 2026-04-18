import SwiftUI

struct StatisticsAnimatedCounterText: View {
    
    init(
        value: Int,
        suffix: String = "",
        font: Font = .title.weight(.bold)
    ) {
        self.value = value
        self.suffix = suffix
        self.font = font
    }
    
    var body: some View {
        Text("\(displayValue)\(suffix)")
            .font(font)
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: 0.6)) {
                    displayValue = newValue
                }
            }
    }
    
    @State private var displayValue: Int = 0
    
    private let value: Int
    private let suffix: String
    private let font: Font
}
