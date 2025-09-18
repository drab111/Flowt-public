//
//  GameScene.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SpriteKit

class GameScene: SKScene {
    private let gameVM: GameViewModel
    
    init(gameVM: GameViewModel) {
        self.gameVM = gameVM
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    override func didMove(to view: SKView) {
        backgroundColor = .blue
        // możesz teraz korzystać z gameVM do tworzenia obiektów w scenie
    }
    
    
    
    
    
    
    
    
    
    
    
    // TODO: - do zmodyfikowania
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameVM.gameStarted = false
    }
}
