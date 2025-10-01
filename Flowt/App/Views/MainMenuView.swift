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
                    case .profile: ProfileView(authVM: mainMenuVM.authVM, userProfileVM: mainMenuVM.profileVM, accountScoreVM: mainMenuVM.accountScoreVM)
                    case .tutorial: TutorialView(tutorialVM: mainMenuVM.tutorialVM, onTabChange: onTabChange)
                    case .game: GameView(gameVM: mainMenuVM.gameVM, scoreVM: mainMenuVM.scoreVM, onTabChange: onTabChange)
                    case .leaderboard: LeaderboardView(scoreVM: mainMenuVM.scoreVM)
                    case .info: InfoView(infoVM: mainMenuVM.infoVM)
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
    
    @State private var bubbleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Tło paska
            BlurView(style: .systemUltraThinMaterialDark)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.15, blue: 0.3).opacity(0.85),
                            Color(red: 0.1, green: 0.25, blue: 0.45).opacity(0.9)
                        ], startPoint: .top, endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: -4)
            
            // Ikony i highlight
            HStack {
                ForEach(MainMenuTab.allCases, id: \.self) { tab in
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == tab {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.4), Color.teal.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 28, height: 28)
                                    .blur(radius: 3)
                                    .frame(width: 35, height: 35)
                                    .blur(radius: 3)
                                    .matchedGeometryEffect(id: "HIGHLIGHT", in: animation)
                                
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.1, green: 0.5, blue: 0.8),
                                        Color(red: 0.3, green: 0.6, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: tab.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                )
                                .matchedGeometryEffect(id: "ICON", in: animation)
                                .frame(width: 28, height: 28)
                                .shadow(color: .white.opacity(0.4), radius: 8, x: 0, y: 0)
                            } else {
                                Image(systemName: tab.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white.opacity(0.65))
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
    }
}


// Reusable blur wrapper (UIKit bridge)
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


#Preview {
    let appState = AppState()
    let mainMenuVM = MainMenuViewModel(appState: appState)
    
    MainMenuView(
        mainMenuVM: mainMenuVM,
        selectedTab: .tutorial,
        onTabChange: { newTab in
            appState.currentScreen = .mainMenu(newTab)
        }
    )
    .environmentObject(appState)
}
