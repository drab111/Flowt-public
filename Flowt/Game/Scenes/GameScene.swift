//
//  GameScene.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import AudioToolbox
import SpriteKit

class GameScene: SKScene {
    private let gameVM: GameViewModel
    
    private var ports: [Port] = []
    private var routeLines: [RouteLine] = []
    private var currentLineIndex: Int = 0
    private var currentLine: RouteLine { routeLines[currentLineIndex] }
    private var isDrawing: Bool = false
    private var colorButtons: [SKShapeNode] = []
    private let cargoFactory: CargoFactory
    private let upgradeFactory: UpgradeFactory
    private var score: Int = 0 { didSet { scoreLabel.score = score } }
    private let scoreLabel = ScoreLabel(position: CGPoint(x: 22, y: UIScreen.main.bounds.height - 30))
    private var storm: Storm?
    private var islands: [Island] = []
    private var activePopup: SKNode? // Jeśli != nil to obsługujemy tylko popup
    private var pendingUpgrade: LineUpgrade? // Co wybrano w pierwszym popupie
    private var backToMenuButton: SKLabelNode?
    private var colors: [UIColor] = [ UIColor.red.withAlphaComponent(0.7), UIColor.magenta.withAlphaComponent(0.7) ]
    
    // Timery:
    private var spawnPortTimer: Timer?
    private var spawnCargoTimer: Timer?
    private var stormTimer: Timer?
    private var upgradeTimer: Timer?
    
    private var cargoSpawnInterval: Double = 2.5 {
        didSet {
            // Unieważniamy poprzedni timer i tworzymy nowy
            spawnCargoTimer?.invalidate()
            spawnCargoTimer = Timer.scheduledTimer(withTimeInterval: cargoSpawnInterval, repeats: true) { [weak self] _ in
                self?.spawnRandomCargo()
            }
        }
    }
    
    init(gameVM: GameViewModel, cargoFactory: CargoFactory, upgradeFactory: UpgradeFactory) {
        self.gameVM = gameVM
        self.cargoFactory = cargoFactory
        self.upgradeFactory = upgradeFactory
        
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    override func didMove(to view: SKView) {
        backgroundColor = .blue
        addChild(scoreLabel)
        
        // Linie
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
        
        // 4 wyspy
        addIsland(position: CGPoint(x: size.width*0.75, y: size.height*0.75), radius: 40, picture: "island_picture")
        addIsland(position: CGPoint(x: size.width*0.4, y: size.height*0.55), radius: 50, picture: "island_picture2")
        addIsland(position: CGPoint(x: size.width*0.3, y: size.height*0.25), radius: 45, picture: "island_picture3")
        addIsland(position: CGPoint(x: size.width*0.67, y: size.height*0.41), radius: 50, picture: "island_picture4")
        
        createBackToMenuButton()
        createColorButtons()
        
        // Porty startowe każdego typu
        for type in CargoType.allCases { spawnRandomPort(portType: type) }
        
        // Co 30s nowy port
        spawnPortTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.spawnRandomPort(portType: CargoType.allCases.randomElement()!)
        }
        // Losowe cargo co 2.5s na początku
        spawnCargoTimer = Timer.scheduledTimer(withTimeInterval: cargoSpawnInterval, repeats: true) { [weak self] _ in
            self?.spawnRandomCargo()
        }
        // Co 60s nowa burza
        stormTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.spawnStorm()
        }
        // Po 90 sekundach pojawia się UpgradePopup
        upgradeTimer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: true) { [weak self] _ in
            self?.showUpgradePopup()
        }
    }
    
    private func addIsland(position: CGPoint, radius: CGFloat, picture: String) {
        let island = Island(position: position, radius: radius, picture: picture)
        addChild(island)
        islands.append(island)
    }
    
    private func createBackToMenuButton() {
        backToMenuButton = SKLabelNode(text: "Menu")
        if let button = backToMenuButton {
            button.fontName = "HelveticaNeue-Bold"
            button.fontSize = 24
            button.fontColor = .white
            button.position = CGPoint(x: 50, y: 50)
            button.name = "BackToMenuButton"
            addChild(button)
        }
    }
    
    private func createColorButtons() {
        for button in colorButtons { button.removeFromParent() }
        colorButtons.removeAll()
        
        for i in 0..<colors.count {
            let circle = SKShapeNode(circleOfRadius: 20)
            circle.fillColor = colors[i]
            circle.strokeColor = .black
            circle.lineWidth = 2
            circle.zPosition = 5
            circle.position = CGPoint(x: size.width - 40, y: size.height - CGFloat(40 + i*50))
            circle.name = "colorButton\(i)"
            addChild(circle)
            colorButtons.append(circle)
            
            let texture = SKTexture(imageNamed: "SignTexture") // TODO: Wymień na własny symbol
            let imageNode = SKSpriteNode(texture: texture)
            imageNode.size = CGSize(width: 35, height: 35)
            imageNode.position = CGPoint(x: 0, y: 0)
            imageNode.zPosition = 6
            circle.addChild(imageNode)
            
            if i == currentLineIndex {
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
                let pulse = SKAction.sequence([scaleUp, scaleDown])
                let repeatPulse = SKAction.repeatForever(pulse)
                circle.run(repeatPulse)
                
                circle.strokeColor = .yellow
                circle.lineWidth = 4
            }
        }
    }
    
    private func gameOver() {
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
    
    private func addPort(position: CGPoint, type: CargoType) {
        let port = Port(position: position, portType: type, factory: cargoFactory, increaseScore: { [weak self] in
                self?.increaseScore()
            },
            gameOver: { [weak self] in
                self?.gameOver()
            })
        
        addChild(port)
        ports.append(port)
    }
    
    private func addExtraLine(lineColor: UIColor, buttonColor: UIColor) {
        //self.run(SKAction.playSoundFileNamed("newLineSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
        
        let notificationCircle = SKShapeNode(circleOfRadius: 120)
        notificationCircle.fillColor = buttonColor
        notificationCircle.strokeColor = .black
        notificationCircle.lineWidth = 2
        notificationCircle.zPosition = 4
        notificationCircle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        notificationCircle.name = "\(lineColor)LineNotification"
        
        let texture = SKTexture(imageNamed: "SignTexture") // TODO: Zmień
        let imageNode = SKSpriteNode(texture: texture)
        imageNode.size = CGSize(width: 210, height: 210)
        imageNode.position = CGPoint(x: 0, y: 0)
        imageNode.zPosition = 5
        notificationCircle.addChild(imageNode)
        addChild(notificationCircle)
        
        let targetPosition = CGPoint(x: size.width - 40, y: size.height - CGFloat(40 + (routeLines.count * 50)))
        
        let delay = SKAction.wait(forDuration: 1.0)
        let scaleAction = SKAction.scale(to: 0.2, duration: 1.0)
        let moveAction = SKAction.move(to: targetPosition, duration: 1.0)
        let groupAction = SKAction.group([scaleAction, moveAction])
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([delay, groupAction, removeAction])
        
        notificationCircle.run(sequence) {
            self.colors.append(buttonColor)
            let newLine = RouteLine(lineColor: lineColor, checkIslandCollision: { [weak self] point in
                self?.checkIslandCollision(point) ?? false
            },
            isInStormZone: { [weak self] point in
                self?.isInStormZone(point) ?? false
            },
            getPorts: { [weak self] in
                self?.ports ?? []
            })
            self.routeLines.append(newLine)
            self.addChild(newLine)
            self.createColorButtons()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Sprawdzamy czy jest widoczne okienko UpgradePopup lub LineSelectionPopup
        if let popup = activePopup, ((popup as? Popup) != nil) {
            (popup as! Popup).handleTouch(location)
            return
        }
        
        let nodesHere = nodes(at: location)
        for node in nodesHere {
            // Sprawdzamy czy kliknięto w "MENU"
            if node.name == "BackToMenuButton" {
                //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
                gameVM.endGame()
                return
            }
        }
        
        // Czy kliknięto w przycisk (rzutujemy na SKShapeNode aby działał first)
        if let tappedButton = nodes(at: location).compactMap({ $0 as? SKShapeNode }).first {
            if let index = colorButtons.firstIndex(of: tappedButton) {
                //self.run(SKAction.playSoundFileNamed("lineSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
                currentLineIndex = index
                createColorButtons()
                isDrawing = false
            }
        }
        
        if currentLine.isLoop {
            isDrawing = false
            return
        }
        
        if currentLine.permanentPoints.isEmpty {
            isDrawing = true
            currentLine.startNewLine(from: location)
        } else {
            // Sprawdzamy dystans do first i last
            let firstP = currentLine.permanentPoints.first!
            let lastP = currentLine.permanentPoints.last!
            
            let distToFirst = hypot(location.x - firstP.x, location.y - firstP.y)
            let distToLast  = hypot(location.x - lastP.x,  location.y - lastP.y)
            
            // Ustalamy czy bliżej do first czy do last
            if distToFirst < 30 {
                // Rysujemy "od początku"
                isDrawing = true
                // Ale w tym wypadku zapamiętamy że dodajemy na początek
                currentLine.isAppendingAtFront = true
                currentLine.startNewLine(from: firstP)
            } else if distToLast < 30 {
                // normalne rysowanie
                isDrawing = true
                currentLine.isAppendingAtFront = false
                currentLine.startNewLine(from: lastP)
            } else { isDrawing = false }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        currentLine.addPoint(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing, let touch = touches.first else { return }
        isDrawing = false
        
        currentLine.addPoint(touch.location(in: self))
        
        let pathPoints = currentLine.currentPoints
        if let (startPort, endPort) = checkConnectionForSegment(points: pathPoints, line: currentLine) {
            currentLine.finalizeCurrentLine()
            currentLine.existingConnections.append((startPort, endPort))
            //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
            
            if currentLine.permanentPoints.count >= 3 {
                let firstPoint = currentLine.permanentPoints[0]
                let lastPoint  = currentLine.permanentPoints.last!
                let distance = hypot(firstPoint.x - lastPoint.x, firstPoint.y - lastPoint.y)
                if distance < 30 {
                    currentLine.isLoop = true
                    currentLine.updatePath()
                }
            }
        } else {
            currentLine.currentPoints.removeAll()
            currentLine.updatePath()
        }
    }
    
    private func checkConnectionForSegment(points: [CGPoint], line: RouteLine) -> (Port, Port)? {
        guard let start = points.first, let end = points.last else { return nil }
        
        let startPort = ports.first(where: { isPoint(start, nearPort: $0) })
        let endPort   = ports.first(where: { isPoint(end, nearPort: $0) })
        
        guard let startPort = startPort, let endPort = endPort, startPort != endPort else { return nil }
        if line.existingConnections.contains(where: { $0 == (startPort, endPort) || $0 == (endPort, startPort) }) { return nil }
        
        return (startPort, endPort)
    }
    
    private func isPoint(_ point: CGPoint, nearPort port: Port) -> Bool {
        let distance = hypot(point.x - port.position.x, point.y - port.position.y)
        let portRadius = port.size.width / 2 + 5
        return distance <= portRadius
    }
    
    private func showUpgradePopup() {
        // Nie pokazujemy jeśli już mamy popup
        guard activePopup == nil else { return }
        
        let popup = UpgradePopup(position: CGPoint(x: size.width / 2, y: size.height / 2)) { [weak self] option in
            guard let self = self else { return }
            //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
            self.pendingUpgrade = upgradeFactory.createUpgrade(option: option)
            
            // Zamykamy popup 1
            self.activePopup = nil
            
            // Teraz otwieramy popup 2 - wybór linii
            self.showLineSelectionPopup()
        }
        
        addChild(popup)
        activePopup = popup
    }
    
    private func showLineSelectionPopup() {
        guard activePopup == nil else { return }
        
        let linePopup = LineSelectionPopup(position: CGPoint(x: size.width / 2, y: size.height / 2), amountOfLines: routeLines.count) { [weak self] index in
            guard let self = self else { return }
            //self.run(SKAction.playSoundFileNamed("clickSound.wav", waitForCompletion: false)) // TODO: dodaj ścieżkę dźwiękową
            
            if let upgrade = self.pendingUpgrade {
                // Aplikujemy do odpowiedniej linii
                let line = self.routeLines[index]
                upgrade.apply(line: line)
                self.pendingUpgrade = nil
            }
            
            self.activePopup = nil
        }
        
        addChild(linePopup)
        activePopup = linePopup
    }
    
    private func spawnRandomPort(portType: CargoType) {
        for _ in 0..<100 {
            let randomX = CGFloat.random(in: 25...(size.width-25))
            let randomY = CGFloat.random(in: 50...(size.height-80))
            let candidatePos = CGPoint(x: randomX, y: randomY)
            
            if !isTooCloseToAnyPort(candidatePos, minDistance: 50.0) && !isTooCLoseToAnyIsland(candidatePos, minDistance: 52.0)
                && !isTooCLoseToAnyButton(candidatePos, minDistance: 45) {
                addPort(position: candidatePos, type: portType)
                return
            }
        }
    }
    
    private func isTooCloseToAnyPort(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        for port in ports {
            let dist = hypot(port.position.x - pos.x, port.position.y - pos.y)
            if dist < minDistance { return true }
        }
        return false
    }
    
    private func isTooCLoseToAnyIsland(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        for island in islands {
            let dist = hypot(island.position.x - pos.x, island.position.y - pos.y)
            if dist < minDistance { return true }
        }
        return false
    }
    
    private func isTooCLoseToAnyButton(_ pos: CGPoint, minDistance: CGFloat) -> Bool {
        // Wszystkie możliwe przyciski linii które są i mogą się pojawić
        let buttonPosition = [
            CGPoint(x: size.width - 40, y: size.height - CGFloat(40)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(90)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(140)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(190)),
            CGPoint(x: size.width - 40, y: size.height - CGFloat(240)),
        ]
        
        for button in buttonPosition {
            let dist = hypot(button.x - pos.x, button.y - pos.y)
            if dist < minDistance { return true }
        }
        
        // Dla backToMenuButton i ScoreLabel
        if let button = backToMenuButton {
            let distToButton = hypot(button.position.x - pos.x, button.position.y - pos.y)
            if distToButton < minDistance { return true }
        }
        let distToLabel = hypot(scoreLabel.position.x + 20.0 - pos.x, scoreLabel.position.y - pos.y)
        if distToLabel < minDistance + 30.0 { return true }
        return false
    }
    
    private func spawnRandomCargo() {
        guard !ports.isEmpty else { return }
        ports.randomElement()!.produceRandomCargo()
    }
    
    private func spawnStorm() {
        // Usuwamy starą burzę
        storm?.removeFromParent()
        storm = nil
        
        // Losujemy obszar dla nowej
        let randomX = CGFloat.random(in: 50...(size.width-50))
        let randomY = CGFloat.random(in: 50...(size.height-50))
        let position = CGPoint(x: randomX, y: randomY)
        let radius: CGFloat = 100.0
        
        let stormNode = Storm(position: position, radius: radius)
        addChild(stormNode)
        storm = stormNode
    }
    
    private func isInStormZone(_ point: CGPoint) -> Bool {
        guard let storm = storm else { return false }
        return storm.contains(point)
    }
    
    private func checkIslandCollision(_ point: CGPoint) -> Bool {
        for island in islands {
            if island.contains(point: point) { return true }
        }
        return false
    }
    
    private func increaseScore() {
        func cargoInterval(score: Int) -> TimeInterval {
            let maxScore: Double = 500
            let start: Double = 2.0
            let end: Double = 0.05

            let t = min(Double(score) / maxScore, 1.0)
            return start + (end - start) * t
        }
        
        score += 1

        // nagrody za milestone’y
        switch score {
        case 20:
            addExtraLine(lineColor: .orange.withAlphaComponent(0.7), buttonColor: .orange.withAlphaComponent(0.7))
        case 150:
            addExtraLine(lineColor: .green.withAlphaComponent(0.7), buttonColor: .green.withAlphaComponent(0.7))
        case 500:
            addExtraLine(lineColor: .blue.withAlphaComponent(0.7), buttonColor: .blue.withAlphaComponent(0.7))
        default: break
        }

        cargoSpawnInterval = cargoInterval(score: score)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        spawnPortTimer?.invalidate()
        spawnPortTimer = nil
        spawnCargoTimer?.invalidate()
        spawnCargoTimer = nil
        stormTimer?.invalidate()
        stormTimer = nil
        upgradeTimer?.invalidate()
        upgradeTimer = nil
    }
}
