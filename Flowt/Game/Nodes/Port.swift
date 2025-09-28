//
//  Port.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import AudioToolbox
import SpriteKit

class Port: SKSpriteNode {
    static var overloadCount = 0  // ilu portów jest przeciążonych
    static let alarmActionKey = "GlobalAlarmAction" // animacja do grania dźwięku co sekundę
    
    private var overloadActionKey = "OverloadTimerAction"
    private var cargoFactory: CargoFactory
    private var cargoBuffer: [Cargo] = []
    private let maxBuffer = GameConfig.portMaxBuffer
    private var remainingTime: CGFloat = GameConfig.overloadTime
    private var isOverloaded = false
    private var overloadIndicator: SKShapeNode?
    private var increaseScore: (() -> Void)
    private var gameOver: (() -> Void)
    private var focusOnPort: ((Port) -> Void)
    var portType: CargoType
    var isOccupied = false
    
    init(position: CGPoint, portType: CargoType, factory: CargoFactory, increaseScore: @escaping (() -> Void), gameOver: @escaping (() -> Void), focusOnPort: @escaping ((Port) -> Void)) {
        self.portType = portType
        self.cargoFactory = factory
        self.increaseScore = increaseScore
        self.gameOver = gameOver
        self.focusOnPort = focusOnPort
        let texture = SKTexture(imageNamed: portType.symbol)
        super.init(texture: texture, color: .white, size: GameConfig.portSize)

        self.position = position
        self.zPosition = 2
        self.name = "Port"

        self.run(SKAction.playSoundFileNamed("portSpawnSound.wav", waitForCompletion: false))
        makePortShape()
        runSpawnAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Wygląd
    
    private func makePortShape() {
        let circle = SKShapeNode(circleOfRadius: 16)
        circle.fillColor = .white
        circle.alpha = 0.5
        circle.strokeColor = .clear
        circle.zPosition = -1
        circle.name = "PortCircle"
        addChild(circle)
    }
    
    private func runSpawnAnimation() {
        // Bounce-in (port skaluje się przy pojawieniu)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        scaleUp.timingMode = .easeOut

        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleDown.timingMode = .easeIn

        let appear = SKAction.sequence([
            SKAction.scale(to: 0.0, duration: 0.0),
            scaleUp,
            scaleDown
        ])
        self.run(appear)
        
        // Rozbłysk kółka (sygnał nowego portu)
        let flashCircle = SKShapeNode(circleOfRadius: 24)
        flashCircle.fillColor = .white
        flashCircle.alpha = 0.4
        flashCircle.strokeColor = .clear
        flashCircle.zPosition = -2
        addChild(flashCircle)
        
        let expand = SKAction.group([
            SKAction.fadeOut(withDuration: 0.6),
            SKAction.scale(to: 2.0, duration: 0.6)
        ])
        let remove = SKAction.removeFromParent()
        flashCircle.run(.sequence([expand, remove]))
    }
    
    private func flashPortCircleSuccess() {
        if let circle = children.first(where: { $0 is SKShapeNode && $0.name == "PortCircle" }) as? SKShapeNode {
            let green = SKAction.run { circle.fillColor = .green }
            let wait = SKAction.wait(forDuration: 0.3)
            let back = SKAction.run { circle.fillColor = .white }
            let seq = SKAction.sequence([green, wait, back])
            circle.run(seq)
        }
    }
    
    // Odpowiada za ustalenie które ładunki są obecnie w porcie i je renderuje
    func updatePortCargoDisplay() {
        // Usuwamy wszystkie poprzednie Node'y
        let oldIcons = children.filter { $0.name == "MiniCargoPort" }
        oldIcons.forEach { $0.removeFromParent() }
        
        // Dodajemy obecne Node'y
        let radius: CGFloat = 22
        let angleStep = CGFloat.pi / 6
        for (index, cargo) in cargoBuffer.enumerated() {
            let angle = CGFloat(index) * angleStep
            let dx = radius * cos(angle)
            let dy = radius * sin(angle)
            let miniNode = SKSpriteNode(texture: cargo.texture, color: cargo.color, size: CGSize(width: 12, height: 12))
            miniNode.colorBlendFactor = cargo.colorBlendFactor
            miniNode.position = CGPoint(x: dx, y: dy)
            miniNode.zPosition = 3
            miniNode.name = "MiniCargoPort"
            addChild(miniNode)
        }
    }
    
    // MARK: Logika dla ładunków
    
    private func addCargo(_ cargo: Cargo) {
        cargoBuffer.append(cargo) // ta tablica to źródło prawdy
        cargo.removeFromParent() // w updatePortCargoDisplay() dodamy je do rodzica
        cargo.isHidden = true // potem wyrenderujemy jego grafikę
        
        updatePortCargoDisplay()
        checkOverload()
    }
    
    func produceRandomCargo() {
        let possibleTypes = CargoType.allCases.filter { $0 != self.portType }
        let randomType = possibleTypes.randomElement()!
        let cargo = cargoFactory.createCargo(type: randomType)
        
        addCargo(cargo)
    }
    
    // Tą funkcją Ship zabiera tyle Cargo na ile ma miejsca
    func removeCargo(type: CargoType, maxCount: Int) -> [Cargo] {
        var taken: [Cargo] = []
        
        var i = 0
        while i < cargoBuffer.count && taken.count < maxCount {
            if cargoBuffer[i].cargoType != portType {
                taken.append(cargoBuffer.remove(at: i))
            } else {
                i += 1
            }
        }
        
        updatePortCargoDisplay()
        checkOverload()
        return taken
    }
    
    func unloadCargo(ship: Ship) {
        let toUnload = ship.cargoBuffer.filter { $0.cargoType == portType }
        
        for cargo in toUnload {
            // Znajdujemy cargo we właściwej tablicy i je usuwamy
            if let idx = ship.cargoBuffer.firstIndex(of: cargo) {
                ship.cargoBuffer.remove(at: idx)
                cargo.removeFromParent()
                
                // +1 punkt
                increaseScore()
                flashPortCircleSuccess()
            }
        }
    }
    
    // MARK: Wskaźnik czasu
    
    private func checkOverload() {
        if cargoBuffer.count > maxBuffer {
            if !isOverloaded {
                isOverloaded = true
                Port.overloadCount += 1
                if Port.overloadCount == 1 { startGlobalAlarm() }
                
                createOverloadIndicator()
                startOverloadTimer()
            }
        } else {
            if isOverloaded {
                isOverloaded = false
                Port.overloadCount -= 1
                if Port.overloadCount == 0 { stopGlobalAlarm() }
            }
            stopOverloadTimer()
        }
    }
    
    private func startOverloadTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let tick = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.remainingTime -= 1.0
            self.updateOverloadIndicator()
            
            // Przekroczenie czasu i koniec gry
            if self.remainingTime <= 0 && self.cargoBuffer.count > self.maxBuffer { self.endGame() }
        }
        let sequence = SKAction.sequence([wait, tick])
        let repeatAction = SKAction.repeatForever(sequence)
        self.run(repeatAction, withKey: overloadActionKey)
    }
    
    private func createOverloadIndicator() {
        let radius: CGFloat = GameConfig.indicatorRadius
        let overloadIndicator = SKShapeNode(circleOfRadius: radius)
        overloadIndicator.strokeColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        overloadIndicator.lineWidth = 16
        overloadIndicator.zPosition = 1
        overloadIndicator.name = "OverloadIndicator"
        addChild(overloadIndicator)
        self.overloadIndicator = overloadIndicator
    }

    private func updateOverloadIndicator() {
        guard let overloadIndicator = overloadIndicator else { return }
        
        let progress = remainingTime / 30.0
        let endAngle = CGFloat.pi * 2 * progress - CGFloat.pi / 2
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: GameConfig.indicatorRadius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: false)
        overloadIndicator.path = path
    }

    private func removeOverloadIndicator() {
        overloadIndicator?.removeFromParent()
        overloadIndicator = nil
    }
    
    private func endGame() {
        stopOverloadTimer()
        if let circle = children.first(where: { $0 is SKShapeNode && $0.name == "PortCircle" }) as? SKShapeNode { circle.fillColor = .red }
        focusOnPort(self)
        
        let wait = SKAction.wait(forDuration: 4.0)
        let callGameOver = SKAction.run { [weak self] in
            self?.gameOver()
        }
        run(.sequence([wait, callGameOver]))
    }
    
    func stopOverloadTimer() {
        self.removeAction(forKey: overloadActionKey)
        removeOverloadIndicator()
        remainingTime = GameConfig.overloadTime
    }
    
    // MARK: - Alarm
    
    private func startGlobalAlarm() {
        let wait = SKAction.wait(forDuration: 1.0)
        let playSound = SKAction.run { AudioServicesPlaySystemSound(SystemSoundID(1151)) }
        let sequence = SKAction.sequence([wait, playSound])
        let repeatAction = SKAction.repeatForever(sequence)
        scene?.run(repeatAction, withKey: Port.alarmActionKey)
    }
    
    private func stopGlobalAlarm() { scene?.removeAction(forKey: Port.alarmActionKey) }
}
