import SwiftUI
import GymbroTypes

struct ChallengeRulesView: View {
    
    let rules: [ChallengeRulesModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("Rules", "How this challenge counts progress")
            
            VStack(spacing: 10) {
                ForEach(rules) { rule in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.green)
                        
                        Text(rule.text)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.66))
                        
                        Spacer()
                    }
                    .padding(13)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
                }
            }
        }
    }
}
