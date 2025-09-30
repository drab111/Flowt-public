//
//  GameView.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel
    @ObservedObject var scoreVM: ScoreViewModel
    let onTabChange: (MainMenuTab) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Flowt")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Navigate the seas, connect ports, master the flow.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 8)
            .padding(.horizontal)
            .padding(.top, 35)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: { withAnimation { gameVM.startGame() } }) {
                    Text("Play")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .gradientBackground()
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 8)
                }
                
                HStack(spacing: 12) {
                    Button(action: { onTabChange(.tutorial) }) {
                        Label("Tutorial", systemImage: "book.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Button(action: { onTabChange(.leaderboard) }) {
                        Label("Leaderboard", systemImage: "list.number")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 35)
        }
        .fullScreenCover(item: $gameVM.activePhase) { phase in
            switch phase {
            case .gameScene:
                SpriteView(scene: makeGameScene())
                    .ignoresSafeArea()
                    .statusBarHidden(true)
            case .endView:
                EndGameView(gameVM: gameVM, scoreVM: scoreVM)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .statusBarHidden(true)
            }
        }
    }
    
    private func makeGameScene() -> SKScene {
        let scene = GameScene(gameVM: gameVM, scoreVM: scoreVM, cargoFactory: LightCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }
}

#Preview {
    let appState = AppState()
    GameView(
        gameVM: GameViewModel(),
        scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: ProfileService()),
        onTabChange: { tab in
            appState.currentScreen = .mainMenu(tab)
        }
    )
    .environmentObject(appState)
}
