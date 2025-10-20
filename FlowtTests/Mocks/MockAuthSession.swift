//
//  MockAuthSession.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/10/2025.
//

import Foundation
import FirebaseAuth
@testable import Flowt

final class MockAuthSession: AuthSession {
    var currentUser: User?
    var shouldThrowOnReload = false
    
    func reload(_ user: User) async throws {
        // Error:
        if shouldThrowOnReload { throw NSError(domain: "MockAuthSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Reload failed"]) }
        // Success: -
    }
}
