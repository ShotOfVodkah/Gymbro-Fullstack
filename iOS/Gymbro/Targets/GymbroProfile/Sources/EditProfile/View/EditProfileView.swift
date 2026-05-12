import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct EditProfileView: View {
    
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    EditProfileViewStub()
                    
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
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    viewModel.didTapCancel()
                }
                .foregroundStyle(.white)
                .accessibilityIdentifier("profile.edit.cancel")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isSaving ? "Saving..." : "Save") {
                    viewModel.didTapSave()
                }
                .foregroundStyle(viewModel.canSave ? .white : .gray)
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("profile.edit.save")
            }
        }
        .alert("Discard changes?", isPresented: $viewModel.shouldShowDiscardAlert) {
            Button("Keep Editing", role: .cancel) {
                viewModel.dismissDiscardAlert()
            }
            Button("Discard", role: .destructive) {
                viewModel.confirmDiscardChanges()
            }
        } message: {
            Text("Your changes will be lost.")
        }
        .overlay(alignment: .top) {
            if viewModel.didSaveSuccessfully {
                Text("Profile saved")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.appPurple.opacity(0.95))
                    )
                    .padding(.top, 12)
            }
        }
        .onChange(of: viewModel.didSaveSuccessfully) { _, newValue in
            guard newValue else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.dismissSaveBanner()
            }
        }
        .overlay(alignment: .topLeading) {
            if viewModel.screenState == .loaded {
                UITestMarker(id: "profile.edit.screen")
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                EditProfileAvatarSection(
                    avatarSystemName: viewModel.form.avatarSystemName
                )
                
                ProfileSectionContainer(title: "Basic Info") {
                    VStack(spacing: 14) {
                        EditProfileTextField(
                            title: "Full Name",
                            text: Binding(
                                get: { viewModel.form.fullName },
                                set: viewModel.updateName
                            ),
                            autocapitalization: .words,
                            disableAutocorrection: true,
                            accessibilityIdentifier: "profile.edit.field.fullName"
                        )
                        
                        EditProfileTextField(
                            title: "Username",
                            text: Binding(
                                get: { viewModel.form.username },
                                set: viewModel.updateUsername
                            ),
                            accessibilityIdentifier: "profile.edit.field.username"
                        )
                        
                        EditProfileTextField(
                            title: "Status",
                            text: Binding(
                                get: { viewModel.form.status },
                                set: viewModel.updateStatus
                            ),
                            autocapitalization: .sentences,
                            disableAutocorrection: true,
                            accessibilityIdentifier: "profile.edit.field.status"
                        )
                        
                        EditProfileTextField(
                            title: "Subtitle",
                            text: Binding(
                                get: { viewModel.form.subtitle },
                                set: viewModel.updateSubtitle
                            ),
                            autocapitalization: .sentences,
                            disableAutocorrection: true,
                            accessibilityIdentifier: "profile.edit.field.subtitle"
                        )
                    }
                }
                
                ProfileSectionContainer(title: "About") {
                    EditProfileBioEditor(
                        text: Binding(
                            get: { viewModel.form.bio },
                            set: viewModel.updateBio
                        ),
                        limit: 220,
                        accessibilityIdentifier: "profile.edit.field.bio"
                    )
                }
                
                if !viewModel.validationErrors.isEmpty {
                    EditProfileValidationView(
                        messages: viewModel.validationErrors.map(\.message)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .refreshable {
            await viewModel.refresh()
        }
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
    
    @ObservedObject private var viewModel: EditProfileViewModel
}
