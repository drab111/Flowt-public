//
//  MainMenuView.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/08/2025.
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var container: MainMenuContainer
    let selectedTab: MainMenuTab
    let onTabChange: (MainMenuTab) -> Void
    @Namespace private var animation
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content
                ZStack {
                    switch selectedTab {
                    case .profile: ProfileView(authVM: container.authVM, userProfileVM: container.profileVM, accountScoreVM: container.accountScoreVM)
                    case .tutorial: TutorialView(tutorialVM: container.tutorialVM, onTabChange: onTabChange)
                    case .game: GameView(gameVM: container.gameVM, scoreVM: container.scoreVM, accountScoreVM: container.accountScoreVM)
                    case .leaderboard: LeaderboardView(scoreVM: container.scoreVM)
                    case .info: InfoView(infoVM: container.infoVM)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: selectedTab, animation: animation, onTabChange: onTabChange)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Subviews
struct CustomTabBar: View {
    let selectedTab: MainMenuTab
    var animation: Namespace.ID
    let onTabChange: (MainMenuTab) -> Void
    
    var body: some View {
        ZStack {
            // Background of the progress bar
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.06, blue: 0.15).opacity(0.95),
                            Color(red: 0.12, green: 0.22, blue: 0.35).opacity(0.92)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: -4)
            
            // Icons and highlights
            HStack {
                ForEach(MainMenuTab.allCases, id: \.self) { tab in
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == tab {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.65, blue: 0.8).opacity(0.5),
                                                Color(red: 0.0, green: 0.55, blue: 0.55).opacity(0.4)
                                            ], startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .blur(radius: 6)
                                    .matchedGeometryEffect(id: "HIGHLIGHT", in: animation)
                                
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.65, blue: 0.8),
                                        Color(red: 0.95, green: 0.75, blue: 0.2)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: tab.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                )
                                .matchedGeometryEffect(id: "ICON", in: animation)
                                .frame(width: 28, height: 28)
                                .shadow(color: .white.opacity(0.5), radius: 8)
                            } else {
                                Image(systemName: tab.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            onTabChange(tab)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("mainMenu_tabBar")
    }
}

#if DEBUG
#Preview {
    let appState = AppState()
    let container = MainMenuContainer(appState: appState)
    
    MainMenuView(
        container: container,
        selectedTab: .tutorial,
        onTabChange: { newTab in
            appState.currentScreen = .mainMenu(newTab)
        }
    )
    .environmentObject(appState)
}
#endif
