//
//  MainMenuContainer.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class MainMenuContainer: ObservableObject {
    private let appState: AppState
    private let authService: AuthServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let scoreService: ScoreServiceProtocol
    private let appReviewService: AppReviewServiceProtocol
    
    let authVM: AuthViewModel
    let profileVM: ProfileViewModel
    let gameVM: GameViewModel
    let scoreVM: ScoreViewModel
    let accountScoreVM: AccountScoreViewModel
    let tutorialVM: TutorialViewModel
    let infoVM: InfoViewModel
    
    init(appState: AppState) {
        self.appState = appState
        
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1" {
            self.authService = MockAuthService()
            self.profileService = MockProfileService()
            self.scoreService = MockScoreService()
            self.appReviewService = MockAppReviewService()
        } else {
            self.authService = AuthService()
            self.profileService = ProfileService()
            self.scoreService = ScoreService()
            self.appReviewService = AppReviewService()
        }
        #else
        // production
        self.authService = AuthService()
        self.profileService = ProfileService()
        self.scoreService = ScoreService()
        self.appReviewService = AppReviewService()
        #endif
        
        self.authVM = AuthViewModel(appState: appState, authService: authService)
        self.profileVM = ProfileViewModel(appState: appState, profileService: profileService)
        self.gameVM = GameViewModel(appReviewService: appReviewService)
        self.scoreVM = ScoreViewModel(appState: appState, scoreService: scoreService, profileService: profileService)
        self.accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: scoreService)
        self.tutorialVM = TutorialViewModel()
        self.infoVM = InfoViewModel()
    }
}
