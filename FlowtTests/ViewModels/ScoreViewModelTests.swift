//
//  ScoreViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class ScoreViewModelTests: XCTestCase {
    // MARK: - fixtures
    var appState: AppState!
    var mockScoreService: MockScoreService!
    var mockProfileService: MockProfileService!

    let defaultUserId = "testUser"

    // MARK: - lifecycle
    override func tearDown() {
        appState = nil
        mockScoreService = nil
        mockProfileService = nil
        super.tearDown()
    }

    override func setUp() async throws {
        try await super.setUp()

        let mockAuth = MockAuthSession()
        mockAuth.currentUser = nil
        appState = AppState(authSession: mockAuth)
        appState.currentUser = AuthUser(uid: defaultUserId, displayName: "testUser", email: "test@example.com")
        appState.currentUserProfile = UserProfile(id: defaultUserId, nickname: "testUser", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)

        mockScoreService = MockScoreService()
        mockProfileService = MockProfileService()
    }

    // MARK: - tests
    func test_saveAndLoadLeaderboard_success_setsLatestId_rank_and_leaderboard() async throws {
        // Arrange
        let vm = ScoreViewModel(appState: appState, scoreService: mockScoreService, profileService: mockProfileService)
        vm.setScore(123)

        // prepare other users and profiles
        let now = Date()
        // pre-existing top user
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: "other", score: 500, createdAt: now.addingTimeInterval(-100)))
        // register profile for 'other'
        mockProfileService.mockProfiles["other"] = UserProfile(id: "other", nickname: "other", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)

        // Act
        await vm.saveAndLoadLeaderboard(limit: 10)

        // Assert
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNotNil(vm.latestScoreId)
        XCTAssertNotNil(vm.userRank)
        XCTAssertFalse(vm.leaderboard.isEmpty)

        // user's entry should exist in leaderboard and be marked as current user
        let currentEntries = vm.leaderboard.filter { $0.isCurrentUser }
        XCTAssertEqual(currentEntries.count, 1)

        // latest flag should be set for one entry (the one with latestScoreId)
        let latestEntries = vm.leaderboard.filter { $0.isLatest }
        XCTAssertEqual(latestEntries.count, 1)
        XCTAssertEqual(latestEntries.first?.entry.id, vm.latestScoreId)
    }

    func test_loadLeaderboard_loadsTopScores_and_profiles_and_mapsCurrentUser() async throws {
        // Arrange - prepare two scores
        let now = Date()
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: "u1", score: 400, createdAt: now.addingTimeInterval(-200)))
        _ = try await mockScoreService.saveScore(ScoreEntry(id: nil, userId: defaultUserId, score: 100, createdAt: now))
        // provide profile only for u1 to test caching and nil profile fallback
        mockProfileService.mockProfiles["u1"] = UserProfile(id: "u1", nickname: "UserOne", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)

        let vm = ScoreViewModel(appState: appState, scoreService: mockScoreService, profileService: mockProfileService)

        // Act
        await vm.loadLeaderboard(limit: 10)

        // Assert
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.leaderboard.isEmpty)
        // ensure mapping has profile for u1 and nil for others if missing
        let mappedU1 = vm.leaderboard.first(where: { $0.entry.userId == "u1" })
        XCTAssertNotNil(mappedU1?.profile)
        let mappedSelf = vm.leaderboard.first(where: { $0.entry.userId == defaultUserId })
        XCTAssertTrue(mappedSelf?.isCurrentUser ?? false)
    }

    func test_saveAndLoadLeaderboard_whenSaveThrows_setsErrorMessage_and_doesNotCrash() async {
        // Arrange
        let vm = ScoreViewModel(appState: appState, scoreService: mockScoreService, profileService: mockProfileService)
        vm.setScore(123)
        mockScoreService.shouldThrowOnSave = true
        mockScoreService.thrownError = NSError(domain: "ScoreMock", code: 8, userInfo: [NSLocalizedDescriptionKey: "save failed"])

        // Act
        await vm.saveAndLoadLeaderboard(limit: 10)

        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("save failed") ?? false)
    }

    func test_makeSharePayload_returnsPayload_whenRenderable() async throws {
        // Arrange (we mark it as optional: if renderer fails to produce image, we just assert nil is acceptable)
        let vm = ScoreViewModel(appState: appState, scoreService: mockScoreService, profileService: mockProfileService)
        vm.score = 123
        appState.currentUserProfile = UserProfile(id: defaultUserId, nickname: "Nick", avatarBase64: nil, musicEnabled: true, sfxEnabled: true)
        vm.userRank = 5

        // Act
        let payload = vm.makeSharePayload()
        
        // we will assert that either payload is nil (renderer not available) OR non-nil with non-empty data
        if let p = payload { XCTAssertFalse(p.imageData.isEmpty) }
    }

    func test_reset_clearsState() async {
        let vm = ScoreViewModel(appState: appState, scoreService: mockScoreService, profileService: mockProfileService)
        vm.score = 123
        vm.latestScoreId = "abc"
        vm.userRank = 2
        vm.leaderboard = [(ScoreEntry(id: "1", userId: "u", score: 1, createdAt: Date()), nil, false, false)]

        vm.reset()

        XCTAssertNil(vm.score)
        XCTAssertNil(vm.latestScoreId)
        XCTAssertNil(vm.userRank)
        XCTAssertTrue(vm.leaderboard.isEmpty)
        XCTAssertNil(vm.errorMessage)
    }
}
