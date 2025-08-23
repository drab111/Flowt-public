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
        case .signIn:
            SignInView(viewModel: AuthViewModel(appState: appState)) // appState to klasa więc przekazujemy oryginał
        case .verifyEmail:
            VerifyEmailView(viewModel: AuthViewModel(appState: appState))
        case .mainMenu:
            MainMenuView(viewModel: MainMenuViewModel(appState: appState))
        case .account:
            AccountView(viewModel: UserProfileViewModel(appState: appState))
        }
    }
}
