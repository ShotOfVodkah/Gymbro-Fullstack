import SwiftUI
import GymbroCommonUI
import GymbroAuth

struct ProfileSettingsView: View {
    
    init(viewModel: ProfileSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    SettingsViewStub()
                    
                case .loaded:
                    contentView
                    
                case .error:
                    VStack(alignment: .center) {
                        Text("Something went wrong, oopsie...")
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton("Refresh", size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $viewModel.isLegalSheetPresented) {
            LegalDocScreen(
                type: viewModel.legalSheetType,
                mode: .readOnly
            )
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $viewModel.isConnectedDevicesPresented) {
            ConnectedDevicesView() {
                viewModel.isConnectedDevicesPresented = false
            }
        }
        .alert("App Version", isPresented: $viewModel.isShowingAppVersionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.appVersionText)
        }
        .alert(
            viewModel.activeInfo?.title ?? "",
            isPresented: Binding(
                get: { viewModel.activeInfo != nil },
                set: { if !$0 { viewModel.activeInfo = nil } }
            ),
            actions: {
                if let secondary = viewModel.activeInfo?.secondary {
                    Button(Self.secondaryButtonTitle(secondary)) {
                        viewModel.handleInfoSecondary(secondary)
                        viewModel.activeInfo = nil
                    }
                }
                Button("OK", role: .cancel) {
                    viewModel.activeInfo = nil
                }
            },
            message: {
                if let message = viewModel.activeInfo?.message {
                    Text(message)
                }
            }
        )
        .overlay(alignment: .topLeading) {
            if viewModel.screenState == .loaded {
                UITestMarker(id: "profile.settings.screen")
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        if !section.title.isEmpty {
                            Text(section.title)
                                .foregroundStyle(.gray)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(section.items) { item in
                                SettingsRow(
                                    item: item,
                                    onTap: {
                                        viewModel.handleTap(item)
                                    },
                                    onToggle: { _ in
                                        viewModel.toggle(item)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
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
    
    @ObservedObject private var viewModel: ProfileSettingsViewModel

    private static func secondaryButtonTitle(_ action: SettingsInfoPresentation.SecondaryAction) -> String {
        switch action {
        case .openAppSettings:
            return "Open App Settings"
        case .openSupportMail:
            return "Email Support"
        }
    }
}
