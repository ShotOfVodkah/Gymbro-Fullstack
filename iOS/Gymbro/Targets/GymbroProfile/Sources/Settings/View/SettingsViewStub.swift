import SwiftUI
import GymbroCommonUI

struct SettingsViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    settingsSectionSkeleton(titleWidth: 72, rowCount: 3, hasToggleRows: [false, false, false])
                    
                    settingsSectionSkeleton(titleWidth: 110, rowCount: 4, hasToggleRows: [true, true, true, true])
                    
                    settingsSectionSkeleton(titleWidth: 68, rowCount: 4, hasToggleRows: [true, true, true, false])
                    
                    settingsSectionSkeleton(titleWidth: 92, rowCount: 4, hasToggleRows: [true, true, true, false])
                    
                    settingsSectionSkeleton(titleWidth: 104, rowCount: 5, hasToggleRows: [false, false, false, false, false])
                    
                    destructiveSectionSkeleton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12/255, green: 18/255, blue: 36/255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func settingsSectionSkeleton(
        titleWidth: CGFloat,
        rowCount: Int,
        hasToggleRows: [Bool]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectLine(width: titleWidth, height: 14, cornerRadius: 6)
                .padding(.leading, 2)
            
            VStack(spacing: 10) {
                ForEach(0..<rowCount, id: \.self) { index in
                    settingsRowSkeleton(
                        hasToggle: hasToggleRows.indices.contains(index) ? hasToggleRows[index] : false
                    )
                }
            }
        }
    }
    
    private var destructiveSectionSkeleton: some View {
        VStack(spacing: 10) {
            settingsRowSkeleton(hasToggle: false)
        }
    }
    
    private func settingsRowSkeleton(hasToggle: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(SkeletonFill())
                .frame(width: 18, height: 18)
            
            RoundedRectLine(width: 140, height: 14, cornerRadius: 6)
            
            Spacer()
            
            if hasToggle {
                Capsule()
                    .fill(SkeletonFill())
                    .frame(width: 52, height: 32)
            } else {
                RoundedRectLine(width: 8, height: 14, cornerRadius: 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05)) // ← только серый, без градиента
        )
    }
}
