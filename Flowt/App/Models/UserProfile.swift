//
//  UserProfile.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

struct UserProfile: Identifiable, Codable {
    var id: String // = uid in FirebaseAuth
    var nickname: String
    var avatarBase64: String?
    var musicEnabled: Bool
    var sfxEnabled: Bool
}
