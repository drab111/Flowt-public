//
//  MainMenuViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class MainMenuViewModel: ObservableObject {
    @Published var authVM: AuthViewModel
    @Published var userProfileVM: UserProfileViewModel
    @Published var gameVM: GameViewModel
    @Published var scoreVM: ScoreViewModel
    @Published var accountScoreVM: AccountScoreViewModel
    @Published var tutorialVM: TutorialViewModel
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.authVM = AuthViewModel(appState: appState, authService: AuthService())
        self.userProfileVM = UserProfileViewModel(appState: appState, profileService: UserProfileService())
        self.gameVM = GameViewModel()
        self.scoreVM = ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: UserProfileService())
        self.accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: ScoreService())
        self.tutorialVM = TutorialViewModel()
    }
}
