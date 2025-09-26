//
//  MainMenuView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject var mainMenuVM: MainMenuViewModel
    
    let selectedTab: MainMenuTab
    let onTabChange: (MainMenuTab) -> Void
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Główna treść
                ZStack {
                    switch selectedTab {
                    case .account: AccountView(authVM: mainMenuVM.authVM, userProfileVM: mainMenuVM.userProfileVM, accountScoreVM: mainMenuVM.accountScoreVM)
                    case .tutorial: TutorialView(tutorialVM: mainMenuVM.tutorialVM, onTabChange: onTabChange)
                    case .game: GameView(gameVM: mainMenuVM.gameVM, scoreVM: mainMenuVM.scoreVM)
                    case .leaderboard: LeaderboardView(scoreVM: mainMenuVM.scoreVM)
                    case .settings: SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: selectedTab, animation: animation, onTabChange: onTabChange)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct CustomTabBar: View {
    let selectedTab: MainMenuTab
    var animation: Namespace.ID
    let onTabChange: (MainMenuTab) -> Void
    
    var body: some View {
        HStack {
            ForEach(MainMenuTab.allCases, id: \.self) { tab in
                VStack(spacing: 4) {
                    ZStack {
                        if selectedTab == tab {
                            LinearGradient(
                                colors: [Color(red: 0.8, green: 0.0, blue: 0.0),
                                         Color(red: 0.0, green: 0.2, blue: 0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Image(systemName: tab.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                            )
                            .matchedGeometryEffect(id: "ICON", in: animation)
                            .frame(width: 26, height: 26)
                        } else {
                            Image(systemName: tab.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Text(tab.title)
                        .font(.caption2)
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        onTabChange(tab) // zamiast bindingu, callback do RootView
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.25).opacity(0.95),
                    Color(red: 0.1, green: 0.3, blue: 0.55).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
    }
}

#Preview {
    let appState = AppState()
    let mainMenuVM = MainMenuViewModel(appState: appState)
    
    MainMenuView(
        mainMenuVM: mainMenuVM,
        selectedTab: .settings,
        onTabChange: { newTab in
            appState.currentScreen = .mainMenu(newTab)
        }
    )
    .environmentObject(appState)
}
