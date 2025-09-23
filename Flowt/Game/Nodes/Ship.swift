//
//  Ship.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Ship: SKNode {
    weak var parentLine: RouteLine?
    private let shipSprite: SKSpriteNode
    private let cargoContainer = SKNode()
    private var movementContext: ShipMovementContext?
    private var isInStormZone: ((CGPoint) -> Bool)
    private var getPorts: (() -> [Port])
    private lazy var loopMovementStrategy: LoopMovementStrategy = LoopMovementStrategy()
    
    // Potrzebne dla wzorca Strategii
    var shipSpeed: CGFloat = GameConfig.shipSpeed
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
        shipSprite = SKSpriteNode(texture: texture, color: .clear, size: GameConfig.shipSize)
        shipSprite.zPosition = 3
        shipSprite.name = "Ship"
        
        super.init()
        
        self.position = position
        self.zPosition = 3
        self.name = "ShipNode"
        addChild(shipSprite) // obracamy tylko sprite'a
        addChild(cargoContainer) // container nie obraca się
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: Wygląd
    
    private func updateShipCargoDisplay() {
        cargoContainer.removeAllChildren()
        
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
            
            cargoContainer.addChild(miniNode)
        }
    }
    
    func rotateShip(angle: CGFloat) {
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0, shortestUnitArc: true)
        shipSprite.run(rotateAction)
    }
    
    // MARK: - Ruch i rozładunek
    
    func setMovementContext(_ context: ShipMovementContext) { self.movementContext = context }
    
    func startNextSegment() {
        guard let context = movementContext, let line = parentLine, line.permanentPoints.count >= 2 else { return }
        if line.isLoop == true { context.setStrategy(loopMovementStrategy) }
        context.move()
        updateShipCargoDisplay()
    }
    
    func checkStormIfNeeded() {
        shipSpeed = GameConfig.shipSpeed * speedBoost
        // Sprawdzamy czy nasza pozycja jest w burzy
        if isInStormZone(self.position) { shipSpeed *= GameConfig.stormSlowdown }
    }
    
    func handlePortIfNeeded(port: Port?) {
        if let port = port {
            shipSpeed = GameConfig.portSpeed * speedBoost
            
            if port.isOccupied == false {
                port.isOccupied = true
                port.unloadCargo(ship: self)
                loadCargo(port: port)
                updateShipCargoDisplay()
                port.updatePortCargoDisplay()
                port.isOccupied = false
            }
        } else {
            shipSpeed = GameConfig.shipSpeed  * speedBoost
            checkStormIfNeeded()
        }
    }
    
    private func loadCargo(port: Port) {
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
    }
    
    // MARK: - Helpers
    
    func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
    
    // Sprawdzamy czy aktualny punkt na którym jest statek znajduje się w zasięgu któregoś z portów
    func findPort(point: CGPoint) -> Port? {
        let maxDistance = GameConfig.portDetectionRadius
        for port in getPorts() {
            if distanceBetween(port.position, point) < maxDistance { return port }
        }
        return nil
    }
}
