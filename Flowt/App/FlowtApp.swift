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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var audioVM: AudioViewModel
    
    init() {
        FirebaseApp.configure()
        let appState = AppState()
        // pzypisujemy obiekty do samego wrappera a nie zmiennej
        _appState = StateObject(wrappedValue: appState)
        _audioVM = StateObject(wrappedValue: AudioViewModel(service: AudioService.shared))
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
    @StateObject private var mainMenuVM: MainMenuViewModel
    
    init(appState: AppState) {
        self.appState = appState
        _mainMenuVM = StateObject(wrappedValue: MainMenuViewModel(appState: appState))
    }
    
    var body: some View {
        switch appState.currentScreen {
        case .loading:
            LoadingView()
        case .signIn:
            SignInView(viewModel: AuthViewModel(appState: appState, authService: AuthService())) // appState to klasa więc przekazujemy oryginał
        case .verifyEmail:
            VerifyEmailView(viewModel: VerifyEmailViewModel(appState: appState, authService: AuthService()))
        case .mainMenu(let selectedTab):
            MainMenuView(
                mainMenuVM: mainMenuVM,
                selectedTab: selectedTab,
                onTabChange: { newTab in
                    appState.currentScreen = .mainMenu(newTab)
                }
            )
            .id(appState.currentUser?.uid) // jak zmieni się user (czyli jego uid) to tworzymy nową instancję aby nie pamiętała wcześniejszych danych
        }
    }
}
