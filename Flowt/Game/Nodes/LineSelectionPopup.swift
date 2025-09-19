//
//  LineSelectionPopup.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

class LineSelectionPopup: SKNode, Popup {
    var onLineSelected: ((Int) -> Void)?
    
    init(position: CGPoint, amountOfLines: Int, onLineSelected: ((Int) -> Void)? = nil) {
        super.init()
        self.onLineSelected = onLineSelected
        self.position = position
        self.zPosition = 6
        self.name = "LineSelectionPopup"
        
        setupBackground()
        setupTitle()
        setupButtons(amount: amountOfLines)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    private func setupBackground() {
        let bg = SKSpriteNode(color: .black, size: CGSize(width: 2000, height: 2000))
        bg.alpha = 0.5
        bg.zPosition = -1
        bg.name = "LineSelectionPopupBG"
        addChild(bg)
    }
    
    private func setupTitle() {
        let title = SKLabelNode(text: "Select Line:")
        title.fontColor = .white
        title.fontSize = 28
        title.fontName = "HelveticaNeue-Bold"
        title.position = CGPoint(x: 0, y: 70)
        addChild(title)
    }
    
    private func setupButtons(amount: Int) {
        let colors: [UIColor] = [
            .red.withAlphaComponent(0.7),
            .magenta.withAlphaComponent(0.7),
            .orange.withAlphaComponent(0.7),
            .green.withAlphaComponent(0.7),
            .blue.withAlphaComponent(0.7),
        ]
        
        // Wyliczamy pozycje startowe dla różnych ilości linii
        let initPos: CGFloat
        switch amount {
        case 2: initPos = -25
        case 3: initPos = 0
        case 4: initPos = 20
        default: initPos = 47.5
        }
        
        for i in 0..<amount {
            let dx = CGFloat(i - 1) * 50 - initPos
            let button = LineButton(index: i, color: colors[i], position: CGPoint(x: dx, y: 0))
            addChild(button)
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        let localPos = convert(location, from: parent!)
        let nodesAtPos = nodes(at: localPos)
        
        if let button = nodesAtPos.compactMap({ $0 as? LineButton }).first {
            onLineSelected?(button.index)
            removeFromParent()
        }
    }
}

// Pojedynczy przycisk wyboru linii
fileprivate class LineButton: SKShapeNode {
    let index: Int
    
    init(index: Int, color: UIColor, position: CGPoint) {
        self.index = index
        super.init()
        
        path = CGPath(ellipseIn: CGRect(x: -20, y: -20, width: 40, height: 40), transform: nil)
        fillColor = color
        strokeColor = .black
        lineWidth = 2
        self.position = position
        
        let texture = SKTexture(imageNamed: "SignTexture") // TODO: Zmień na customowy symbol
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 35, height: 35)
        imageNode.zPosition = 1
        addChild(imageNode)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
