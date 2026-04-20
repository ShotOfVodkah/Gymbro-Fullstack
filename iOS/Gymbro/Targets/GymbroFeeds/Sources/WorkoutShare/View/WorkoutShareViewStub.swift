import SwiftUI
import GymbroCommonUI

struct WorkoutShareViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                header
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                stepIndicator
                    .padding(.top, 18)
                    .padding(.horizontal, 16)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        sessionSummaryCard
                        
                        recipientsSection
                        
                        detailsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
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
        VStack(spacing: 8) {
            RoundedRectLine(width: 170, height: 28, cornerRadius: 8)
            RoundedRectLine(width: 220, height: 14, cornerRadius: 6)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var stepIndicator: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 8, height: 8)
                
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 6)
                
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 8, height: 8)
                
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 6)
                
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 8, height: 8)
            }
            
            HStack {
                RoundedRectLine(width: 86, height: 12, cornerRadius: 6)
                Spacer()
                RoundedRectLine(width: 72, height: 12, cornerRadius: 6)
            }
        }
    }
    
    private var sessionSummaryCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 52, height: 52)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 150, height: 18, cornerRadius: 6)
                RoundedRectLine(width: 90, height: 14, cornerRadius: 6)
            }
            
            Spacer()
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var recipientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectLine(width: 94, height: 18, cornerRadius: 6)
            
            VStack(spacing: 12) {
                recipientRow
                recipientRow
                recipientRow
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectLine(width: 72, height: 18, cornerRadius: 6)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 62, height: 14, cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 52)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 70, height: 14, cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: 52)
            }
            
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(width: 46, height: 28)
                
                RoundedRectLine(width: 110, height: 16, cornerRadius: 6)
                
                Spacer()
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    
    private var recipientRow: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 120, height: 15, cornerRadius: 6)
                RoundedRectLine(width: 84, height: 12, cornerRadius: 6)
            }
            
            Spacer()
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 22, height: 22)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.72)
    }
}
