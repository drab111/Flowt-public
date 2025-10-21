//
//  AuthViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class AuthViewModelTests: XCTestCase {
    // MARK: - fixtures
    var appState: AppState!
    var mockAuthService: MockAuthService!
    
    let defaultUserId = "testUser"
    
    // MARK: - lifecycle
    override func tearDown() {
        appState = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    override func setUp() async throws {
        try await super.setUp()
        
        // mock auth session so AppState init does not hit Firebase
        let mockAuthSession = MockAuthSession()
        mockAuthSession.currentUser = nil
        appState = AppState(authSession: mockAuthSession)
        appState.currentUser = AuthUser(uid: defaultUserId, displayName: "T", email: "test@example.com")
        
        mockAuthService = MockAuthService()
    }
    
    // MARK: - tests
    func test_submit_whenNotRegistering_callsSignIn_and_setsMainMenu() async throws {
        // Arrange
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        vm.email = "me@example.com"
        vm.password = "validpass" // >=8 chars
        vm.isRegistering = false
        
        // Act
        await vm.submit()
        
        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNotNil(appState.currentUser)
        XCTAssertEqual(appState.currentScreen, .mainMenu(.profile))
    }
    
    func test_submit_whenRegistering_callsSignUp_and_sendsVerification_and_setsUser() async throws {
        // Arrange
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        vm.email = "new@example.com"
        vm.password = "newpassword"
        vm.isRegistering = true
        
        // Act
        await vm.submit()
        
        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNotNil(appState.currentUser)
        XCTAssertEqual(appState.currentUser?.email, "new@example.com")
        XCTAssertNotNil(mockAuthService.currentAuthUser)
    }
    
    func test_submit_whenSignInThrows_setsErrorMessage() async {
        // Arrange
        mockAuthService.shouldThrowOnSignIn = true
        mockAuthService.thrownError = NSError(domain: "AuthMock", code: 4, userInfo: [NSLocalizedDescriptionKey: "sign in failed"])
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        vm.email = "x@x.x"
        vm.password = "password"
        vm.isRegistering = false
        
        // Act
        await vm.submit()
        
        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("sign in failed") ?? false)
    }
    
    func test_signOut_clearsAppState_and_signsOutFromService() {
        // Arrange
        appState.currentUser = AuthUser(uid: "u1", displayName: "U", email: "u@example.com")
        appState.currentUserProfile = UserProfile(id: "u1", nickname: "nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        appState.currentScreen = .mainMenu(.profile)
        mockAuthService.currentAuthUser = AuthUser(uid: "u1", displayName: "U", email: "u@example.com")
        
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        vm.signOut()
        
        // Assert
        XCTAssertNil(appState.currentUser)
        XCTAssertNil(appState.currentUserProfile)
        XCTAssertEqual(appState.currentScreen, .signIn)
        XCTAssertNil(mockAuthService.currentAuthUser)
        XCTAssertNil(vm.errorMessage)
    }
    
    func test_deleteUserAccount_success_setsSignIn() async {
        // Arrange
        let uid = "toDelete"
        appState.currentUser = AuthUser(uid: uid, displayName: nil, email: "d@d.com")
        mockAuthService.currentAuthUser = AuthUser(uid: uid, displayName: nil, email: "d@d.com")
        mockAuthService.shouldThrowOnDelete = false
        
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        await vm.deleteUserAccount()
        
        // Assert
        XCTAssertNil(appState.currentUser)
        XCTAssertEqual(appState.currentScreen, .signIn)
        XCTAssertNil(vm.errorMessage)
    }
    
    func test_deleteUserAccount_whenServiceThrows_setsErrorMessageAndKeepsUser() async {
        // Arrange
        let uid = "errUser"
        appState.currentUser = AuthUser(uid: uid, displayName: nil, email: "e@e.com")
        mockAuthService.currentAuthUser = AuthUser(uid: uid, displayName: nil, email: "e@e.com")
        mockAuthService.shouldThrowOnDelete = true
        mockAuthService.thrownError = NSError(domain: "Auth", code: 5, userInfo: [NSLocalizedDescriptionKey: "delete failed"])
        
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        
        // Act
        await vm.deleteUserAccount()
        
        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("delete failed") ?? false)
        XCTAssertNotNil(appState.currentUser) // unchanged
    }
    
    func test_resetPassword_success_setsInfoMessage() async {
        // Arrange
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        let email = "reset@me.com"
        
        // Act
        await vm.resetPasswordWithEmail(email)
        
        // Assert
        XCTAssertEqual(vm.infoMessage, "Password reset link sent to \(email).")
        XCTAssertNil(vm.errorMessage)
    }
    
    func test_resetPassword_whenServiceThrows_setsErrorMessage() async {
        // Arrange
        mockAuthService.shouldThrowOnPasswordReset = true
        mockAuthService.thrownError = NSError(domain: "Auth", code: 6, userInfo: [NSLocalizedDescriptionKey: "reset failed"])
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        let email = "bad@x.x"
        
        // Act
        await vm.resetPasswordWithEmail(email)
        
        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("reset failed") ?? false)
        XCTAssertNil(vm.infoMessage)
    }
    
    func test_validation_properties_and_toggleMode() {
        // Arrange
        let vm = AuthViewModel(appState: appState, authService: mockAuthService)
        
        vm.email = "not-an-email"
        vm.password = "short"
        XCTAssertFalse(vm.isEmailValid)
        XCTAssertFalse(vm.isPasswordValid)
        XCTAssertFalse(vm.canSubmit)
        
        vm.email = "ok@example.com"
        vm.password = "longenough"
        XCTAssertTrue(vm.isEmailValid)
        XCTAssertTrue(vm.isPasswordValid)
        XCTAssertTrue(vm.canSubmit)
        
        // messages should clear on toggleMode
        vm.errorMessage = "err"
        vm.infoMessage = "info"
        vm.isRegistering = false
        
        vm.toggleMode()
        XCTAssertTrue(vm.isRegistering)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.infoMessage)
    }
}
