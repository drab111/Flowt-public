//
//  AuthSession.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/10/2025.
//

import FirebaseAuth

protocol AuthSession {
    var currentUser: User? { get }
    func reload(_ user: User) async throws
}

struct FirebaseAuthSession: AuthSession {
    var currentUser: User? { Auth.auth().currentUser }
    func reload(_ user: User) async throws { try await user.reload() }
}
