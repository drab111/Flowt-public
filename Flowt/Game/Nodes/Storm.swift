//
//  Storm.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Storm: SKShapeNode {
    private let radius: CGFloat
    
    init(position: CGPoint, radius: CGFloat) {
        self.radius = radius
        super.init()
        
        // Create storm shape
        let circlePath = CGMutablePath()
        circlePath.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
        self.path = circlePath
        self.position = position
        self.fillColor = UIColor.darkGray.withAlphaComponent(0.4)
        self.strokeColor = UIColor.black.withAlphaComponent(0.6)
        self.lineWidth = 2.0
        self.zPosition = 1
        
        // Animations
        startAnimating()
        addLightningEffect()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Animations
    private func startAnimating() {
        // Slow “breathing” animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 2.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 2.0)
        let breathing = SKAction.sequence([scaleUp, scaleDown])
        run(.repeatForever(breathing))
        
        // Alpha pulse
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 1.5)
        let fadeIn = SKAction.fadeAlpha(to: 0.35, duration: 1.5)
        let pulsing = SKAction.sequence([fadeOut, fadeIn])
        run(.repeatForever(pulsing))
        
        // Shaking outline
        let thicken = SKAction.customAction(withDuration: 1.0) { node, time in
            (node as? SKShapeNode)?.lineWidth = 2.0 + CGFloat(time) * 1.5
        }
        let thin = SKAction.customAction(withDuration: 1.0) { node, time in
            (node as? SKShapeNode)?.lineWidth = 3.5 - CGFloat(time) * 1.5
        }
        let wobble = SKAction.sequence([thicken, thin])
        run(.repeatForever(wobble))
    }
    
    private func addLightningEffect() {
        // Random lightning flashes
        let waitRandom = SKAction.wait(forDuration: 3.0, withRange: 4.0)
        let flash = SKAction.run { [weak self] in
            guard let self = self else { return }
            let flashNode = SKShapeNode(path: self.path!)
            flashNode.position = .zero
            flashNode.fillColor = UIColor.white.withAlphaComponent(0.7)
            flashNode.strokeColor = UIColor.yellow.withAlphaComponent(0.8)
            flashNode.lineWidth = 1.0
            flashNode.zPosition = 2
            self.addChild(flashNode)
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.15)
            let remove = SKAction.removeFromParent()
            flashNode.run(.sequence([fadeOut, remove]))
        }
        
        let sequence = SKAction.sequence([waitRandom, flash])
        run(.repeatForever(sequence))
    }
    
    // MARK: - Collision helper
    func contains(point: CGPoint) -> Bool { // Check whether a given point is within the storm’s radius
        let dist = hypot(point.x - self.position.x, point.y - self.position.y)
        return dist <= radius
    }
}
