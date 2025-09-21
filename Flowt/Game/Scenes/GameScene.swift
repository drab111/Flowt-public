//
//  GameScene.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SpriteKit

class GameScene: SKScene {
    let gameVM: GameViewModel
    let cargoFactory: CargoFactory
    let upgradeFactory: UpgradeFactory
    let scoreLabel = ScoreLabel(position: CGPoint(x: 22, y: UIScreen.main.bounds.height - 30))
    
    var ports: [Port] = []
    var routeLines: [RouteLine] = []
    var currentLineIndex: Int = 0
    var currentLine: RouteLine { routeLines[currentLineIndex] }
    var isDrawing: Bool = false
    var colorButtons: [SKShapeNode] = []
    var score: Int = 0 { didSet { scoreLabel.score = score } }
    var storm: Storm?
    var islands: [Island] = []
    var activePopup: SKNode?
    var pendingUpgrade: LineUpgrade?
    var backToMenuButton: SKLabelNode?
    var colors: [UIColor] = [UIColor.red.withAlphaComponent(0.7), UIColor.magenta.withAlphaComponent(0.7)]
    var cargoSpawnInterval: Double = GameConfig.spawnCargoInterval {
        didSet { resetCargoSpawnTimer() }
    }
    
    // Timery:
    var spawnPortTimer: Timer?
    var spawnCargoTimer: Timer?
    var spawnStormTimer: Timer?
    var upgradeTimer: Timer?
    
    init(gameVM: GameViewModel, cargoFactory: CargoFactory, upgradeFactory: UpgradeFactory) {
        self.gameVM = gameVM
        self.cargoFactory = cargoFactory
        self.upgradeFactory = upgradeFactory
        
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    override func didMove(to view: SKView) {
        let ocean = OceanBackground(size: size)
        addChild(ocean)
        setupUI()
        setupRouteLines()
        setupIslands()
        setupInitialPorts()
        setupTimers()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        invalidateTimers()
    }
}
