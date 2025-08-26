//
//  UserProfileService.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import FirebaseFirestore
import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String // = uid z FirebaseAuth
    var nickname: String
    var avatarBase64: String? // Base64 to metoda kodowania danych binarnych na tekst
}

final class UserProfileService {
    private let db = Firestore.firestore()
    
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
}
