//
//  MockProfileService.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import SwiftUI
@testable import Flowt

final class MockProfileService: ProfileServiceProtocol {
    var mockProfiles: [String: UserProfile] = [:]
    var lastSavedProfile: UserProfile?
    var lastDeletedUID: String?
    var shouldThrowOnFetch: Bool = false
    var shouldThrowOnSave: Bool = false
    var shouldThrowOnDelete: Bool = false
    var shouldThrowOnValidate: Bool = false
    var thrownError: Error = NSError(domain: "MockProfileService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    var avatarValidationHandler: ((UIImage, Float) -> Bool)?
    
    // MARK: - Firestore
    func fetchProfile(uid: String) async throws -> UserProfile? {
        if shouldThrowOnFetch { throw thrownError }
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
        if let handler = avatarValidationHandler {
            return handler(image, threshold)
        } else { // default behaviour: always return true
            return true
        }
    }
}
