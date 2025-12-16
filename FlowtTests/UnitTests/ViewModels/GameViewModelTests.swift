//
//  GameViewModelTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/10/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class GameViewModelTests: XCTestCase {
    // MARK: - fixtures
    var originalGamesPlayed: Int?
    let gamesPlayedKey = "gamesPlayed"
    var mockAppReviewService: MockAppReviewService!
    
    // MARK: - lifecycle
    override func tearDown() {
        mockAppReviewService = nil
        
        // for the duration of testing, we reset UserDeaults and then restore them to their original state
        // restore UserDefaults
        if let orig = originalGamesPlayed {
            UserDefaults.standard.set(orig, forKey: gamesPlayedKey)
        } else {
            UserDefaults.standard.removeObject(forKey: gamesPlayedKey)
        }
        super.tearDown()
    }
    
    override func setUp() async throws {
        try await super.setUp()
        
        // preserve existing value
        if UserDefaults.standard.object(forKey: gamesPlayedKey) != nil {
            originalGamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedKey)
        } else {
            originalGamesPlayed = nil
        }
        // ensure deterministic start
        UserDefaults.standard.removeObject(forKey: gamesPlayedKey)
        
        mockAppReviewService = MockAppReviewService()
    }
    
    // MARK: - tests
    func test_startGame_setsGameScene_and_endGame_setsEndView_and_incrementsGamesPlayed() {
        // Arrange
        let vm = GameViewModel(appReviewService: mockAppReviewService)
        // ensure starting point
        UserDefaults.standard.set(0, forKey: gamesPlayedKey)
        
        // Act - start
        vm.startGame()
        XCTAssertEqual(vm.activePhase?.id, GameViewModel.GamePhase.gameScene.id)
        
        // Act - end
        vm.endGame()
        XCTAssertEqual(vm.activePhase?.id, GameViewModel.GamePhase.endView.id)
        
        // Assert - gamesPlayed incremented
        let gamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedKey)
        XCTAssertEqual(gamesPlayed, 1)
        XCTAssertFalse(mockAppReviewService.didRequestReview)
        XCTAssertEqual(mockAppReviewService.requestCount, 0)
        
        // back to menu
        vm.backToMenu()
        XCTAssertNil(vm.activePhase)
    }
    
    func test_endGame_incrementsToTen_triggersReviewThreshold() {
        // Arrange
        UserDefaults.standard.set(9, forKey: gamesPlayedKey)
        let vm = GameViewModel(appReviewService: mockAppReviewService)
        
        // Act
        vm.endGame()
        
        // Assert becomes 10
        let gamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedKey)
        XCTAssertEqual(gamesPlayed, 10)
        
        // Review requested exactly once at threshold
        XCTAssertTrue(mockAppReviewService.didRequestReview)
        XCTAssertEqual(mockAppReviewService.requestCount, 1)
    }
}
