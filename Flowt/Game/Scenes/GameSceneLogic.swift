//
//  GameSceneLogic.swift
//  Flowt
//
//  Created by Wiktor Drab on 19/09/2025.
//

import SpriteKit

extension GameScene {
    // MARK: - Game Management
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
        
        // Rewards for milestones
        if let color = GameConfig.milestoneRewards[score] {
            addExtraLine(lineColor: color, buttonColor: color)
        }
        
        cargoSpawnInterval = cargoInterval(score: score)
        
        if score == GameConfig.PointsToSpawnAdditionalStorm && additionalStorm == nil { unlockAdditionalStorm() }
        
        checkScoreAchievements(score: score) // Game Center
    }
    
    private func checkScoreAchievements(score: Int) {
        switch score {
        case 100:
            GameCenterService.shared.unlockAchievement(id: "flowt.ach.score.100")
        case 300:
            GameCenterService.shared.unlockAchievement(id: "flowt.ach.score.300.secondstorm")
        case 500:
            GameCenterService.shared.unlockAchievement(id: "flowt.ach.score.500.fulllines")
        case 1000:
            GameCenterService.shared.unlockAchievement(id: "flowt.ach.score.1000")
        case 2000:
            GameCenterService.shared.unlockAchievement(id: "flowt.ach.score.2000")
        default:
            break
        }
    }
    
    // MARK: Storm Handling
    func isInStormZone(_ point: CGPoint) -> Bool {
        return (storm?.contains(point) ?? false) || (additionalStorm?.contains(point) ?? false)
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
    
    // MARK: - Line and Connection Logic
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
    
    // MARK: - Collision Detection
    func checkIslandCollision(_ point: CGPoint) -> Bool {
        for island in islands {
            if island.contains(point: point) { return true }
        }
        return false
    }
    
    // MARK: - Setup
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
    
    // MARK: - Timer Management
    func setupTimers() {
        // Port spawning
        let spawnPortAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.spawnPortInterval),
                SKAction.run { [weak self] in
                    self?.spawnRandomPort(portType: CargoType.allCases.randomElement()!)
                }
            ])
        )
        run(spawnPortAction, withKey: TimerKeys.spawnPort)
        
        // Cargo spawning
        let spawnCargoAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: cargoSpawnInterval),
                SKAction.run { [weak self] in
                    self?.spawnRandomCargo()
                }
            ])
        )
        run(spawnCargoAction, withKey: TimerKeys.spawnCargo)
        
        // Storm spawning
        let spawnStormAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: GameConfig.spawnStormInterval),
                SKAction.run { [weak self] in
                    self?.spawnStorm()
                }
            ])
        )
        run(spawnStormAction, withKey: TimerKeys.spawnStorm)
        
        // UpgradePopup spawning
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
    
    private func cargoInterval(score: Int) -> TimeInterval {
        switch score {
        case ..<30:    return 3.0
        case ..<45:    return 2.5
        case ..<60:    return 2.0
        case ..<100:   return 1.7
        case ..<150:   return 1.2
        case ..<300:   return 0.75
        case ..<500:   return 0.55
        case ..<1000:  return 0.4
        case ..<1500:  return 0.3
        case ..<2000:  return 0.2
        default:       return 0.05
        }
    }
    
    // Invalidate the previous timer and create a new one
    func resetCargoSpawnTimer() {
        // Remove the previous action
        removeAction(forKey: TimerKeys.spawnCargo)
        
        // Add a new action with an updated interval
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
        removeAction(forKey: TimerKeys.spawnInitialPorts)
        removeAction(forKey: TimerKeys.spawnPort)
        removeAction(forKey: TimerKeys.spawnCargo)
        removeAction(forKey: TimerKeys.spawnStorm)
        removeAction(forKey: TimerKeys.spawnAdditionalStorm)
        removeAction(forKey: TimerKeys.upgrade)
        scene?.removeAction(forKey: Port.alarmActionKey)
        Port.overloadCount = 0
    }
}
