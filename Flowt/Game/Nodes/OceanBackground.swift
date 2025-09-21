//
//  OceanBackground.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/09/2025.
//

import SpriteKit
import UIKit

class OceanBackground: SKNode {
    
    private let waveCount = 6
    private let waveColor = UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 0.35)
    private var waves: [SKShapeNode] = []
    
    init(size: CGSize) {
        super.init()
        
        self.zPosition = -10
        self.position = CGPoint(x: size.width/2, y: size.height/2)
        
        for i in 0..<waveCount {
            let wave = createRandomWave(size: size, index: i)
            addChild(wave)
            waves.append(wave)
            
            animateWave(wave, size: size, index: i)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Tworzenie fal
    private func createRandomWave(size: CGSize, index: Int) -> SKShapeNode {
        let width = size.width * 1.5
        let height = size.height
        let offsetY = CGFloat(index) * (height / CGFloat(waveCount)) - height/2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -width/2, y: offsetY))
        
        // Dodajemy kilka segmentów Béziera, każdy o losowej amplitudzie i fazie
        let segmentCount = 5
        let segmentWidth = width / CGFloat(segmentCount)
        var currentX: CGFloat = -width/2
        
        for _ in 0..<segmentCount {
            let cp1 = CGPoint(x: currentX + segmentWidth * 0.25,
                              y: offsetY + CGFloat.random(in: -30...30))
            let cp2 = CGPoint(x: currentX + segmentWidth * 0.75,
                              y: offsetY + CGFloat.random(in: -30...30))
            let end = CGPoint(x: currentX + segmentWidth,
                              y: offsetY + CGFloat.random(in: -20...20))
            path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
            currentX += segmentWidth
        }
        
        let waveNode = SKShapeNode(path: path.cgPath)
        waveNode.strokeColor = waveColor
        waveNode.lineWidth = 3
        waveNode.alpha = CGFloat.random(in: 0.3...0.6)
        
        return waveNode
    }
    
    // MARK: - Animacja fal
    private func animateWave(_ wave: SKShapeNode, size: CGSize, index: Int) {
        let moveDistance: CGFloat = size.width
        let duration = Double.random(in: 15.0...25.0)
        
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: duration)
        let resetPosition = SKAction.moveBy(x: -moveDistance, y: 0, duration: 0.0)
        let sequence = SKAction.sequence([moveRight, resetPosition])
        let forever = SKAction.repeatForever(sequence)
        
        wave.run(forever)
    }
}
