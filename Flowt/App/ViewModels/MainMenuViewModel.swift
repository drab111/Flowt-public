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
    @Published var profileVM: ProfileViewModel
    @Published var gameVM: GameViewModel
    @Published var scoreVM: ScoreViewModel
    @Published var accountScoreVM: AccountScoreViewModel
    @Published var tutorialVM: TutorialViewModel
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.authVM = AuthViewModel(appState: appState, authService: AuthService())
        self.profileVM = ProfileViewModel(appState: appState, profileService: ProfileService())
        self.gameVM = GameViewModel()
        self.scoreVM = ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService())
        self.accountScoreVM = AccountScoreViewModel(appState: appState, scoreService: ScoreService())
        self.tutorialVM = TutorialViewModel()
    }
}
