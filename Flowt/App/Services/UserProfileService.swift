//
//  UserProfileService.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import FirebaseFirestore
import NSFWDetector

protocol UserProfileServiceProtocol {
    func fetchProfile(uid: String) async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func deleteProfile(uid: String) async throws
    func validateAvatar(image: UIImage, threshold: Float) async throws -> Bool
}

final class UserProfileService: UserProfileServiceProtocol {
    private let db = Firestore.firestore()
    private let detector = NSFWDetector.shared
    
    // MARK: - Firestore
    func fetchProfile(uid: String) async throws -> UserProfile? {
        // doc to pojedyńczy dokument pobrany z Firestore
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        return UserProfile(id: doc.documentID, nickname: data["nickname"] as? String ?? "", avatarBase64: data["avatarBase64"] as? String)
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        try await db.collection("users").document(profile.id).setData(["nickname": profile.nickname, "avatarBase64": profile.avatarBase64 as Any])
    }
    
    func deleteProfile(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }
    
    // MARK: - helper do modelu ML (opakowujemy stare, callback-owe API w mechanizm async/await - wymuszając zaczekanie na wynik klasyfikatora)
    func validateAvatar(image: UIImage, threshold: Float) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in // to wykryje brak wywołania resume lub podwójne resume i zgłosi problem — pomaga debugować
            detector.check(image: image) { result in
                switch result {
                case let .success(nsfwConfidence: confidence):
                    if confidence > threshold {
                        // zdjęcie nieodpowiednie
                        continuation.resume(returning: false)
                    } else {
                        // zdjęcie ok
                        continuation.resume(returning: true)
                    }
                case let .error(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
