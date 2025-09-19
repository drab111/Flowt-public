//
//  Ship.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Ship: SKSpriteNode {
    weak var parentLine: RouteLine?
    private lazy var loopMovementStrategy: LoopMovementStrategy = LoopMovementStrategy()
    private var movementContext: ShipMovementContext?
    private var isInStormZone: ((CGPoint) -> Bool)
    private var getPorts: (() -> [Port])
    
    // Potrzebne dla wzorca Strategii
    var shipSpeed: CGFloat = 30.0
    var speedBoost: CGFloat = 1.0
    var maxCapacity = 4
    var currentSegmentIndex: Int = 0
    var goingForward: Bool = true
    var cargoBuffer: [Cargo] = []
    
    init(position: CGPoint, parentLine: RouteLine, isInStormZone: @escaping ((CGPoint) -> Bool), getPorts: @escaping (() -> [Port])) {
        self.parentLine = parentLine
        self.isInStormZone = isInStormZone
        self.getPorts = getPorts
        
        let texture = SKTexture(imageNamed: "ShipTexture")
        super.init(texture: texture, color: .clear, size: CGSize(width: 30, height: 20))
        
        self.position = position
        self.zPosition = 3
        self.name = "Ship"
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    private func updateShipCargoDisplay() {
        // Usuwamy wszystkie poprzednie Node'y
        let oldIcons = children.filter { $0.name == "MiniCargoShip" }
        oldIcons.forEach { $0.removeFromParent() }
        
        // Dodajemy obecne Node'y
        let radius: CGFloat = 15
        let angleStep = CGFloat.pi / 4
        for (index, cargo) in cargoBuffer.enumerated() {
            let angle = CGFloat(index) * angleStep
            let dx = radius * cos(angle)
            let dy = radius * sin(angle)
            let miniNode = SKSpriteNode(texture: cargo.texture, color: cargo.color, size: CGSize(width: 8, height: 8))
            miniNode.colorBlendFactor = cargo.colorBlendFactor
            miniNode.position = CGPoint(x: dx, y: dy)
            miniNode.zPosition = 3
            miniNode.name = "MiniCargoShip"
            addChild(miniNode)
        }
    }
    
    func setMovementContext(_ context: ShipMovementContext) { self.movementContext = context }
    
    func startNextSegment() {
        guard let context = movementContext, let line = parentLine, line.permanentPoints.count >= 2 else { return }
        if line.isLoop == true { context.setStrategy(loopMovementStrategy) }
        context.move()
        updateShipCargoDisplay()
    }
    
    func checkStormIfNeeded() {
        shipSpeed = 30.0 * speedBoost
        // Sprawdzamy czy nasza pozycja jest w burzy
        if isInStormZone(self.position) { shipSpeed *= 0.5 }
    }
    
    func handlePortIfNeeded(port: Port?) {
        if let port = port {
            shipSpeed = 20.0 * speedBoost
            
            if port.isOccupied == false {
                port.isOccupied = true
                port.acceptMatchingCargo(ship: self)
                
                // Załadowywujemy cargo w porcie (którego port "nie lubi")
                let freeSpace = maxCapacity - cargoBuffer.count
                if freeSpace > 0 {
                    let taken = port.removeCargo(type: port.portType, maxCount: freeSpace)
                    for cargo in taken {
                        cargo.removeFromParent()
                        cargoBuffer.append(cargo)
                        cargo.isHidden = true
                        cargo.position = .zero
                        cargo.zPosition = 3
                        addChild(cargo)
                    }
                }
                updateShipCargoDisplay()
                port.updatePortCargoDisplay()
                port.isOccupied = false
            }
        } else {
            shipSpeed = 30.0  * speedBoost
            checkStormIfNeeded()
        }
    }
    
    func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
    
    // Sprawdzamy czy aktualny punkt na którym jest statek znajduje się w zasięgu któregoś z portów
    func findPort(point: CGPoint) -> Port? {
        let maxDistance: CGFloat = 15
        for port in getPorts() {
            if distanceBetween(port.position, point) < maxDistance { return port }
        }
        return nil
    }
}
