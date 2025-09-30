//
//  UserProfile.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

struct UserProfile: Identifiable, Codable {
    var id: String // = uid z FirebaseAuth
    var nickname: String
    var avatarBase64: String? // Base64 to metoda kodowania danych binarnych na tekst
    var musicEnabled: Bool
    var sfxEnabled: Bool
}
