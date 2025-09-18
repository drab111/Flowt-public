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
        
        // Utworzenie kształtu burzy
        let circlePath = CGMutablePath()
        circlePath.addArc(center: .zero, radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
        self.path = circlePath
        self.position = position
        self.fillColor = .darkGray
        self.alpha = 0.3
        self.zPosition = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // Sprawdza czy podany punkt jest w promieniu burzy
    func contains(point: CGPoint) -> Bool {
        let dist = hypot(point.x - self.position.x, point.y - self.position.y)
        return dist <= radius
    }
}
