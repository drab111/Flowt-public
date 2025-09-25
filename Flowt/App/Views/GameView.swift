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
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                Text("Flowt")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation { gameVM.startGame() }
                }) {
                    Text("Play")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal, 20)
                        .gradientBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(radius: 5)
                }
            }
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
        gameVM: GameViewModel(appState: appState),
        scoreVM: ScoreViewModel(appState: appState, scoreService: ScoreService(), profileService: UserProfileService())
    )
    .environmentObject(appState)
}
