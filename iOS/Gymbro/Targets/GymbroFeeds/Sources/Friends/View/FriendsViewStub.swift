import SwiftUI
import GymbroCommonUI

struct FeedsPeopleViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                header
                    .padding(.top, 12)
                    .padding(.bottom, 18)
                
                searchBar
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
                
                segmentRow
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        sectionSkeleton(titleWidth: 110, rowsCount: 3)
                        sectionSkeleton(titleWidth: 88, rowsCount: 4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
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
    
    private var header: some View {
        HStack {
            RoundedRectLine(width: 92, height: 30, cornerRadius: 8)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 18, height: 18)
            
            RoundedRectLine(width: 140, height: 16, cornerRadius: 6)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(SkeletonFill())
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private var segmentRow: some View {
        HStack(spacing: 10) {
            segmentPill(width: 76)
            segmentPill(width: 84)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func segmentPill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 38)
    }
    
    private func sectionSkeleton(titleWidth: CGFloat, rowsCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectLine(width: titleWidth, height: 18, cornerRadius: 6)
            
            VStack(spacing: 10) {
                ForEach(0..<rowsCount, id: \.self) { _ in
                    personRowSkeleton
                }
            }
        }
    }
    
    private var personRowSkeleton: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 54, height: 54)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    RoundedRectLine(width: 110, height: 15, cornerRadius: 6)
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(SkeletonFill())
                        .frame(width: 56, height: 22)
                }
                
                RoundedRectLine(width: 130, height: 13, cornerRadius: 6)
                RoundedRectLine(width: 74, height: 12, cornerRadius: 6)
            }
            
            Spacer(minLength: 12)
            
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 92, height: 38)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
