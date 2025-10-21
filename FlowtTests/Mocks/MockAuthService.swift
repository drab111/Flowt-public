//
//  MockAuthService.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/10/2025.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
@testable import Flowt

final class MockAuthService: AuthServiceProtocol {
    var shouldThrowOnSignUp: Bool = false
    var shouldThrowOnSignIn: Bool = false
    var shouldThrowOnSignOut: Bool = false
    var shouldThrowOnDelete: Bool = false
    var shouldThrowOnSendVerification: Bool = false
    var shouldThrowOnPasswordReset: Bool = false
    var thrownError: Error = NSError(domain: "MockAuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

    var currentAuthUser: AuthUser? = nil
    private(set) var lastGeneratedNonce: String?

    // MARK: - Email & Password
    func signUp(email: String, password: String) async throws -> AuthUser {
        if shouldThrowOnSignUp { throw thrownError }
        let user = AuthUser(uid: UUID().uuidString, displayName: nil, email: email)
        currentAuthUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        if shouldThrowOnSignIn { throw thrownError }
        if let user = currentAuthUser, user.email == email {
            return user
        } else {
            let user = AuthUser(uid: UUID().uuidString, displayName: nil, email: email)
            currentAuthUser = user
            return user
        }
    }

    // MARK: - Apple Sign-In
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = "mocked-nonce-\(UUID().uuidString.prefix(6))"
        lastGeneratedNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleAuth(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser {
        // W mocku ignorujemy tokeny i tworzymy użytkownika bazując na credential.fullName / email (jeśli są)
        // Możemy też wymusić błąd
        if shouldThrowOnSignIn { throw thrownError }
        let displayName = credential.fullName?.givenName
        // w testach często credential.email będzie nil — użyjemy placeholdera
        let emailCandidate = credential.email ?? "apple-\(UUID().uuidString.prefix(6))@mock"
        let user = AuthUser(uid: UUID().uuidString, displayName: displayName, email: emailCandidate)
        currentAuthUser = user
        return user
    }

    // MARK: - Account Management
    func deleteAccount() async throws {
        if shouldThrowOnDelete { throw thrownError }
        currentAuthUser = nil
    }
    
    func getCurrentUser() -> User? { return nil } // never return User so that there is no connection with Firebase

    func signOut() throws {
        if shouldThrowOnSignOut { throw thrownError }
        currentAuthUser = nil
    }

    func sendVerificationEmail() async throws {
        if shouldThrowOnSendVerification { throw thrownError }
    }

    func sendPasswordReset(email: String) async throws {
        if shouldThrowOnPasswordReset { throw thrownError }
    }
}

// MARK: - Helper
private func sha256(_ input: String) -> String { // the same as in the original
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}
