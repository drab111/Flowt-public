//
//  VerifyEmailViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 26/08/2025.
//

import SwiftUI

@MainActor
final class VerifyEmailViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    
    private var appState: AppState
    private let authService: AuthServiceProtocol
    private var sessionTimer: Timer?
    
    init(appState: AppState, authService: AuthServiceProtocol) {
        self.appState = appState
        self.authService = authService
        startAutoCheck()
    }
    
    deinit { sessionTimer?.invalidate() }
    
    func resendVerificationEmail() async {
        do {
            try await authService.sendVerificationEmail()
            infoMessage = "A verification email has been sent."
        } catch { errorMessage = error.localizedDescription }
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            self.errorMessage = nil
            self.infoMessage = nil
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            appState.currentUser = nil
            appState.currentUserProfile = nil
            appState.currentScreen = .signIn
        } catch { errorMessage = error.localizedDescription }
    }
    
    private func startAutoCheck() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.appState.checkUserSession()
            }
        }
    }
}
