//
//  VerifyEmailViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class VerifyEmailViewModelTests: XCTestCase {
    // MARK: - fixtures
    var appState: AppState!
    var mockAuthService: MockAuthService!

    // MARK: - lifecycle
    override func tearDown() {
        appState = nil
        mockAuthService = nil
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()
        let mockAuth = MockAuthSession()
        mockAuth.currentUser = nil
        appState = AppState(authSession: mockAuth)
        appState.currentUser = AuthUser(uid: "u-verif", displayName: "Test", email: "test@example.com")
        appState.currentScreen = .verifyEmail
        
        mockAuthService = MockAuthService()
    }

    // MARK: - tests
    func test_resendVerificationEmail_onSuccess_setsInfoMessage() async {
        // Arrange
        let vm = VerifyEmailViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        await vm.resendVerificationEmail()
        
        // Assert
        XCTAssertEqual(vm.infoMessage, "A verification email has been sent.")
        XCTAssertNil(vm.errorMessage)
    }

    func test_resendVerificationEmail_whenServiceThrows_setsErrorMessage() async {
        // Arrange
        mockAuthService.shouldThrowOnSendVerification = true
        mockAuthService.thrownError = NSError(domain: "Test", code: 9, userInfo: [NSLocalizedDescriptionKey: "send failed"])
        let vm = VerifyEmailViewModel(appState: appState, authService: mockAuthService)

        // Act
        await vm.resendVerificationEmail()

        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("send failed") ?? false)
        XCTAssertNil(vm.infoMessage)
    }

    func test_resendVerificationEmail_clearsMessages_afterDelay() async {
        // Arrange
        let vm = VerifyEmailViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        await vm.resendVerificationEmail()
        XCTAssertEqual(vm.infoMessage, "A verification email has been sent.")
        try? await Task.sleep(nanoseconds: 5_200_000_000)

        // Assert
        XCTAssertNil(vm.infoMessage)
        XCTAssertNil(vm.errorMessage)
    }

    func test_signOut_clearsAppState_and_setsScreenToSignIn() {
        // Arrange
        let vm = VerifyEmailViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        vm.signOut()

        // Assert
        XCTAssertNil(appState.currentUser)
        XCTAssertNil(appState.currentUserProfile)
        XCTAssertEqual(appState.currentScreen, .signIn)
        XCTAssertNil(vm.errorMessage)
    }

    func test_signOut_whenServiceThrows_setsErrorMessage_and_doesNotClearEverything() {
        // Arrange
        mockAuthService.shouldThrowOnSignOut = true
        mockAuthService.thrownError = NSError(domain: "Test", code: 10, userInfo: [NSLocalizedDescriptionKey: "sign out failed"])
        let vm = VerifyEmailViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        vm.signOut()

        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("sign out failed") ?? false)
        XCTAssertEqual(appState.currentScreen, .verifyEmail)
    }
}
