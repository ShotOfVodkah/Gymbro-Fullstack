import SwiftUI
import GymbroCommonUI

struct WorkoutBuilderForTypeViewStub: View {

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    selectedExercisesSection
                        .padding(.top, 16)

                    availableHeader
                        .padding(.top, 18)

                    availableDivSkeleton
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                }
            }

            saveButtonSkeleton
                .padding(.horizontal, 8)
                .padding(.bottom, 30)
        }
        .shimmer(active: true)
    }

    private var selectedExercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectLine(width: 220, height: 18, cornerRadius: 7)
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { i in
                    exerciseCardSkeleton(accentOpacity: 0.55 + Double(i % 3) * 0.08)
                        .padding(.horizontal, 16)
                }
            }
        }
    }

    private func exerciseCardSkeleton(accentOpacity: Double) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color.white.opacity(accentOpacity)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8)
                .padding(.vertical, 10)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 180, height: 18, cornerRadius: 7)

                HStack(spacing: 10) {
                    capsuleFieldSkeleton(width: 74)
                    capsuleFieldSkeleton(width: 74)
                    capsuleFieldSkeleton(width: 86)
                }
            }
            .padding(.vertical, 12)

            Spacer(minLength: 0)

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.35))
        }
        .padding(.horizontal, 7)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func capsuleFieldSkeleton(width: CGFloat) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.10))
            .frame(width: width, height: 32)
            .overlay(
                RoundedRectLine(width: width * 0.55, height: 12, cornerRadius: 6)
            )
    }

    private var availableHeader: some View {
        HStack(spacing: 12) {
            RoundedRectLine(width: 190, height: 18, cornerRadius: 7)

            Spacer()

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.35))
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var availableDivSkeleton: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                divRowSkeleton
                    .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        divChipSkeleton
                            .frame(width: 160, height: 96)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 6)
        }
    }

    private var divRowSkeleton: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectLine(width: 18, height: 18, cornerRadius: 6)
                )

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 220, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 160, height: 12, cornerRadius: 6)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var divChipSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectLine(width: 110, height: 14, cornerRadius: 6)
                .padding(.top, 14)
                .padding(.horizontal, 14)

            RoundedRectLine(width: 130, height: 12, cornerRadius: 6)
                .padding(.horizontal, 14)

            Spacer(minLength: 0)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var saveButtonSkeleton: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.16))

            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            RoundedRectLine(width: 90, height: 16, cornerRadius: 7)
        }
        .frame(height: 56)
    }
}
