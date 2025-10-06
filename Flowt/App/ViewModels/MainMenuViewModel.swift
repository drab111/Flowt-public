//
//  MainMenuViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class MainMenuViewModel: ObservableObject {
    let authVM: AuthViewModel
    let profileVM: ProfileViewModel
    let gameVM: GameViewModel
    let scoreVM: ScoreViewModel
    let accountScoreVM: AccountScoreViewModel
    let tutorialVM: TutorialViewModel
    let infoVM: InfoViewModel
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.authVM = AuthViewModel(appState: appState, authService: AuthService())
        self.profileVM = ProfileViewModel(appState: appState, profileService: ProfileService())
        self.gameVM = GameViewModel()
        self.scoreVM = ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService())
        self.accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: ScoreService())
        self.tutorialVM = TutorialViewModel()
        self.infoVM = InfoViewModel()
    }
}
