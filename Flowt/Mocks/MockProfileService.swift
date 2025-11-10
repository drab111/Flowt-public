#if DEBUG

//
//  MockProfileService.swift
//  Flowt
//
//  Created by Wiktor Drab on 07/11/2025.
//

import SwiftUI

final class MockProfileService: ProfileServiceProtocol {
    var mockProfiles: [String: UserProfile] = [:]
    var lastSavedProfile: UserProfile?
    var lastDeletedUID: String?
    var shouldThrowOnFetch: Bool = false
    var shouldThrowOnSave: Bool = false
    var shouldThrowOnDelete: Bool = false
    var shouldThrowOnValidate: Bool = false
    var shouldReturnFalseOnValidate: Bool = false
    var thrownError: Error = NSError(domain: "MockProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    var avatarValidationHandler: ((UIImage, Float) -> Bool)?
    
    init() {
        let env = ProcessInfo.processInfo.environment
        if env["MOCK_PROFILE_SHOULD_THROW_FETCH"] == "1" { shouldThrowOnFetch = true }
        if env["MOCK_PROFILE_SHOULD_THROW_SAVE"] == "1" { shouldThrowOnSave = true }
        if env["MOCK_PROFILE_SHOULD_THROW_DELETE"] == "1" { shouldThrowOnDelete = true }
        if env["MOCK_PROFILE_SHOULD_THROW_VALIDATE"] == "1" { shouldThrowOnValidate = true }
        if env["MOCK_PROFILE_SHOULD_RETURN_FALSE_ON_VALIDATE"] == "1" { shouldReturnFalseOnValidate = true }
        
        if let base64 = env["PRELOAD_AVATAR_BASE64"] {
            let profile = UserProfile(
                id: "user-with-avatar",
                nickname: "UI Tester",
                avatarBase64: base64,
                musicEnabled: true,
                sfxEnabled: true
            )
            mockProfiles["user-with-avatar"] = profile
        }
    }
    
    // MARK: - Firestore
    func fetchProfile(uid: String) async throws -> UserProfile? {
        if shouldThrowOnFetch { throw thrownError }
        
        // to simulate a user already having an avatar loaded
        let env = ProcessInfo.processInfo.environment
        if env["PRELOAD_AVATAR_BASE64"] != nil {
            return mockProfiles["user-with-avatar"]
        }
        
        // normal path
        return mockProfiles[uid]
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        if shouldThrowOnSave { throw thrownError }
        mockProfiles[profile.id] = profile
        lastSavedProfile = profile
    }
    
    func deleteProfile(uid: String) async throws {
        if shouldThrowOnDelete { throw thrownError }
        mockProfiles.removeValue(forKey: uid)
        lastDeletedUID = uid
    }
    
    // MARK: - Avatar Validation
    func validateAvatar(image: UIImage, threshold: Float) async throws -> Bool {
        if shouldThrowOnValidate { throw thrownError }
        if shouldReturnFalseOnValidate { return false }
        if let handler = avatarValidationHandler {
            return handler(image, threshold)
        } else { // default behaviour: always return true
            return true
        }
    }
}

#endif
