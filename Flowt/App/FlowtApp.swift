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
    @StateObject private var appState: AppState
    
    init() {
        FirebaseApp.configure()
        let appState = AppState()
        // Assign object directly to the wrapper instead of the variable
        _appState = StateObject(wrappedValue: appState)
        GameCenterService.shared.authenticate()
        _ = AudioService.shared // Trigger initialization to set up the observer
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @ObservedObject var appState: AppState
    @StateObject private var container: MainMenuContainer
    
    init(appState: AppState) {
        self.appState = appState
        _container = StateObject(wrappedValue: MainMenuContainer(appState: appState))
    }
    
    var body: some View {
        switch appState.currentScreen {
        case .loading:
            LoadingView()
        case .signIn:
            SignInView(authVM: AuthViewModel(appState: appState, authService: AuthService())) // appState is a class, so we pass the original instance
        case .verifyEmail:
            VerifyEmailView(verifyVM: VerifyEmailViewModel(appState: appState, authService: AuthService()))
        case .mainMenu(let selectedTab):
            MainMenuView(
                container: container,
                selectedTab: selectedTab,
                onTabChange: { newTab in
                    appState.currentScreen = .mainMenu(newTab)
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            )
            .id(appState.currentUser?.uid) // When the user (uid) changes, create a new instance to reset previous state
        }
    }
}
