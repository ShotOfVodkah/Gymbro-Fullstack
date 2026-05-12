import SwiftUI
import GymbroCommonUI

struct EditProfileViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    avatarSectionSkeleton
                    basicInfoSectionSkeleton
                    aboutSectionSkeleton
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
                Color(red: 12.0 / 255.0, green: 18.0 / 255.0, blue: 36.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var avatarSectionSkeleton: some View {
        ProfileSectionContainer {
            VStack(spacing: 16) {
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 96, height: 96)
                
                RoundedRectLine(width: 220, height: 12, cornerRadius: 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
    
    private var basicInfoSectionSkeleton: some View {
        ProfileSectionContainer(title: String(localized: "edit_profile.section_basic", bundle: .module)) {
            VStack(spacing: 14) {
                fieldSkeleton(titleWidth: 80)
                fieldSkeleton(titleWidth: 72)
                fieldSkeleton(titleWidth: 52)
                fieldSkeleton(titleWidth: 60)
            }
        }
    }
    
    private var aboutSectionSkeleton: some View {
        ProfileSectionContainer(title: String(localized: "edit_profile.section_about", bundle: .module)) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 140)
                    .overlay(
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectLine(width: 260, height: 12, cornerRadius: 6)
                            RoundedRectLine(width: 220, height: 12, cornerRadius: 6)
                            RoundedRectLine(width: 240, height: 12, cornerRadius: 6)
                            RoundedRectLine(width: 160, height: 12, cornerRadius: 6)
                            Spacer()
                        }
                        .padding(16),
                        alignment: .topLeading
                    )
                
                RoundedRectLine(width: 48, height: 12, cornerRadius: 6)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private func fieldSkeleton(titleWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectLine(width: titleWidth, height: 12, cornerRadius: 6)
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(height: 48)
                .overlay(
                    RoundedRectLine(width: 180, height: 12, cornerRadius: 6)
                        .padding(.horizontal, 14),
                    alignment: .leading
                )
        }
    }
}
