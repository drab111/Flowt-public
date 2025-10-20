//
//  AppStateTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/10/2025.
//

import XCTest
@testable import Flowt

final class AppStateTests: XCTestCase {
    
    @MainActor
    func test_checkUserSession_setsSignInWhenNoUser() async {
        let mock = MockAuthSession()
        mock.currentUser = nil
        let appState = AppState(authSession: mock)
        
        XCTAssertEqual(appState.currentScreen, .signIn)
    }
}
