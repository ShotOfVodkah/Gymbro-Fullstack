import SwiftUI
import GymbroCommonUI

struct ChatViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                header
                    .padding(.bottom, 12)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        incomingMessage
                        outgoingMessage
                        workoutMessage
                        incomingMessage
                        outgoingMessage
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                
                inputBar
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0/255.0, green: 18.0/255.0, blue: 36.0/255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 110, height: 18, cornerRadius: 6)
                RoundedRectLine(width: 70, height: 12, cornerRadius: 5)
            }
            
            Spacer()
            
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var incomingMessage: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 150, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 110, height: 14, cornerRadius: 6)
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            
            Spacer(minLength: 50)
        }
    }
    
    private var outgoingMessage: some View {
        HStack {
            Spacer(minLength: 50)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 130, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 90, height: 14, cornerRadius: 6)
            }
            .padding(14)
            .background(Color.appPurple.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }
    
    private var workoutMessage: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectLine(width: 130, height: 16, cornerRadius: 6)
                RoundedRectLine(width: 90, height: 12, cornerRadius: 5)
                RoundedRectLine(width: 60, height: 12, cornerRadius: 5)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer(minLength: 30)
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(height: 48)
                .overlay(
                    HStack {
                        RoundedRectLine(width: 110, height: 14, cornerRadius: 6)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                )
            
            Circle()
                .fill(Color.appPurple.opacity(0.8))
                .frame(width: 48, height: 48)
        }
    }
}
