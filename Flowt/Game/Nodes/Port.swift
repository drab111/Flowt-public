//
//  Port.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import AudioToolbox
import SpriteKit

class Port: SKSpriteNode {
    private var cargoFactory: CargoFactory
    private var cargoBuffer: [Cargo] = []
    private let maxBuffer = GameConfig.portMaxBuffer
    private var remainingTime: CGFloat = GameConfig.overloadTime
    private var overloadTimer: Timer?
    private var isOverloaded = false
    private var overloadIndicator: SKShapeNode?
    private var increaseScore: (() -> Void)
    private var gameOver: (() -> Void)
    var portType: CargoType
    var isOccupied = false
    
    init(position: CGPoint, portType: CargoType, factory: CargoFactory, increaseScore: @escaping (() -> Void), gameOver: @escaping (() -> Void)) {
        self.portType = portType
        self.cargoFactory = factory
        self.increaseScore = increaseScore
        self.gameOver = gameOver
        let texture = SKTexture(imageNamed: portType.symbol)
        super.init(texture: texture, color: .white, size: GameConfig.portSize)

        self.position = position
        self.zPosition = 2
        self.name = "Port"

        // Otoczka portu
        let border = SKShapeNode(circleOfRadius: 16)
        border.strokeColor = .white
        border.lineWidth = 2
        border.zPosition = 2
        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: Logika generowania i wymiany ładunków pomiędzy portem a statkami
    
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
            let miniNode = SKSpriteNode(texture: cargo.texture, color: cargo.color, size: CGSize(width: 10, height: 10))
            miniNode.colorBlendFactor = cargo.colorBlendFactor
            miniNode.position = CGPoint(x: dx, y: dy)
            miniNode.zPosition = 3
            miniNode.name = "MiniCargoPort"
            addChild(miniNode)
        }
    }
    
    func produceRandomCargo() {
        let possibleTypes = CargoType.allCases.filter { $0 != self.portType }
        let randomType = possibleTypes.randomElement()!
        let cargo = cargoFactory.createCargo(type: randomType)
        
        addCargo(cargo)
    }
    
    private func addCargo(_ cargo: Cargo) {
        cargoBuffer.append(cargo) // ta tablica to źródło prawdy
        cargo.removeFromParent() // w updatePortCargoDisplay() dodamy je do rodzica
        cargo.isHidden = true // potem wyrenderujemy jego grafikę
        
        updatePortCargoDisplay()
        checkOverload()
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
            }
        }
    }
    
    // MARK: Logika dla wskaźnika czasu
    private func checkOverload() {
        if cargoBuffer.count > maxBuffer {
            if !isOverloaded {
                isOverloaded = true
                AudioServicesPlaySystemSound(1005) // TODO: zmienić dźwięk
                createOverloadIndicator()
                startOverloadTimer()
            }
        } else {
            isOverloaded = false
            stopOverloadTimer()
        }
    }
    
    private func startOverloadTimer() {
        overloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }  // sprawdzamy czy self już nie został zwolniony z pamięci i nie istnieje
            remainingTime -= 1.0
            updateOverloadIndicator()
            
            // Przekroczenie czasu i koniec gry
            if remainingTime <= 0 && cargoBuffer.count > maxBuffer {
                stopOverloadTimer()
                gameOver()
            }
        }
    }
    
    private func stopOverloadTimer() {
        overloadTimer?.invalidate()
        overloadTimer = nil
        removeOverloadIndicator()
        remainingTime = GameConfig.overloadTime
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
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // TODO: Zmienić wibracje urządzenia na coś innego
    }

    private func removeOverloadIndicator() {
        overloadIndicator?.removeFromParent()
        overloadIndicator = nil
    }
}
