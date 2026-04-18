import Foundation
import GymbroNetwork
import GymbroTypes

protocol EditProfileService {
    func fetchProfile() async throws -> EditProfileScreenModel
    func saveProfile(_ form: EditProfileForm) async throws -> EditProfileScreenModel
}

final class EditProfileServiceImpl: EditProfileService {
    
    init(client: ProfileClient) {
        self.client = client
    }
    
    func fetchProfile() async throws -> EditProfileScreenModel {
        let response = try await client.fetchMyProfileForEdit()
        
        return EditProfileScreenModel(
            userID: response.user_id,
            fullName: response.name,
            username: response.username,
            status: response.status,
            subtitle: response.subtitle,
            bio: response.bio,
            avatarSystemName: response.avatar_system_name
        )
    }
    
    func saveProfile(_ form: EditProfileForm) async throws -> EditProfileScreenModel {
        let request = UpdateProfileRequest(
            name: form.fullName,
            username: form.username,
            status: form.status,
            subtitle: form.subtitle,
            bio: form.bio,
            avatar_system_name: form.avatarSystemName
        )
        
        let response = try await client.updateMyProfile(request)
        
        return EditProfileScreenModel(
            userID: response.user_id,
            fullName: response.name,
            username: response.username,
            status: response.status,
            subtitle: response.subtitle,
            bio: response.bio,
            avatarSystemName: response.avatar_system_name
        )
    }
    
    private let client: ProfileClient
}
