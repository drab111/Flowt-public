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
    @Published var currentUser: AuthUser?
    @Published var errorMessage: String?
    
    private var appState: AppState
    private let auth = AuthService()
    
    init(appState: AppState) { self.appState = appState }
    
    // MARK: - Sign in with Email & Password
    func signUp(email: String, password: String) async {
        do {
            currentUser = try await auth.signUp(email: email, password: password)
            appState.currentUser = currentUser
            refreshSession()
            try await auth.sendVerificationEmail()
        } catch { errorMessage = error.localizedDescription }
    }
    
    func signIn(email: String, password: String) async {
        do {
            currentUser = try await auth.signIn(email: email, password: password)
            appState.currentUser = currentUser
            if let user = auth.getCurrentUser(), !user.isEmailVerified {
                appState.currentScreen = .verifyEmail
                return
            }
            appState.currentScreen = .mainMenu
        } catch { errorMessage = error.localizedDescription }
    }
    
    // MARK: - Sign in with Apple
    func handleAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        auth.prepareAppleRequest(request)
    }
    
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            // credential - to obiekt zwracany przez system po zakończeniu procesu autoryzacji Apple (tożsamość usera)
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        currentUser = try await auth.handleAppleAuth(credential: credential)
                        appState.currentUser = currentUser
                        appState.currentScreen = .mainMenu
                    } catch { errorMessage = error.localizedDescription }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helpers
    func resendVerificationEmail() async {
        do {
            try await auth.sendVerificationEmail()
            errorMessage = "A verification email has been sent."
        } catch { errorMessage = error.localizedDescription }
    }
    
    func refreshSession() { appState.checkUserSession() }
    
    func signOut() { appState.signOut() }
}
