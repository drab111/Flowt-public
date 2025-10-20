//
//  MockAuthService.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/10/2025.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth 

@testable import Flowt

final class MockAuthService: AuthServiceProtocol {
    // konfiguracja do testów
    var shouldThrowOnSignUp = false
    var shouldThrowOnSignIn = false
    var shouldThrowOnDelete = false
    var shouldThrowOnSendVerification = false
    var shouldThrowOnPasswordReset = false
    var thrownError: Error = NSError(domain: "MockAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

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
        // jeśli mamy już currentAuthUser i email pasuje -> zwróć go; inaczej stwórz nowego
        if let u = currentAuthUser, u.email == email {
            return u
        } else {
            let user = AuthUser(uid: UUID().uuidString, displayName: nil, email: email)
            currentAuthUser = user
            return user
        }
    }

    // MARK: - Apple Sign-In (mockowane)
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        // generujemy deterministyczny nonce dla testów
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

    // NOTE: protokół zwraca Firebase `User?`. W mocku nie tworzymy instancji Firebase.User,
    // więc zwracamy `nil`. Jeśli potrzebujesz testować zachowanie zależne od tej konkretnej wartości,
    // rozważ zmianę protokołu na zwracanie AuthUser? (zalecane).
    func getCurrentUser() -> User? {
        return nil
    }

    func signOut() throws {
        currentAuthUser = nil
    }

    func sendVerificationEmail() async throws {
        if shouldThrowOnSendVerification { throw thrownError }
        // nic do zrobienia w mocku
    }

    func sendPasswordReset(email: String) async throws {
        if shouldThrowOnPasswordReset { throw thrownError }
        // nic do zrobienia w mocku
    }
}

// Helper: sha256 użyty jak w oryginalnym serwisie (kopiowane)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}
