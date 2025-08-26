//
//  MainMenuView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject var authVM: AuthViewModel
    @StateObject var mainMenuVM: MainMenuViewModel
    var selectedTab: MainMenuTab
    
    var body: some View {
        TabView(selection: Binding( // musimy zrobic sami Binding bo selectedTab pochodzace z nadwidoku nie jest typu @State
            get: { selectedTab },
            set: { newTab in mainMenuVM.changeTab(newTab) }
        )) {
            
            AccountView( authVM: AuthViewModel(appState: mainMenuVM.getAppState()), userProfileVM: UserProfileViewModel(appState: mainMenuVM.getAppState()))
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(MainMenuTab.account)
            
            TutorialView()
                .tabItem {
                    Label("Tutorial", systemImage: "book.closed")
                }
                .tag(MainMenuTab.tutorial)
            
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }
                .tag(MainMenuTab.game)
            
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "trophy")
                }
                .tag(MainMenuTab.ranking)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(MainMenuTab.settings)
        }
        .accentColor(.blue) // kolor ikonek aktywnej zakładki
        .animation(.easeInOut, value: selectedTab) // płynne przejście
    }
}

#Preview {
    let appState = AppState()
    let mainMenuVM = MainMenuViewModel(appState: appState)
    let authVM = AuthViewModel(appState: appState)
    
    MainMenuView(authVM: authVM, mainMenuVM: mainMenuVM, selectedTab: .account)
        .environmentObject(appState)
}
