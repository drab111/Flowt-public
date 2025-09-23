//
//  RouteLine.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

class RouteLine: SKShapeNode {
    private let checkIslandCollision: ((CGPoint) -> Bool)
    
    // Dla wzorca fabryki i zarządzania przez Scene
    let isInStormZone: ((CGPoint) -> Bool)
    let getPorts: (() -> [Port])
    var permanentPoints: [CGPoint] = []
    var currentPoints: [CGPoint] = []
    var existingConnections: [(Port, Port)] = []
    var isLoop: Bool = false
    var ships: [Ship] = []
    var isAppendingAtFront = false
    
    init(lineColor: UIColor, checkIslandCollision: @escaping ((CGPoint) -> Bool), isInStormZone: @escaping ((CGPoint) -> Bool), getPorts: @escaping () -> [Port]) {
        self.checkIslandCollision = checkIslandCollision
        self.isInStormZone = isInStormZone
        self.getPorts = getPorts
        super.init()
        self.strokeColor = lineColor.withAlphaComponent(0.4)
        self.lineWidth = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    private func resetCurrentPoints() {
        currentPoints.removeAll()
        updatePath()
    }
    
    func startNewLine(from point: CGPoint) {
        currentPoints.removeAll()
        currentPoints.append(point)
        updatePath()
    }
    
    func addPoint(_ point: CGPoint) {
        // Najpierw sprawdźmy czy punkt jest w obszarze jakiejś wyspy
        if checkIslandCollision(point) {
            resetCurrentPoints()
            return
        }
        currentPoints.append(point)
        updatePath()
    }
    
    func finalizeCurrentLine() {
        if isAppendingAtFront {
            // Zatrzymujemy statki
            for ship in ships { ship.removeAllActions() }
            
            // Odwracamy currentPoints i wstawiamy na początek
            permanentPoints.insert(contentsOf: currentPoints.reversed(), at: 0)
            isAppendingAtFront = false
            
            // Ustawiamy statki na nowej pozycji w tablicy tak aby się nie teleportowały
            for ship in ships {
                ship.currentSegmentIndex += currentPoints.count
                ship.startNextSegment()
            }
        } else {
            // normalnie
            permanentPoints.append(contentsOf: currentPoints)
        }
        currentPoints.removeAll()
        updatePath()
        
        // Tworzymy pierwszy statek jeśli go brak
        if ships.isEmpty && permanentPoints.count >= 2 {
            let newShip = Ship(position: permanentPoints[0], parentLine: self, isInStormZone: isInStormZone, getPorts: getPorts)
            ships.append(newShip)
            addChild(newShip)
            newShip.setMovementContext(ShipMovementContext(ship: newShip, strategy: BackAndForthMovementStrategy()))
            newShip.startNextSegment()
        }
    }
    
    func updatePath() {
        let path = CGMutablePath()
        
        if !permanentPoints.isEmpty {
            path.move(to: permanentPoints[0])
            for point in permanentPoints.dropFirst() { path.addLine(to: point) }
            if isLoop && permanentPoints.count >= 2 { path.addLine(to: permanentPoints[0]) }
        }
        
        if !currentPoints.isEmpty {
            if permanentPoints.isEmpty { path.move(to: currentPoints[0]) }
            if isAppendingAtFront { path.move(to: currentPoints[0]) }
            for point in currentPoints { path.addLine(to: point) }
        }
        
        self.path = path
    }
}
