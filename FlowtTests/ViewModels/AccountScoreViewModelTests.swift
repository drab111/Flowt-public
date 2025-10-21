//
//  AccountScoreViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class AccountScoreViewModelTests: XCTestCase {
    // MARK: - fixtures
    var appState: AppState!
    var mockScoreService: MockScoreService!
    
    let defaultUserId = "testUser"
    
    // MARK: - lifecycle
    override func tearDown() {
        appState = nil
        mockScoreService = nil
        super.tearDown()
    }
    
    override func setUp() async throws {
        try await super.setUp()
        
        let mockAuth = MockAuthSession()
        mockAuth.currentUser = nil
        appState = AppState(authSession: mockAuth)
        appState.currentUser = AuthUser(uid: defaultUserId, displayName: "Test", email: "test@example.com")
        
        mockScoreService = MockScoreService()
    }
    
    // MARK: - tests
    func test_loadUserStats_whenBestScoreExists_setsBestScoreAndRank() async throws {
        // Arrange
        appState.currentUser = AuthUser(uid: "u1", displayName: "X", email: nil)
        
        let now = Date()
        // someone with higher score
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: "other", score: 300, createdAt: now.addingTimeInterval(-1000)))
        // user's best
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: "u1", score: 200, createdAt: now))
        
        let vm = AccountScoreViewModel(appState: appState, scoreService: mockScoreService)
        
        // Act
        await vm.loadUserStats()
        
        // Assert
        XCTAssertEqual(vm.bestScore, 200)
        XCTAssertEqual(vm.globalRank, 2)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
    
    func test_loadUserStats_whenNoBestScore_setsNilValues() async {
        // Arrange
        let vm = AccountScoreViewModel(appState: appState, scoreService: mockScoreService)
        
        // Act
        await vm.loadUserStats()
        
        // Assert
        XCTAssertNil(vm.bestScore)
        XCTAssertNil(vm.globalRank)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
    
    func test_loadUserStats_whenServiceThrows_setsErrorMessage() async {
        // Arrange
        appState.currentUser = AuthUser(uid: "u3", displayName: nil, email: nil)
        mockScoreService.shouldThrowOnFetchBestScore = true
        mockScoreService.thrownError = NSError(domain: "Test", code: 2, userInfo: [NSLocalizedDescriptionKey: "fetch failed"])
        
        let vm = AccountScoreViewModel(appState: appState, scoreService: mockScoreService)
        
        // Act
        await vm.loadUserStats()
        
        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("fetch failed") ?? false)
        XCTAssertFalse(vm.isLoading)
    }
    
    func test_deleteUserScores_onSuccess_clearsProfileAndSetsSignIn() async throws {
        // Arrange
        let uid = "deleteme"
        appState.currentUser = AuthUser(uid: uid, displayName: "nick", email: nil)
        appState.currentUserProfile = UserProfile(id: uid, nickname: "nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        appState.currentScreen = .mainMenu(.profile)
        
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: uid, score: 10, createdAt: Date()))
        XCTAssertFalse(mockScoreService.scores.isEmpty)
        
        let vm = AccountScoreViewModel(appState: appState, scoreService: mockScoreService)
        
        // Act
        await vm.deleteUserScores()
        
        // Assert
        XCTAssertNil(appState.currentUserProfile)
        XCTAssertEqual(appState.currentScreen, .signIn)
        XCTAssertEqual(mockScoreService.lastDeletedUserId, uid)
    }
    
    func test_deleteUserScores_whenServiceThrows_setsErrorMessageAndDoesNotChangeAppState() async {
        // Arrange
        let uid = "userErr"
        appState.currentUser = AuthUser(uid: uid, displayName: nil, email: nil)
        appState.currentUserProfile = UserProfile(id: uid, nickname: "nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        appState.currentScreen = .mainMenu(.profile)
        
        mockScoreService.shouldThrowOnDelete = true
        mockScoreService.thrownError = NSError(domain: "ScoreMock", code: 3, userInfo: [NSLocalizedDescriptionKey: "delete failed"])
        
        let vm = AccountScoreViewModel(appState: appState, scoreService: mockScoreService)
        
        // Act
        await vm.deleteUserScores()
        
        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("delete failed") ?? false)
        XCTAssertNotNil(appState.currentUserProfile)
        XCTAssertEqual(appState.currentScreen, .mainMenu(.profile))
    }
}
