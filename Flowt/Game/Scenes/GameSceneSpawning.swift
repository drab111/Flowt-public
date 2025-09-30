//
//  GameSceneSpawning.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import SpriteKit

extension GameScene {
    func addPort(position: CGPoint, type: CargoType) {
        let port = Port(position: position, portType: type, factory: cargoFactory, increaseScore: { [weak self] in
                self?.increaseScore()
            },
            gameOver: { [weak self] in
                self?.gameOver()
            },
            focusOnPort: { [weak self] port in
                self?.focusOnPort(port: port)
            })
        
        addChild(port)
        ports.append(port)
    }
    
    func setupInitialPorts() {
        for type in CargoType.allCases { spawnRandomPort(portType: type) }
    }
    
    func spawnRandomPort(portType: CargoType) {
        for _ in 0..<GameConfig.maxPortAttempts {
            let randomX = CGFloat.random(in: GameConfig.portMarginX...(size.width - GameConfig.portMarginX))
            let randomY = CGFloat.random(in: GameConfig.portMarginY...(size.height - GameConfig.portBottomMargin))
            let candidatePos = CGPoint(x: randomX, y: randomY)
            
            if !isTooCloseToAnyPort(candidatePos, minDistance: GameConfig.minDistanceToPort),
               !isTooCloseToAnyIsland(candidatePos, minDistance: GameConfig.minDistanceToIsland),
               !isTooCloseToAnyButton(candidatePos, minDistance: GameConfig.minDistanceToButton) {
                addPort(position: candidatePos, type: portType)
                return
            }
        }
    }
    
    func spawnRandomCargo() { ports.randomElement()?.produceRandomCargo() }
    
    func spawnStorm() {
        // Usuwamy starą burzę
        storm?.removeFromParent()
        storm = nil
        
        // Losujemy obszar dla nowej
        let randomX = CGFloat.random(in: GameConfig.stormMargin...(size.width - GameConfig.stormMargin))
        let randomY = CGFloat.random(in: GameConfig.stormMargin...(size.height - GameConfig.stormMargin))
        let position = CGPoint(x: randomX, y: randomY)
        let radius: CGFloat = GameConfig.stormRadius
        
        let stormNode = Storm(position: position, radius: radius)
        addChild(stormNode)
        storm = stormNode
        AudioService.shared.playSFX(node: self, fileName: "stormSound.wav")
    }
    
    // MARK: - Collision helpers
    private func isTooCloseToAnyPort(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        for port in ports {
            let dist = hypot(port.position.x - pos.x, port.position.y - pos.y)
            if dist < minDistance { return true }
        }
        return false
    }
    
    private func isTooCloseToAnyIsland(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        for island in islands {
            let dist = hypot(island.position.x - pos.x, island.position.y - pos.y)
            if dist < minDistance { return true }
        }
        return false
    }
    
    private func isTooCloseToAnyButton(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        // Wszystkie możliwe przyciski linii które są i mogą się pojawić
        let buttonPosition = [
            CGPoint(x: size.width - 40, y: size.height - CGFloat(40)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(90)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(140)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(190)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(240)),
        ]
        
        for button in buttonPosition {
            let dist = hypot(button.x - pos.x, button.y - pos.y)
            if dist < minDistance { return true }
        }
        
        // Dla backToMenuButton i ScoreLabel
        if let button = backToMenuButton {
            let distToButton = hypot(button.position.x - pos.x, button.position.y - pos.y)
            if distToButton < minDistance { return true }
        }
        let distToLabel = hypot(scoreLabel.position.x + 20.0 - pos.x, scoreLabel.position.y - pos.y)
        if distToLabel < minDistance + 30.0 { return true }
        return false
    }
}
