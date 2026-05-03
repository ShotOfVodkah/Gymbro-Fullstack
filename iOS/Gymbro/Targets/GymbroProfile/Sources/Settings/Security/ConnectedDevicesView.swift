import SwiftUI
import GymbroNetwork

struct ConnectedDevicesView: View {

    @StateObject private var viewModel: ConnectedDevicesViewModel
    @Environment(\.dismiss) private var dismiss

    init(onSessionEnded: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: ConnectedDevicesViewModel(
                onSessionEnded: onSessionEnded
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                content
            }
            .navigationTitle("Connected Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.screenState {
        case .loading:
            ProgressView()
                .tint(.white)

        case .loaded:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Manage sessions where your GymBro account is currently signed in.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))

                    ForEach(viewModel.sessions) { session in
                        sessionRow(session)
                    }

                    Button {
                        viewModel.logoutAllDevices()
                    } label: {
                        Text("Log out from all devices")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 10)
                }
                .padding()
            }

        case .error(let message):
            VStack(spacing: 16) {
                Text("Something went wrong")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                Button("Try again") {
                    viewModel.load()
                }
                .foregroundStyle(.white)
            }
            .padding()
        }
    }

    private func sessionRow(_ session: AuthSessionResponse) -> some View {
        Button {
            viewModel.revoke(session)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: session.platform.lowercased() == "ios" ? "iphone" : "desktopcomputer")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.appPurple.opacity(0.35))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(session.deviceName)
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            if session.isCurrent {
                                Text("This device")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        Text(session.platform)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    
                    Spacer()
                }
                
                HStack {
                    if let ip = session.ipAddress {
                        Text("IP: \(ip)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Spacer()
                    Text(session.isCurrent ? "Log out this device" : "Revoke session")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
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
}
