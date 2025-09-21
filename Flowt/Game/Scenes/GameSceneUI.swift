//
//  GameSceneUI.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import SpriteKit

extension GameScene {
    private func createBackToMenuButton() {
        let button = SKLabelNode(text: "Menu")
        button.fontName = "HelveticaNeue-Bold"
        button.fontSize = 24
        button.fontColor = .white
        button.position = CGPoint(x: 50, y: 50)
        button.name = "BackToMenuButton"
        addChild(button)
        backToMenuButton = button
    }
    
    func createColorButtons() {
        for button in colorButtons { button.removeFromParent() }
        colorButtons.removeAll()
        
        for (i, color) in colors.enumerated() {
            let button = makeColorButton(color: color, index: i)
            addChild(button)
            colorButtons.append(button)
            
            if i == currentLineIndex { highlightColorButton(button) }
        }
    }
    
    private func makeColorButton(color: UIColor, index: Int) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: 20)
        circle.fillColor = color
        circle.strokeColor = .black
        circle.lineWidth = 2
        circle.zPosition = 5
        circle.position = CGPoint(x: size.width - 40, y: size.height - CGFloat(40 + index * 50))
        circle.name = "colorButton\(index)"
        
        let texture = SKTexture(imageNamed: "SignTexture") // TODO: wymień na własny symbol
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 35, height: 35)
        imageNode.zPosition = 6
        circle.addChild(imageNode)
        
        return circle
    }
    
    private func highlightColorButton(_ button: SKShapeNode) {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        button.run(SKAction.repeatForever(pulse))

        button.strokeColor = .yellow
        button.lineWidth = 4
    }
    
    func setupUI() {
        addChild(scoreLabel)
        createBackToMenuButton()
        createColorButtons()
    }
    
    func setupIslands() {
        let islandConfigs: [(CGPoint, CGFloat, String)] = [
            (CGPoint(x: size.width*0.75, y: size.height*0.75), 40, "island_picture"),
            (CGPoint(x: size.width*0.4,  y: size.height*0.55), 50, "island_picture2"),
            (CGPoint(x: size.width*0.3,  y: size.height*0.25), 45, "island_picture3"),
            (CGPoint(x: size.width*0.67, y: size.height*0.41), 50, "island_picture4")
        ]
        
        for (pos, radius, pic) in islandConfigs { addIsland(position: pos, radius: radius, picture: pic) }
    }
    
    func addIsland(position: CGPoint, radius: CGFloat, picture: String) {
        let island = Island(position: position, radius: radius, picture: picture)
        addChild(island)
        islands.append(island)
    }
    
    func addExtraLine(lineColor: UIColor, buttonColor: UIColor) {
        //self.run(SKAction.playSoundFileNamed("newLineSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
        // Tworzymy reprezentację graficzną
        let notificationCircle = makeNotificationCircle(color: buttonColor, lineColor: lineColor)
        addChild(notificationCircle)
        
        // Tworzymy animację
        let targetPosition = CGPoint(x: size.width - 40, y: size.height - CGFloat(40 + (routeLines.count * 50)))
        let delay = SKAction.wait(forDuration: 1.0)
        let scaleAction = SKAction.scale(to: 0.2, duration: 1.0)
        let moveAction = SKAction.move(to: targetPosition, duration: 1.0)
        let groupAction = SKAction.group([scaleAction, moveAction])
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([delay, groupAction, removeAction])
        
        notificationCircle.run(sequence) {
            // Po animacji dodajemy nową linię
            self.colors.append(buttonColor)
            let newLine = RouteLine(lineColor: lineColor, checkIslandCollision: { [weak self] point in
                self?.checkIslandCollision(point) ?? false
            },
            isInStormZone: { [weak self] point in
                self?.isInStormZone(point) ?? false
            },
            getPorts: { [weak self] in
                self?.ports ?? []
            })
            self.routeLines.append(newLine)
            self.addChild(newLine)
            self.createColorButtons()
        }
    }
    
    private func makeNotificationCircle(color: UIColor, lineColor: UIColor) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: 120)
        circle.fillColor = color
        circle.strokeColor = .black
        circle.lineWidth = 2
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        circle.zPosition = 4

        let texture = SKTexture(imageNamed: "SignTexture") // TODO: Zmień
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 210, height: 210)
        imageNode.zPosition = 5
        circle.addChild(imageNode)

        return circle
    }
}
