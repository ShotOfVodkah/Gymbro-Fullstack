import SwiftUI
import GymbroCommonUI


public struct LegalDocScreen: View {
    let type: LegalDocType
    let mode: LegalDocMode

    @Environment(\.dismiss) private var dismiss

    public init(
        type: LegalDocType,
        mode: LegalDocMode
    ) {
        self.type = type
        self.mode = mode
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                BlurredBackground()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(dummyText(for: type)) // заглушка
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(16)
                    }
                    bottomButton
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "legal.close", bundle: .module)) { dismiss() }
                }
            }
        }
    }
    
    private func dummyText(for type: LegalDocType) -> String {
        switch type {
        case .terms:
            return String(localized: "legal.dummy.terms", bundle: .module)
        case .privacy:
            return String(localized: "legal.dummy.privacy", bundle: .module)
        }
    }
    
    @ViewBuilder
    private var bottomButton: some View {
        switch mode {
        case .readOnly:
            EmptyView()
            
        case .acceptance(let isAlreadyAccepted, let onAccept):
            AppButton(isAlreadyAccepted ? String(localized: "legal.accepted", bundle: .module) : String(localized: "legal.accepted", bundle: .module) : String(localized: "legal.agree", bundle: .module), size: .xl) {
                onAccept()
                dismiss()
            }
            .disabled(isAlreadyAccepted)
            .opacity(isAlreadyAccepted ? 0.5 : 1.0)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}
