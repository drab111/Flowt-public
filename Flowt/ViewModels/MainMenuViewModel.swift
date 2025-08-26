//
//  MainMenuViewModel.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import SwiftUI

@MainActor
final class MainMenuViewModel: ObservableObject {
    private var appState: AppState
    
    init(appState: AppState) { self.appState = appState }
    
    func changeTab(_ tab: MainMenuTab) { appState.currentScreen = .mainMenu(tab) }
    
    func getAppState() -> AppState { return appState }
}
