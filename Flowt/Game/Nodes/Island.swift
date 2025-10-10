//
//  Island.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Island: SKSpriteNode {
    private let radius: CGFloat
    
    init(position: CGPoint, radius: CGFloat, picture: String) {
        self.radius = radius
        let texture = SKTexture(imageNamed: picture)
        super.init(texture: texture, color: .clear, size: CGSize(width: radius*2, height: radius*2))
        
        self.position = position
        self.zPosition = 1
        self.name = "Island"
        
        addBlurredShadow(texture: texture, radius: radius)
        addBorder()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Design
    private func addBlurredShadow(texture: SKTexture, radius: CGFloat) {
        let shadowNode = SKSpriteNode(texture: texture)
        shadowNode.size = CGSize(width: radius*2, height: radius*2)
        shadowNode.color = .black
        shadowNode.colorBlendFactor = 1.0
        shadowNode.alpha = 0.4
        
        let effectNode = SKEffectNode()
        effectNode.addChild(shadowNode)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 4])
        effectNode.shouldRasterize = true
        effectNode.zPosition = -1
        effectNode.position = CGPoint(x: 2, y: -2)
        
        addChild(effectNode)
    }
    
    private func addBorder() {
        let border = SKShapeNode(circleOfRadius: radius)
        border.strokeColor = UIColor.black.withAlphaComponent(0.2)
        border.lineWidth = 1
        border.zPosition = 1.5
        addChild(border)
    }
    
    // MARK: - Collision Helper
    func contains(point: CGPoint) -> Bool {
        let dist = hypot(point.x - self.position.x, point.y - self.position.y)
        return dist <= radius
    }
}
