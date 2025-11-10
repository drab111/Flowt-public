#if DEBUG

//
//  MockAuthSession.swift
//  Flowt
//
//  Created by Wiktor Drab on 07/11/2025.
//

import Foundation
import FirebaseAuth

final class MockAuthSession: AuthSession {
    var currentUser: User?
    var shouldThrowOnReload: Bool = false
    
    func reload(_ user: User) async throws {
        if shouldThrowOnReload { throw NSError(domain: "MockAuthSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Reload failed"]) }
    }
}

#endif
