//
//  MovementStrategy.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

import SpriteKit

protocol MovementStrategy {
    func moveShip(_ context: ShipMovementContext)
}

class ShipMovementContext {
    private unowned let ship: Ship
    private var strategy: MovementStrategy
    
    init(ship: Ship, strategy: MovementStrategy) {
        self.ship = ship
        self.strategy = strategy
    }
    
    func setStrategy(_ strategy: MovementStrategy) { self.strategy = strategy }
    
    func getShip() -> Ship { return self.ship }
    
    func move() { strategy.moveShip(self) }
}

class LoopMovementStrategy: MovementStrategy {
    func moveShip(_ context: ShipMovementContext) {
        let ship = context.getShip()
        let pts = ship.linePermanentPoints
        let n = pts.count
        
        let i1 = ship.currentSegmentIndex
        let i2 = ship.goingForward ? (i1 + 1) % n : (i1 - 1 + n) % n
        
        let p1 = pts[i1]
        let p2 = pts[i2]
        
        let portAtP2 = ship.findPort(point: p2)
        ship.checkStormIfNeeded()
        ship.handlePortIfNeeded(port: portAtP2)
        
        let dist = ship.distanceBetween(p1, p2)
        let duration = TimeInterval(dist / ship.shipSpeed)
        
        let angle = atan2(p2.y - p1.y, p2.x - p1.x) + CGFloat.pi/2
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0, shortestUnitArc: true)
        let moveAction = SKAction.move(to: p2, duration: duration)
        
        let nextSegment = SKAction.run {
            ship.currentSegmentIndex = i2
            ship.startNextSegment()
        }
        
        ship.run(SKAction.sequence([rotateAction, moveAction, nextSegment]))
    }
}

class BackAndForthMovementStrategy: MovementStrategy {
    func moveShip(_ context: ShipMovementContext) {
        let ship = context.getShip()
        let pts = ship.linePermanentPoints
        let n = pts.count
        
        if ship.goingForward && ship.currentSegmentIndex >= n-1 {
            ship.goingForward = false
        } else if !ship.goingForward && ship.currentSegmentIndex <= 0 {
            ship.goingForward = true
        }
        
        let i1 = ship.currentSegmentIndex
        let i2 = ship.goingForward ? i1 + 1 : i1 - 1
        
        if i2 < 0 {
            ship.currentSegmentIndex = 0
            ship.goingForward = true
            ship.startNextSegment()
            return
        } else if i2 >= n {
            ship.currentSegmentIndex = n-1
            ship.goingForward = false
            ship.startNextSegment()
            return
        }
        
        let p1 = pts[i1]
        let p2 = pts[i2]
        
        let portAtP2 = ship.findPort(point: p2)
        ship.checkStormIfNeeded()
        ship.handlePortIfNeeded(port: portAtP2)
        
        let dist = ship.distanceBetween(p1, p2)
        let duration = TimeInterval(dist / ship.shipSpeed)
        
        let angle = atan2(p2.y - p1.y, p2.x - p1.x) + CGFloat.pi/2
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0, shortestUnitArc: true)
        let moveAction = SKAction.move(to: p2, duration: duration)
        
        let nextSegment = SKAction.run {
            ship.currentSegmentIndex = i2
            ship.startNextSegment()
        }
        
        ship.run(SKAction.sequence([rotateAction, moveAction, nextSegment]))
    }
}
