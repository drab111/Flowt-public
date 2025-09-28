//
//  UserProfileViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class UserProfileViewModel: ObservableObject {
    enum SaveState { case idle, saving, saved, rejected }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentNickname: String = ""
    @Published var newNickname: String = ""
    @Published var avatarData: Data?
    @Published var saveState: SaveState = .idle
    
    private var appState: AppState
    private let profileService: UserProfileServiceProtocol
    
    init(appState: AppState, profileService: UserProfileServiceProtocol) {
        self.appState = appState
        self.profileService = profileService
    }
    
    func loadUserProfile() async {
        isLoading = true
        defer { isLoading = false }
        guard let uid = appState.currentUser?.uid else { return }
        do {
            if let profile = try await profileService.fetchProfile(uid: uid) {
                appState.currentUserProfile = profile
                currentNickname = profile.nickname
                avatarData = profile.avatarBase64.flatMap { Data(base64Encoded: $0) }
            } else {
                errorMessage = "New profile"
                currentNickname = "Player \(String(uid.prefix(5)))"
                avatarData = nil
                let profile = UserProfile(id: uid, nickname: currentNickname, avatarBase64: nil)
                try await profileService.saveProfile(profile)
                appState.currentUserProfile = profile
            }
        } catch { errorMessage = error.localizedDescription }
    }
    
    func updateProfile(nickname: String, imageData: Data?) async {
        saveState = .saving
        defer { saveState = .idle }
        guard let uid = appState.currentUser?.uid else { return }
        do {
            let finalNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? currentNickname : nickname
            
            var avatarBase64: String? = appState.currentUserProfile?.avatarBase64
            if let imageData = imageData, let image = UIImage(data: imageData) {
                
                // Sprawdzanie czy zdjęcie nie jest niestosowne używając modelu ML
                let isSafe = try await profileService.validateAvatar(image: image, threshold: 0.5)
                
                // Odrzucenie zapisu w przypadku niestosowności
                if !isSafe {
                    saveState = .rejected
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    if !Task.isCancelled { saveState = .idle }
                    return
                }
                
                // Zdjęcie jest stosowne
                let resized = image.resized(to: 200)
                avatarBase64 = resized.toBase64(maxSizeKB: 100)
            }
            
            let profile = UserProfile(id: uid, nickname: finalNickname, avatarBase64: avatarBase64)
            try await profileService.saveProfile(profile)
            appState.currentUserProfile = profile
            currentNickname = profile.nickname
            avatarData = profile.avatarBase64.flatMap { Data(base64Encoded: $0) }
            newNickname = ""
            
            // sukces
            saveState = .saved
            // automatyczny powrót do "idle" po 1.5 sekundy
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if !Task.isCancelled { saveState = .idle }
        } catch {
            errorMessage = error.localizedDescription
            saveState = .idle
        }
    }
    
    func deleteProfile() async {
        guard let uid = appState.currentUser?.uid else { return }
        do {
            try await profileService.deleteProfile(uid: uid)
            appState.currentUserProfile = nil
            appState.currentScreen = .signIn
        } catch { errorMessage = error.localizedDescription }
    }
}
