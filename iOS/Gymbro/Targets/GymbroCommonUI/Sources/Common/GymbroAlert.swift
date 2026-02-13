import SwiftUI

public struct CustomAlertData {
    public let message: String?
    public let primaryButton: AppButton?
    
    public init(
        message: String? = nil,
        primaryButton: AppButton? = nil
    ) {
        self.message = message
        self.primaryButton = primaryButton
    }
}

public struct CustomAlert: View {
    @Binding private var isPresented: Bool
    @State private var opacity: Double = 0.0
    private let data: CustomAlertData
    
    public init(
        isPresented: Binding<Bool>,
        data: CustomAlertData
    ) {
        self._isPresented = isPresented
        self.data = data
    }
    
    public var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismiss()
                    }
            }
            
            if isPresented {
                alertContent
                    .opacity(opacity)
            }
        }
        .onChange(of: isPresented) { newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                opacity = newValue ? 1.0 : 0.0
            }
        }
    }
    
    @ViewBuilder
    private var alertContent: some View {
        VStack(spacing: 24) {
            if let message = data.message {
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            if data.primaryButton != nil{
                VStack(spacing: 12) {
                    if let primary = data.primaryButton {
                        primary
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, data.primaryButton != nil ? 32 : 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.black))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

public extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        data: CustomAlertData
    ) -> some View {
        self.overlay {
            CustomAlert(isPresented: isPresented, data: data)
        }
    }
}
