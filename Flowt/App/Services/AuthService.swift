//
//  AuthService.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class AuthService {
    
    // MARK: - Email & Password
    func signUp(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(uid: result.user.uid, displayName: result.user.displayName, email: result.user.email)
    }
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(uid: result.user.uid, displayName: result.user.displayName, email: result.user.email)
    }
    
    
    // MARK: - Apple
    private var currentNonce: String?
    
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce // Zapisujemy nonce w zmiennej globalnej, by później porównać go z odpowiedzią
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAppleAuth(credential: ASAuthorizationAppleIDCredential) async throws -> AuthUser {
        guard let nonce = currentNonce, let tokenData = credential.identityToken, let idToken = String(data: tokenData, encoding: .utf8)
        else { throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID token"]) }

        let oAuthCredential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: credential.fullName)
        let result = try await Auth.auth().signIn(with: oAuthCredential)
        return AuthUser(uid: result.user.uid, displayName: result.user.displayName ?? credential.fullName?.givenName, email: result.user.email)
    }
    
    // MARK: - Other Methods
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.delete()
    }
    
    func getCurrentUser() -> User? { return Auth.auth().currentUser }
    
    func signOut() throws { try Auth.auth().signOut() }
    
    func sendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.sendEmailVerification()
    }
}

// MARK: - Helpers
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess { fatalError("Unable to generate nonce") }
        if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
        }
    }
    return result
}
