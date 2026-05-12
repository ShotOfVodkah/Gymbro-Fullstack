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
                        Text(GymbroCommonStrings.genericError)
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton(GymbroCommonStrings.refresh, size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(String(localized: "edit_profile.nav_title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "edit_profile.cancel", bundle: .module)) {
                    viewModel.didTapCancel()
                }
                .foregroundStyle(.white)
                .accessibilityIdentifier("profile.edit.cancel")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isSaving ? String(localized: "edit_profile.saving", bundle: .module) : String(localized: "edit_profile.save", bundle: .module)) {
                    viewModel.didTapSave()
                }
                .foregroundStyle(viewModel.canSave ? .white : .gray)
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("profile.edit.save")
            }
        }
        .alert(String(localized: "edit_profile.discard_title", bundle: .module), isPresented: $viewModel.shouldShowDiscardAlert) {
            Button(String(localized: "edit_profile.keep_editing", bundle: .module), role: .cancel) {
                viewModel.dismissDiscardAlert()
            }
            Button(String(localized: "edit_profile.discard", bundle: .module), role: .destructive) {
                viewModel.confirmDiscardChanges()
            }
        } message: {
            Text(String(localized: "edit_profile.discard_body", bundle: .module))
        }
        .overlay(alignment: .top) {
            if viewModel.didSaveSuccessfully {
                Text(String(localized: "edit_profile.saved", bundle: .module))
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
                
                ProfileSectionContainer(title: String(localized: "edit_profile.section_basic", bundle: .module)) {
                    VStack(spacing: 14) {
                        EditProfileTextField(
                            title: String(localized: "edit_profile.field_full_name", bundle: .module),
                            text: Binding(
                                get: { viewModel.form.fullName },
                                set: viewModel.updateName
                            ),
                            autocapitalization: .words,
                            disableAutocorrection: true,
                            accessibilityIdentifier: "profile.edit.field.fullName"
                        )
                        
                        EditProfileTextField(
                            title: String(localized: "edit_profile.field_username", bundle: .module),
                            text: Binding(
                                get: { viewModel.form.username },
                                set: viewModel.updateUsername
                            ),
                            accessibilityIdentifier: "profile.edit.field.username"
                        )
                        
                        EditProfileTextField(
                            title: String(localized: "edit_profile.field_status", bundle: .module),
                            text: Binding(
                                get: { viewModel.form.status },
                                set: viewModel.updateStatus
                            ),
                            autocapitalization: .sentences,
                            disableAutocorrection: true,
                            accessibilityIdentifier: "profile.edit.field.status"
                        )
                        
                        EditProfileTextField(
                            title: String(localized: "edit_profile.field_subtitle", bundle: .module),
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
                
                ProfileSectionContainer(title: String(localized: "edit_profile.section_about", bundle: .module)) {
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
