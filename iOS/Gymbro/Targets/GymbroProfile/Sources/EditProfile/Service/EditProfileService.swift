import Foundation
import GymbroNetwork
import GymbroTypes

protocol EditProfileService {
    func fetchProfile() async throws -> EditProfileScreenModel
    func saveProfile(_ form: EditProfileForm) async throws
}

final class EditProfileServiceImpl: EditProfileService {
    
    private var storedProfile: EditProfileScreenModel = EditProfileMocks.profile
    
    func fetchProfile() async throws -> EditProfileScreenModel {
        try await Task.sleep(nanoseconds: 250_000_000)
        return storedProfile
    }
    
    func saveProfile(_ form: EditProfileForm) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        storedProfile = EditProfileScreenModel(
            userID: storedProfile.userID,
            fullName: form.fullName,
            username: form.username,
            status: form.status,
            subtitle: form.subtitle,
            bio: form.bio,
            avatarSystemName: form.avatarSystemName
        )
    }
}
