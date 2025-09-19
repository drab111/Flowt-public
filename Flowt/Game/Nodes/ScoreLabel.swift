//
//  ScoreLabel.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

class ScoreLabel: SKLabelNode {
    var score: Int = 0 {
        didSet {
            text = "Score: \(score)"
            animateScoreChange()
        }
    }
    
    // Prosta animacja: niewielkie powiększenie i powrót
    private func animateScoreChange() {
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let seq = SKAction.sequence([scaleUp, scaleDown])
        run(seq)
    }
    
    init(position: CGPoint) {
        super.init()
        fontColor = .white
        fontSize = 22
        fontName = "HelveticaNeue-Bold"
        self.position = position
        zPosition = 5
        horizontalAlignmentMode = .left
        verticalAlignmentMode = .top
        text = "Score: 0"
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
}
