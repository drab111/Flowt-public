//
//  FlowtApp.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/08/2025.
//

import SwiftUI
import FirebaseCore

@main
struct FlowtApp: App {
    init() { FirebaseApp.configure() }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        switch appState.currentScreen {
        case .loading:
            LoadingView()
        case .signIn:
            SignInView(viewModel: AuthViewModel(appState: appState)) // appState to klasa więc przekazujemy oryginał
        case .verifyEmail:
            VerifyEmailView(viewModel: VerifyEmailViewModel(appState: appState))
        case .mainMenu(let selectedTab):
            MainMenuView(authVM: AuthViewModel(appState: appState), mainMenuVM: MainMenuViewModel(appState: appState), selectedTab: selectedTab)
        }
    }
}
