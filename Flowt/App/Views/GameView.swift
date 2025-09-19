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
    
    var scene: SKScene {
        let scene = GameScene(gameVM: gameVM, cargoFactory: SimpleCargoFactory(), upgradeFactory: SimpleUpgradeFactory()) // TODO: Fabryka w trybie ciemnym
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }
    
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
        .fullScreenCover(isPresented: $gameVM.gameStarted) {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}

#Preview {
    let appState = AppState()
    GameView(gameVM: GameViewModel(appState: appState))
        .environmentObject(appState)
}
