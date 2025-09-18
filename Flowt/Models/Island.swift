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
        
        // Kolor wypełnienia
        //self.colorBlendFactor = 1.0
        self.position = position
        self.zPosition = 1
        self.name = "Island"
        
        // Otoczka aby było wiadomo gdzie oddziaływanie ma wyspa
        let border = SKShapeNode(circleOfRadius: radius)
        border.strokeColor = UIColor(red: 0.0, green: 0.4, blue: 0.7, alpha: 9.0)
        border.lineWidth = 0.2
        border.zPosition = 2
        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // Sprawdza czy podany punkt jest w promieniu wyspy
    func contains(point: CGPoint) -> Bool {
        let dist = hypot(point.x - self.position.x, point.y - self.position.y)
        return dist <= radius
    }
}
