//
//  ProfileViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class ProfileViewModelTests: XCTestCase {
    // MARK: - fixtures
    var appState: AppState!
    var mockProfileService: MockProfileService!
    
    // MARK: - lifecycle
    override func tearDown() {
        appState = nil
        mockProfileService = nil
        super.tearDown()
    }
    
    override func setUp() async throws {
        try await super.setUp()
        
        let mockAuth = MockAuthSession()
        mockAuth.currentUser = nil
        appState = AppState(authSession: mockAuth)
        appState.currentUser = AuthUser(uid: "userTest", displayName: "T", email: "test@example.com")
        
        mockProfileService = MockProfileService()
    }
    
    // MARK: - tests
    func test_loadUserProfile_whenProfileExists_populatesAppStateAndFields() async throws {
        // Arrange
        let uid = appState.currentUser!.uid
        let profile = UserProfile(id: uid, nickname: "Nick", avatarBase64: nil, musicEnabled: false, sfxEnabled: true)
        mockProfileService.mockProfiles[uid] = profile
        
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        
        // Act
        await vm.loadUserProfile()
        
        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(appState.currentUserProfile?.id, uid)
        XCTAssertEqual(vm.currentNickname, "Nick")
        XCTAssertNil(vm.avatarData)
    }
    
    func test_loadUserProfile_whenNoProfile_createsAndSavesProfile() async throws {
        // Arrange - no profile present
        let uid = appState.currentUser!.uid
        mockProfileService.mockProfiles.removeAll()
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        
        // Act
        await vm.loadUserProfile()
        
        // Assert - a profile should be saved and applied to appState
        XCTAssertNotNil(mockProfileService.lastSavedProfile)
        XCTAssertEqual(mockProfileService.lastSavedProfile?.id, uid)
        XCTAssertEqual(appState.currentUserProfile?.id, uid)
        XCTAssertFalse(vm.isLoading)
    }
    
    func test_updateProfile_withNicknameOnly_savesAndSetsSavedState_then_cancelToAvoidSleep() async throws {
        // Arrange
        let uid = appState.currentUser!.uid
        appState.currentUserProfile = UserProfile(id: uid, nickname: "Old", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        
        // Act (running in Task so we can cancel before 5s sleep finishes)
        let task = Task { await vm.updateProfile(nickname: "NewNick", imageData: nil) }
        
        // waiting until saveState becomes .saved (short timeout)
        let start = Date()
        while Date().timeIntervalSince(start) < 1.0 {
            if vm.saveState == .saved { break }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
        
        // Assert intermediate saved state
        XCTAssertEqual(vm.saveState, .saved)
        XCTAssertEqual(appState.currentUserProfile?.nickname, "NewNick")
        XCTAssertEqual(vm.currentNickname, "NewNick")
        XCTAssertEqual(mockProfileService.lastSavedProfile?.nickname, "NewNick")
        
        // cancel to avoid the 5s sleep inside updateProfile resetting to .idle
        task.cancel()
        // await completion so resources freed
        _ = await task.result
    }
    
    func test_updateProfile_whenAvatarRejected_setsRejectedState_then_cancel() async throws {
        // Arrange
        mockProfileService.avatarValidationHandler = { _, _ in return false }
        let uid = appState.currentUser!.uid
        appState.currentUserProfile = UserProfile(id: uid, nickname: "Old", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        
        // create small dummy image data
        let image = UIImage(systemName: "person")!
        let imageData = image.pngData()
        XCTAssertNotNil(imageData)
        
        // Act
        let task = Task { await vm.updateProfile(nickname: "Whatever", imageData: imageData) }
        
        // Wait until .rejected is set
        let start = Date()
        while Date().timeIntervalSince(start) < 1.0 {
            if vm.saveState == .rejected { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        
        // Assert
        XCTAssertEqual(vm.saveState, .rejected)
        XCTAssertNil(mockProfileService.lastSavedProfile) // no profile saved
        
        // cancel to avoid the 5s sleep inside updateProfile
        task.cancel()
        _ = await task.result
    }
    
    func test_deleteProfile_callsService_and_clearsAppState() async throws {
        // Arrange
        let uid = appState.currentUser!.uid
        mockProfileService.mockProfiles[uid] = UserProfile(id: uid, nickname: "nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        appState.currentScreen = .mainMenu(.profile)
        
        // Act
        await vm.deleteProfile()
        
        // Assert
        XCTAssertEqual(mockProfileService.lastDeletedUID, uid)
        XCTAssertNil(appState.currentUserProfile)
        XCTAssertEqual(appState.currentScreen, .signIn)
    }
    
    func test_deleteProfile_whenServiceThrows_keepsAppState() async throws {
        // Arrange
        let uid = appState.currentUser!.uid
        mockProfileService.mockProfiles[uid] = UserProfile(id: uid, nickname: "nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        mockProfileService.shouldThrowOnDelete = true
        mockProfileService.thrownError = NSError(domain: "ProfileMock", code: 7, userInfo: [NSLocalizedDescriptionKey: "delete failed"])
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        appState.currentScreen = .mainMenu(.profile)
        
        // Act
        await vm.deleteProfile()
        
        // Assert
        XCTAssertNil(mockProfileService.lastDeletedUID)
        XCTAssertFalse(mockProfileService.mockProfiles.isEmpty)
        XCTAssertEqual(appState.currentScreen, .mainMenu(.profile))
        XCTAssertTrue(vm.errorMessage?.contains("delete failed") ?? false)
    }
    
    func test_updatePreferences_savesNewPreferences() async throws {
        // Arrange
        let uid = appState.currentUser!.uid
        let profile = UserProfile(id: uid, nickname: "abc", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        appState.currentUserProfile = profile
        let vm = ProfileViewModel(appState: appState, profileService: mockProfileService)
        
        // Act
        await vm.updatePreferences(musicEnabled: false, sfxEnabled: false)
        
        // Assert
        XCTAssertEqual(mockProfileService.lastSavedProfile?.musicEnabled, false)
        XCTAssertEqual(mockProfileService.lastSavedProfile?.sfxEnabled, false)
        XCTAssertEqual(appState.currentUserProfile?.musicEnabled, false)
        XCTAssertEqual(appState.currentUserProfile?.sfxEnabled, false)
    }
}
