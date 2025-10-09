//
//  GameSceneLogic.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import SpriteKit

extension GameScene {
    func gameOver() {
        for port in ports { port.removeFromParent() }
        ports.removeAll()
        
        for line in routeLines { line.removeFromParent() }
        routeLines.removeAll()
        
        for button in colorButtons { button.removeFromParent() }
        colors.removeAll()
        
        for island in islands { island.removeFromParent() }
        islands.removeAll()
        
        scoreLabel.removeFromParent()
        backToMenuButton = nil
        pauseButton = nil
        pauseLabel = nil
        storm = nil
        additionalStorm = nil
        ocean = nil
        activePopup = nil
        pendingUpgrade = nil
        
        scoreVM.setScore(score)
        gameVM.endGame()
    }
    
    func increaseScore() {
        score += 1

        // Nagrody za milestone’y
        if let color = GameConfig.milestoneRewards[score] {
            addExtraLine(lineColor: color, buttonColor: color)
        }

        cargoSpawnInterval = cargoInterval(score: score)
        
        if score == GameConfig.PointsToSpawnAdditionalStorm && additionalStorm == nil { unlockAdditionalStorm() }
    }
    
    private func unlockAdditionalStorm() {
        spawnAdditionalStorm()

        let action = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.spawnAdditionalStormInterval),
                SKAction.run { [weak self] in
                    self?.spawnAdditionalStorm()
                }
            ])
        )
        run(action, withKey: TimerKeys.spawnAdditionalStorm)
    }
    
    private func cargoInterval(score: Int) -> TimeInterval {
        switch score {
        case ..<30:    return 2.5
        case ..<45:    return 2.2
        case ..<60:    return 1.8
        case ..<100:   return 1.4
        case ..<150:   return 1.0
        case ..<300:   return 0.7
        case ..<500:   return 0.4
        case ..<1000:  return 0.25
        case ..<1500:  return 0.15
        default:       return 0.1
        }
    }
    
    func checkConnectionForSegment(points: [CGPoint], line: RouteLine) -> (Port, Port)? {
        guard let start = points.first, let end = points.last else { return nil }
        
        let startPort = ports.first(where: { isPoint(start, nearPort: $0) })
        let endPort   = ports.first(where: { isPoint(end, nearPort: $0) })
        
        guard let startPort = startPort, let endPort = endPort, startPort != endPort else { return nil }
        if line.existingConnections.contains(where: { $0 == (startPort, endPort) || $0 == (endPort, startPort) }) { return nil }
        
        return (startPort, endPort)
    }
    
    func isPoint(_ point: CGPoint, nearPort port: Port) -> Bool {
        let distance = hypot(point.x - port.position.x, point.y - port.position.y)
        let portRadius = port.size.width / 2 + 5
        return distance <= portRadius
    }
    
    func isInStormZone(_ point: CGPoint) -> Bool {
        return (storm?.contains(point) ?? false) || (additionalStorm?.contains(point) ?? false)
    }
    
    func checkIfLoopClosed(line: RouteLine) {
        guard line.permanentPoints.count >= 3 else { return }
        let firstPoint = line.permanentPoints[0]
        let lastPoint  = line.permanentPoints.last!
        let distance = hypot(firstPoint.x - lastPoint.x, firstPoint.y - lastPoint.y)
        if distance < GameConfig.portConnectionTolerance {
            line.isLoop = true
            line.updatePath()
        }
    }
    
    func checkIslandCollision(_ point: CGPoint) -> Bool {
        for island in islands {
            if island.contains(point: point) { return true }
        }
        return false
    }
    
    func setupRouteLines() {
        routeLines = colors.map { color in
            RouteLine(lineColor: color, checkIslandCollision: { [weak self] point in
                self?.checkIslandCollision(point) ?? false
            },
            isInStormZone: { [weak self] point in
                self?.isInStormZone(point) ?? false
            },
            getPorts: { [weak self] in
                self?.ports ?? []
            })
        }
        routeLines.forEach(addChild)
    }
    
    func setupTimers() {
        // Spawn Portów
        let spawnPortAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.spawnPortInterval),
                SKAction.run { [weak self] in
                    self?.spawnRandomPort(portType: CargoType.allCases.randomElement()!)
                }
            ])
        )
        run(spawnPortAction, withKey: TimerKeys.spawnPort)
        
        // Spawn Cargo
        let spawnCargoAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: cargoSpawnInterval),
                SKAction.run { [weak self] in
                    self?.spawnRandomCargo()
                }
            ])
        )
        run(spawnCargoAction, withKey: TimerKeys.spawnCargo)
        
        // Spawn Burzy
        let spawnStormAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.spawnStormInterval),
                SKAction.run { [weak self] in
                    self?.spawnStorm()
                }
            ])
        )
        run(spawnStormAction, withKey: TimerKeys.spawnStorm)
        
        // Upgrade popup
        let upgradeAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.upgradePopupInterval),
                SKAction.run { [weak self] in
                    self?.showUpgradePopup()
                }
            ])
        )
        run(upgradeAction, withKey: TimerKeys.upgrade)
    }
    
    // Unieważniamy poprzedni timer i tworzymy nowy
    func resetCargoSpawnTimer() {
        // Usuwamy starą akcję
        removeAction(forKey: TimerKeys.spawnCargo)
        
        // Dodajemy nową z nowym interwałem
        let spawnCargoAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: cargoSpawnInterval),
                SKAction.run { [weak self] in
                    self?.spawnRandomCargo()
                }
            ])
        )
        run(spawnCargoAction, withKey: TimerKeys.spawnCargo)
    }
    
    func invalidateTimers() {
        removeAction(forKey: TimerKeys.spawnPort)
        removeAction(forKey: TimerKeys.spawnCargo)
        removeAction(forKey: TimerKeys.spawnStorm)
        removeAction(forKey: TimerKeys.spawnAdditionalStorm)
        removeAction(forKey: TimerKeys.upgrade)
        scene?.removeAction(forKey: Port.alarmActionKey)
        Port.overloadCount = 0
    }
}
