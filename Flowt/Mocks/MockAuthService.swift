#if DEBUG

//
//  MockAuthService.swift
//  Flowt
//
//  Created by Wiktor Drab on 07/11/2025.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth

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
    
    init() {
        let env = ProcessInfo.processInfo.environment
        if env["MOCK_AUTH_SHOULD_THROW_SIGNIN"] == "1" { shouldThrowOnSignIn = true }
        if env["MOCK_AUTH_SHOULD_THROW_SIGNUP"] == "1" { shouldThrowOnSignUp = true }
        if env["MOCK_AUTH_SHOULD_THROW_SIGNOUT"] == "1" { shouldThrowOnSignOut = true }
        if env["MOCK_AUTH_SHOULD_THROW_DELETE"] == "1" { shouldThrowOnDelete = true }
        if env["MOCK_AUTH_SHOULD_THROW_SEND"] == "1" { shouldThrowOnSendVerification = true }
        if env["MOCK_AUTH_SHOULD_THROW_PASSWORD_RESET"] == "1" { shouldThrowOnPasswordReset = true }
        
        guard env["SKIP_LOGIN"] != nil else { return }
        currentAuthUser = AuthUser(uid: "ui-test-uid", displayName: "UI Tester", email: "ui-test@example.com")
    }

    // MARK: - Email & Password
    func signUp(email: String, password: String) async throws -> AuthUser {
        if shouldThrowOnSignUp { throw thrownError }
        let user = AuthUser(uid: UUID().uuidString, displayName: nil, email: email)
        currentAuthUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        if shouldThrowOnSignIn { throw thrownError }
        if let user = currentAuthUser, user.email == email { return user }
        let user = AuthUser(uid: UUID().uuidString, displayName: nil, email: email)
        currentAuthUser = user
        return user
    }

    // MARK: - Apple Sign-In
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = "mocked-nonce-\(UUID().uuidString.prefix(6))"
        lastGeneratedNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleAuth(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser {
        // in the mock we ignore tokens and create a user based on credential.fullName / email (if present)
        if shouldThrowOnSignIn { throw thrownError }
        let displayName = credential.fullName?.givenName
        // in tests, credential.email is often nil — use a placeholder
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

#endif
