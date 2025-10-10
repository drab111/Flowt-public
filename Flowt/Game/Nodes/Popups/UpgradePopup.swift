//
//  UpgradePopup.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

// Provides info about which button the user selected so the app can react accordingly
class UpgradePopup: SKNode, Popup {
    var onOptionSelected: ((UpgradeOption) -> Void)?
    
    init(size: CGSize, onOptionSelected: ((UpgradeOption) -> Void)? = nil) {
        super.init()
        self.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.zPosition = 6
        self.name = "UpgradePopup"
        self.onOptionSelected = onOptionSelected
        
        setupBackground()
        setupTitle()
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Setup UI
    private func setupBackground() {
        let bg = SKSpriteNode(color: .black, size: UIScreen.main.bounds.size)
        bg.alpha = 0.6
        bg.zPosition = -1
        bg.name = "UpgradePopupBG"
        addChild(bg)
    }
    
    private func setupTitle() {
        let title = SKLabelNode(text: "Select Upgrade:")
        title.fontColor = .white
        title.fontSize = 28
        title.fontName = "HelveticaNeue-Bold"
        title.position = CGPoint(x: 0, y: 70)
        addChild(title)
    }
    
    private func setupButtons() {
        let options: [UpgradeOption] = [.addShip, .speedBoost, .capacityBoost]
        let startY: CGFloat = 30
        let spacing: CGFloat = -60
        
        for (index, option) in options.enumerated() {
            let pos = CGPoint(x: 0, y: startY + spacing * CGFloat(index))
            let button = UpgradeButton(option: option, position: pos)
            addChild(button)
        }
    }
    
    private func makeButton(_ name: String, _ text: String, _ position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = position
        
        let shape = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 8)
        shape.fillColor = UIColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0)
        shape.strokeColor = .white
        shape.lineWidth = 2
        shape.name = "ButtonShape"
        container.addChild(shape)
        
        let label = SKLabelNode(text: text)
        label.fontColor = .white
        label.fontSize = 23
        label.verticalAlignmentMode = .center
        label.fontName = "HelveticaNeue-Bold"
        label.name = "ButtonLabel"
        container.addChild(label)
        
        return container
    }
    
    // MARK: - Touch Handling
    func handleTouch(_ location: CGPoint) {
        // Convert touch location to popup’s local coordinates (popup has custom size: 2000x2000)
        guard let parent = parent else { return }
        let localPos = convert(location, from: parent)
        let nodesAtPos = nodes(at: localPos)
        
        if let button = nodesAtPos.compactMap({ $0 as? UpgradeButton }).first {
            AudioService.shared.playSFX(node: self, fileName: "clickSound.wav")
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            onOptionSelected?(button.option)
            removeFromParent()
        }
    }
}

// MARK: - Helpers
fileprivate class UpgradeButton: SKNode { // Button used inside the popup
    let option: UpgradeOption
    
    init(option: UpgradeOption, position: CGPoint) {
        self.option = option
        super.init()
        self.position = position
        
        let shape = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 8)
        shape.fillColor = UIColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0)
        shape.strokeColor = .white
        shape.lineWidth = 2
        addChild(shape)
        
        let label = SKLabelNode(text: option.title)
        label.fontColor = .white
        label.fontSize = 23
        label.fontName = "HelveticaNeue-Bold"
        label.verticalAlignmentMode = .center
        addChild(label)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

protocol Popup {
    func handleTouch(_ location: CGPoint)
}
