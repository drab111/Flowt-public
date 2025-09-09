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
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.authVM = AuthViewModel(appState: appState)
        self.userProfileVM = UserProfileViewModel(appState: appState)
    }
    
    func getAppState() -> AppState { return appState }
}
