//
//  GameSceneUI.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import AudioToolbox
import SpriteKit

extension GameScene {
    private func createBackToMenuButton() {
        let background = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 10)
        background.fillColor = .clear
        background.strokeColor = .clear
        background.lineWidth = 0
        background.position = CGPoint(x: 50, y: 60)
        background.name = "BackToMenuButton"
        
        let label = SKLabelNode(text: "Menu")
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = "BackToMenuButton"
        
        background.addChild(label)
        addChild(background)
        backToMenuButton = background
    }
    
    private func createPauseButton() {
        let background = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 12)
        background.fillColor = .clear
        background.strokeColor = .clear
        background.lineWidth = 0
        background.position = CGPoint(x: self.size.width - 50, y: 60)
        background.name = "PauseButton"

        let label = SKLabelNode(text: "\u{23F8}\u{FE0E}")
        label.fontName = "Menlo"
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = "PauseButton"

        background.addChild(label)
        addChild(background)

        pauseButton = background
        pauseLabel = label
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
        
        let texture = SKTexture(imageNamed: "AnchorTexture")
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 35, height: 35)
        imageNode.zPosition = 6
        circle.addChild(imageNode)
        
        return circle
    }
    
    private func highlightColorButton(_ button: SKShapeNode) {
        button.childNode(withName: "buttonHighlight")?.removeFromParent()
        
        let container = SKNode()
        container.name = "buttonHighlight"
        container.zPosition = -1
        button.addChild(container)
        
        let radius: CGFloat = 24
        
        mainButtonCircut(container: container, radius: radius)
        makePulse(container: container, radius: radius)
    }
    
    private func mainButtonCircut(container: SKNode, radius: CGFloat = 24, arcLength: CGFloat = CGFloat.pi / 6, lineWidth: CGFloat = 3) {
        let arcLength = CGFloat.pi / 6
        for i in 0..<4 {
            let startAngle = CGFloat(i) * (.pi / 2)
            let endAngle = startAngle + arcLength
            let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            let arc = SKShapeNode(path: path.cgPath)
            arc.strokeColor = .cyan
            arc.lineWidth = lineWidth
            arc.alpha = 0.5
            arc.lineCap = .round
            container.addChild(arc)
        }
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        container.run(SKAction.repeatForever(rotate))
    }
    
    private func makePulse(container: SKNode, radius: CGFloat = 24) {
        let pulse = SKShapeNode(circleOfRadius: radius)
        pulse.strokeColor = .cyan
        pulse.lineWidth = 2
        pulse.alpha = 0.4
        container.addChild(pulse)
        
        let scaleUp = SKAction.scale(to: 1.6, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([scaleUp, fadeOut])
        let remove = SKAction.removeFromParent()
        pulse.run(SKAction.sequence([group, remove]))
    }

    func setupButtons() {
        addChild(scoreLabel)
        createBackToMenuButton()
        createPauseButton()
        createColorButtons()
    }
    
    func setupIslands() {
        let islandConfigs: [(CGPoint, CGFloat, String)] = [
            (CGPoint(x: size.width * 0.25, y: size.height * 0.35), 40, "IslandTexture1"),
            (CGPoint(x: size.width * 0.47, y: size.height * 0.2), 50, "IslandTexture2"),
            (CGPoint(x: size.width * 0.75, y: size.height * 0.75), 45, "IslandTexture3"),
            (CGPoint(x: size.width * 0.4, y: size.height * 0.55), 55, "IslandTexture4"),
            (CGPoint(x: size.width * 0.67, y: size.height * 0.41), 50, "IslandTexture5")
        ]
        
        for (pos, radius, pic) in islandConfigs { addIsland(position: pos, radius: radius, picture: pic) }
    }
    
    private func addIsland(position: CGPoint, radius: CGFloat, picture: String) {
        let island = Island(position: position, radius: radius, picture: picture)
        addChild(island)
        islands.append(island)
    }
    
    func setupBackground() {
        let ocean = Ocean(size: size)
        addChild(ocean)
        self.ocean = ocean
    }
    
    func setupCamera() {
        addChild(cameraNode)
        self.camera = cameraNode
        
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        cameraNode.setScale(1.0)
    }
    
    func addExtraLine(lineColor: UIColor, buttonColor: UIColor) {
        AudioService.shared.playSFX(node: self, fileName: "milestoneSound.wav")
        
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
        circle.lineWidth = 4
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        circle.zPosition = 5.5

        let texture = SKTexture(imageNamed: "AnchorTexture")
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 210, height: 210)
        imageNode.zPosition = 5
        circle.addChild(imageNode)

        return circle
    }
    
    func focusOnPort(port: Port, scale: CGFloat = 0.14, duration: TimeInterval = 2.0) {
        guard let camera = camera else { return }

        if let popup = activePopup {
            popup.removeFromParent()
            activePopup = nil
        }
        
        // zamrażamy wszystko poza portami i kamerą
        for node in children {
            if node is Port {
                (node as! Port).stopOverloadTimer()
            } else if !(node is SKCameraNode) {
                node.isPaused = true
            }
        }
        
        invalidateTimers()
        showGameOverLabel(camera: camera)
        AudioService.shared.playSystemSFX(id: 1254)
        
        let move = SKAction.move(to: port.position, duration: duration)
        let zoom = SKAction.scale(to: scale, duration: duration)
        let group = SKAction.group([move, zoom])
        group.timingMode = .easeInEaseOut

        camera.run(group)
    }
    
    private func showGameOverLabel(camera: SKCameraNode) {
        let label = SKLabelNode(text: "GAME OVER")
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -UIScreen.main.bounds.height / 3.5)
        label.zPosition = 25
        label.alpha = 0
        camera.addChild(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        label.run(fadeIn)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt = CGFloat(1.0 / 60.0)
        ocean?.update(dt)
    }
}
