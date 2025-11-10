//
//  RootView.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/10/2025.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var appState: AppState
    @StateObject private var container: MainMenuContainer
    
    init(appState: AppState) {
        self.appState = appState
        _container = StateObject(wrappedValue: MainMenuContainer(appState: appState))
    }
    
    private var injectedAuthService: AuthServiceProtocol {
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1" {
            return MockAuthService()
        } else { return AuthService() }
        #else
        return AuthService()
        #endif
    }
    
    var body: some View {
        switch appState.currentScreen {
        case .loading:
            LoadingView()
        case .signIn:
            SignInView(authVM: AuthViewModel(appState: appState, authService: injectedAuthService)) // appState is a class, so we pass the original instance
        case .verifyEmail:
            VerifyEmailView(verifyVM: VerifyEmailViewModel(appState: appState, authService: injectedAuthService))
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
