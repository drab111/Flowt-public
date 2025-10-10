//
//  Ocean.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/09/2025.
//

import SpriteKit

class Ocean: SKNode {
    private let oceanSize: CGSize
    private let scrollSpeed: CGFloat = 10
    private var layers: [SKSpriteNode] = []
    
    init(size: CGSize) {
        self.oceanSize = size
        super.init()
        
        makeGradientTexture(size: size)
        brightnessPulseEffect()
        addWaveLayer(size: size) // Blinking waves
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Setup
    private func makeGradientTexture(size: CGSize) {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let gradientColors = [
                UIColor(red: 0.0, green: 0.08, blue: 0.20, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.17, blue: 0.32, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.08, blue: 0.20, alpha: 1.0).cgColor
            ]
            
            let locations: [CGFloat] = [0.0, 0.35, 0.65, 1.0]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: gradientColors as CFArray,
                locations: locations
            )!
            
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width/2, y: size.height),
                end: CGPoint(x: size.width/2, y: 0),
                options: []
            )
        }
        
        // Two gradient layers (stacked)
        for i in 0..<2 {
            let node = SKSpriteNode(texture: SKTexture(image: image))
            node.size = size
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: size.width / 2, y: CGFloat(i) * size.height)
            node.zPosition = -20
            addChild(node)
            layers.append(node)
        }
    }
    
    private func brightnessPulseEffect() {
        let fadeOut = SKAction.fadeAlpha(to: 0.6, duration: 20.0)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 20.0)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        run(.repeatForever(pulse))
    }
    
    private func addWaveLayer(size: CGSize) {
        let waveLayer = Wave(size: size, waveColor: UIColor.white.withAlphaComponent(0.02))
        addChild(waveLayer)
    }
    
    // MARK: - Update
    func update(_ dt: CGFloat) {
        for node in layers {
            node.position.y -= scrollSpeed * dt
            
            // Teleport once the entire gradient disappears
            if node.position.y <= -oceanSize.height { node.position.y += oceanSize.height * 2 }
        }
    }
}
