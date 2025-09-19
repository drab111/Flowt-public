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
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.authVM = AuthViewModel(appState: appState)
        self.userProfileVM = UserProfileViewModel(appState: appState)
        self.gameVM = GameViewModel(appState: appState)
    }
}
