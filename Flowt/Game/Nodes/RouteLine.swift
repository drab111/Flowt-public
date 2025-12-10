//
//  RouteLine.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

class RouteLine: SKShapeNode {
    private let checkIslandCollision: ((CGPoint) -> Bool)
    private(set) var currentSegmentInvalid: Bool = false
    
    // For factory pattern and Scene-based management
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
    
    // MARK: - Path Management
    private func resetCurrentPoints() {
        currentPoints.removeAll()
        updatePath()
    }
    
    func startNewLine(from point: CGPoint) {
        currentPoints.removeAll()
        currentSegmentInvalid = false
        currentPoints.append(point)
        updatePath()
    }
    
    func addPoint(_ point: CGPoint) {
        guard !currentSegmentInvalid else { return }
        
        // First, check if the point lies within any island area
        if checkIslandCollision(point) {
            AudioService.shared.playSFX(node: self, fileName: "failureSound.wav")
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            currentSegmentInvalid = true
            resetCurrentPoints()
            return
        }
        
        currentPoints.append(point)
        updatePath()
    }
    
    func finalizeCurrentLine() {
        if isAppendingAtFront {
            // Stop all ships
            for ship in ships { ship.removeAllActions() }
            
            // Reverse currentPoints and insert at the beginning
            permanentPoints.insert(contentsOf: currentPoints.reversed(), at: 0)
            isAppendingAtFront = false
            
            // Reposition ships so they don’t teleport
            for ship in ships {
                ship.currentSegmentIndex += currentPoints.count
                ship.startNextSegment()
            }
        } else {
            // Default behavior
            permanentPoints.append(contentsOf: currentPoints)
        }
        currentPoints.removeAll()
        updatePath()
        
        // Create the first ship if none exists
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
