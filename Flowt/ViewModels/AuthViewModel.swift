//
//  AuthViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import AuthenticationServices
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isRegistering: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    
    private var appState: AppState
    private let authService: AuthServiceProtocol
    
    init(appState: AppState, authService: AuthServiceProtocol) {
        self.appState = appState
        self.authService = authService
    }
    
    // MARK: - Email & Password Authentication
    func submit() async {
        isLoading = true
        defer { isLoading = false }
        if isRegistering {
            await signUp(email: email, password: password)
        } else {
            await signIn(email: email, password: password)
        }
    }
    
    private func signUp(email: String, password: String) async {
        do {
            let user = try await authService.signUp(email: email, password: password)
            appState.currentUser = user
            try await authService.sendVerificationEmail()
            appState.checkUserSession()
        } catch { errorMessage = error.localizedDescription }
    }
    
    private func signIn(email: String, password: String) async {
        do {
            let user = try await authService.signIn(email: email, password: password)
            appState.currentUser = user
            
            #if DEBUG
            if ProcessInfo.processInfo.environment["SET_VERIFY_EMAIL"] == "1" { appState.currentScreen = .verifyEmail; return }
            #endif
            
            if let user = authService.getCurrentUser(), !user.isEmailVerified {
                appState.currentScreen = .verifyEmail
                return
            }
            appState.currentScreen = .mainMenu(.profile)
        } catch { errorMessage = error.localizedDescription }
    }
    
    // MARK: - Apple Sign-In
    func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        authService.prepareAppleRequest(request)
    }
    
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            // 'credential' is the object returned by the system after completing Apple authentication (user identity)
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        let user = try await authService.handleAppleAuth(credential: credential)
                        appState.currentUser = user
                        appState.currentScreen = .mainMenu(.profile)
                    } catch { errorMessage = error.localizedDescription }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Account Management
    func signOut() {
        do {
            try authService.signOut()
            appState.currentUser = nil
            appState.currentUserProfile = nil
            appState.currentScreen = .signIn
        } catch { errorMessage = error.localizedDescription }
    }
    
    func deleteUserAccount() async {
        guard (appState.currentUser?.uid) != nil else { return }
        do {
            try await authService.deleteAccount()
            appState.currentUser = nil
            appState.currentScreen = .signIn
        } catch { errorMessage = error.localizedDescription }
    }
    
    // MARK: - Password Reset
    func resetPasswordWithEmail(_ email: String) async {
        guard !email.isEmpty else { return }
        do {
            try await authService.sendPasswordReset(email: email)
            infoMessage = "Password reset link sent to \(email)."
        } catch { errorMessage = error.localizedDescription }
    }
    
    // MARK: - Helpers
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    var isPasswordValid: Bool { return password.count >= 8 }

    var canSubmit: Bool { return isEmailValid && isPasswordValid }
    
    func toggleMode() {
        withAnimation(.spring()) {
            isRegistering.toggle()
            errorMessage = nil
            infoMessage = nil
        }
    }
}
