//
//  ProfileService.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import FirebaseFirestore
import NSFWDetector

protocol ProfileServiceProtocol {
    func fetchProfile(uid: String) async throws -> UserProfile?
    func fetchProfiles(uids: [String]) async throws -> [UserProfile]
    func saveProfile(_ profile: UserProfile) async throws
    func deleteProfile(uid: String) async throws
    func validateAvatar(image: UIImage, threshold: Float) async throws -> Bool
}

final class ProfileService: ProfileServiceProtocol {
    private let db = Firestore.firestore()
    private let detector = NSFWDetector.shared
    
    // MARK: - Firestore
    func fetchProfile(uid: String) async throws -> UserProfile? {
        // 'doc' represents a single Firestore document
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        return UserProfile(
            id: doc.documentID,
            nickname: data["nickname"] as? String ?? "",
            avatarBase64: data["avatarBase64"] as? String,
            musicEnabled: data["musicEnabled"] as? Bool ?? true,
            sfxEnabled: data["sfxEnabled"] as? Bool ?? true
        )
    }

    func fetchProfiles(uids: [String]) async throws -> [UserProfile] {
        guard !uids.isEmpty else { return [] }
        
        let snapshot = try await db.collection("users")
            .whereField(FieldPath.documentID(), in: uids)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            let data = doc.data()
            return UserProfile(
                id: doc.documentID,
                nickname: data["nickname"] as? String ?? "",
                avatarBase64: data["avatarBase64"] as? String,
                musicEnabled: data["musicEnabled"] as? Bool ?? true,
                sfxEnabled: data["sfxEnabled"] as? Bool ?? true
            )
        }
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        try await db.collection("users").document(profile.id).setData([
            "nickname": profile.nickname,
            "avatarBase64": profile.avatarBase64 as Any,
            "musicEnabled": profile.musicEnabled,
            "sfxEnabled": profile.sfxEnabled
        ])
    }
    
    func deleteProfile(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }
    
    // MARK: - Avatar Validation (ML)
    // Wraps legacy callback-based API into async/await, ensuring proper suspension until the classifier returns a result
    func validateAvatar(image: UIImage, threshold: Float) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            // Detects missing or multiple 'resume' calls — helpful for debugging
            var didResume = false
            
            detector.check(image: image) { result in
                guard !didResume else { return }
                didResume = true
                
                switch result {
                case let .success(nsfwConfidence: confidence):
                    if confidence > threshold {
                        // Inappropriate image
                        continuation.resume(returning: false)
                    } else {
                        // Image accepted
                        continuation.resume(returning: true)
                    }
                case let .error(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
