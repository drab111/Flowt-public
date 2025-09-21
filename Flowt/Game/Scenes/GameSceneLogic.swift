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
        storm = nil
        activePopup = nil
        pendingUpgrade = nil
        
        gameVM.endGame()
    }
    
    func increaseScore() {
        score += 1

        // Nagrody za milestone’y
        if let color = GameConfig.milestoneRewards[score] {
            addExtraLine(lineColor: color, buttonColor: color)
        }

        cargoSpawnInterval = cargoInterval(score: score)
    }
    
    private func cargoInterval(score: Int) -> TimeInterval {
        let maxScore: Double = 500
        let start: Double = 2.0
        let end: Double = 0.05

        let t = min(Double(score) / maxScore, 1.0)
        return start + (end - start) * t
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
    
    func isInStormZone(_ point: CGPoint) -> Bool { return storm?.contains(point) ?? false }
    
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
        spawnPortTimer = Timer.scheduledTimer(withTimeInterval: GameConfig.spawnPortInterval, repeats: true) { [weak self] _ in
            self?.spawnRandomPort(portType: CargoType.allCases.randomElement()!)
        }
        
        spawnCargoTimer = Timer.scheduledTimer(withTimeInterval: cargoSpawnInterval, repeats: true) { [weak self] _ in
            self?.spawnRandomCargo()
        }
        
        spawnStormTimer = Timer.scheduledTimer(withTimeInterval: GameConfig.spawnStormInterval, repeats: true) { [weak self] _ in
            self?.spawnStorm()
        }
        
        upgradeTimer = Timer.scheduledTimer(withTimeInterval: GameConfig.upgradePopupInterval, repeats: true) { [weak self] _ in
            self?.showUpgradePopup()
        }
    }
    
    // Unieważniamy poprzedni timer i tworzymy nowy
    func resetCargoSpawnTimer() {
        spawnCargoTimer?.invalidate()
        spawnCargoTimer = Timer.scheduledTimer(withTimeInterval: cargoSpawnInterval, repeats: true) { [weak self] _ in
            self?.spawnRandomCargo()
        }
    }
    
    func invalidateTimers() {
        [spawnPortTimer, spawnCargoTimer, spawnStormTimer, upgradeTimer].forEach { $0?.invalidate() }
        spawnPortTimer = nil
        spawnCargoTimer = nil
        spawnStormTimer = nil
        upgradeTimer = nil
    }
}
