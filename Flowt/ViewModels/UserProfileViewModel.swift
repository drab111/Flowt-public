//
//  UserProfileViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentNickname: String = ""
    @Published var avatarData: Data?
    
    private var appState: AppState
    private let profileService = UserProfileService()
    
    init(appState: AppState) { self.appState = appState }
    
    func loadUserProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let uid = appState.currentUser?.uid else { return }
        do {
            if let profile = try await profileService.fetchProfile(uid: uid) {
                appState.currentUserProfile = profile
                currentNickname = profile.nickname
                if currentNickname == "" { currentNickname = "Player \(uid)" }
                avatarData = profile.avatarBase64.flatMap { Data(base64Encoded: $0) }
            } else {
                errorMessage = "Profile not found"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(nickname: String, imageData: Data?) async {
        guard let uid = appState.currentUser?.uid else { return }
        do {
            var avatarBase64: String? = appState.currentUserProfile?.avatarBase64
            if let imageData = imageData, let image = UIImage(data: imageData) {
                // zmniejszamy i kompresujemy
                let resized = image.resized(to: 200)
                avatarBase64 = resized.toBase64(maxSizeKB: 500)
            }
            let profile = UserProfile(id: uid, nickname: nickname, avatarBase64: avatarBase64)
            try await profileService.saveProfile(profile)
            appState.currentUserProfile = profile
            currentNickname = profile.nickname
            avatarData = profile.avatarBase64.flatMap { Data(base64Encoded: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
