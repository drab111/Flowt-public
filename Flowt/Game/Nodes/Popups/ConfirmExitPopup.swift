//
//  ConfirmExitPopup.swift
//  Flowt
//
//  Created by Wiktor Drab on 21/09/2025.
//

import SpriteKit

class ConfirmExitPopup: SKNode, Popup {
    private var onConfirm: (() -> Void)?
    private var onCancel: (() -> Void)?
    
    init(size: CGSize, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        super.init()
        self.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.zPosition = 50
        self.name = "ConfirmExitPopup"
        
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        
        setupBackground(size: size)
        setupBox()
        setupButtons()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Setup UI
    private func setupBackground(size: CGSize) {
        let bg = SKSpriteNode(color: .black, size: size)
        bg.alpha = 0.5
        bg.zPosition = -1
        bg.name = "ConfirmExitBG"
        addChild(bg)
    }
    
    private func setupBox() {
        let box = SKShapeNode(rectOf: CGSize(width: 280, height: 160), cornerRadius: 16)
        box.fillColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.9)
        box.strokeColor = .white
        box.lineWidth = 2
        addChild(box)
        
        let label = SKLabelNode(text: "Quit to menu?")
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 22
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 40)
        addChild(label)
    }
    
    private func setupButtons() {
        let yesButton = makeButton(text: "Yes", color: .red)
        yesButton.position = CGPoint(x: -70, y: -40)
        yesButton.name = "ConfirmYes"
        addChild(yesButton)
        
        let noButton = makeButton(text: "No", color: .green)
        noButton.position = CGPoint(x: 70, y: -40)
        noButton.name = "ConfirmNo"
        addChild(noButton)
    }
    
    private func makeButton(text: String, color: UIColor) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 8)
        button.fillColor = color.withAlphaComponent(0.5)
        button.strokeColor = .white
        button.lineWidth = 2
        
        let label = SKLabelNode(text: text)
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
        
        return button
    }
    
    // MARK: - Touch Handling
    func handleTouch(_ location: CGPoint) {
        guard let parent = parent else { return }
        let localPos = convert(location, from: parent)
        let nodesAtPos = nodes(at: localPos)
        
        for node in nodesAtPos {
            if node.name == "ConfirmYes" {
                onConfirm?()
                removeFromParent()
            } else if node.name == "ConfirmNo" {
                onCancel?()
                removeFromParent()
            }
        }
    }
}
