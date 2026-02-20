import SwiftUI
import GymbroCommonUI

enum LegalDocType {
    case terms
    case privacy

    var title: String {
        switch self {
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        }
    }
}

struct LegalDocScreen: View {
    let type: LegalDocType
    let isAlreadyAccepted: Bool
    let onAccept: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
                    AppButton(isAlreadyAccepted ? "✓ Already Accepted" : "I agree", size: .xl) {
                        onAccept()
                        dismiss()
                    }
                    .disabled(isAlreadyAccepted)
                    .opacity(isAlreadyAccepted ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func dummyText(for type: LegalDocType) -> String {
        switch type {
        case .terms:
            return "Terms of Service text goes here...\n\n1. You agree...\n2. You also agree...\n\n(Yes, nobody reads this.)"
        case .privacy:
            return "Privacy Policy text goes here...\n\nWe collect X, store Y, process Z...\n\n(Also nobody reads this.)"
        }
    }
}
