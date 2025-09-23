//
//  Wave.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/09/2025.
//

import SpriteKit

class Wave: SKNode {
    private let waveCount = 10
    private let waveAmplitude: CGFloat = 10
    private let wavePeriod: CGFloat = 100
    private let lineWidth: CGFloat = 2
    
    private var waveLines: [SKShapeNode] = []
    private var container: SKNode?
    private let waveColor: UIColor
    private let sizeRef: CGSize
    
    init(size: CGSize, waveColor: UIColor) {
        self.waveColor = waveColor
        self.sizeRef = size
        super.init()
        
        makeContainer()
        makeWaves()
        scheduleHighlights()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Setup
    
    private func makeContainer() {
        let container = SKNode()
        container.position = CGPoint(x: sizeRef.width / 2, y: sizeRef.height / 2)
        container.zPosition = -0.5
        container.zRotation = -CGFloat.pi / 8
        addChild(container)
        self.container = container
    }
    
    private func makeWaves() {
        let diagonal = CGFloat(hypot(Double(sizeRef.width), Double(sizeRef.height))) // fale muszą być dłuższe niż ekran
        
        for i in 0..<waveCount {
            let offsetY = CGFloat(i) * (diagonal / CGFloat(waveCount + 1))
            let path = makeWavePath(diagonal: diagonal, offsetY: offsetY)
            
            let waveNode = SKShapeNode(path: path.cgPath)
            waveNode.strokeColor = waveColor
            waveNode.lineWidth = lineWidth
            waveNode.alpha = 1.0
            container?.addChild(waveNode)
            
            waveLines.append(waveNode)
        }
    }
    
    private func makeWavePath(diagonal: CGFloat, offsetY: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -diagonal/2, y: offsetY - diagonal/2))
        
        var x: CGFloat = -diagonal/2
        while x <= diagonal/2 {
            let relativeX = x + diagonal/2
            let yOffset = sin((relativeX / wavePeriod) * 2 * .pi) * waveAmplitude
            let y = offsetY - diagonal/2 + yOffset
            path.addLine(to: CGPoint(x: x, y: y))
            x += 5
        }
        return path
    }
    
    // MARK: - Highlight
    
    private func scheduleHighlights() {
        let waitRandom = SKAction.wait(forDuration: 2.0, withRange: 4.0)
        let highlightAction = SKAction.run { [weak self] in
            self?.highlightRandomWave()
        }
        let sequence = SKAction.sequence([waitRandom, highlightAction])
        run(.repeatForever(sequence))
    }
    
    private func highlightRandomWave() {
        guard !waveLines.isEmpty else { return }
        let randomIndex = Int.random(in: 0..<waveLines.count)
        let wave = waveLines[randomIndex]
        
        let fadeUp = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
            let fraction = elapsedTime / 1.0
            let targetAlpha: CGFloat = 1.0 + 0.8 * fraction
            (node as? SKShapeNode)?.alpha = targetAlpha
        }
        
        let fadeDown = SKAction.customAction(withDuration: 1.0) { node, elapsedTime in
            let fraction = elapsedTime / 1.0
            let targetAlpha: CGFloat = 1.3 - 0.8 * fraction
            (node as? SKShapeNode)?.alpha = targetAlpha
        }
        
        let seq = SKAction.sequence([fadeUp, fadeDown])
        wave.run(seq)
    }
}
