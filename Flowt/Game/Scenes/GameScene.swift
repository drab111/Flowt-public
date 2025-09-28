//
//  GameScene.swift
//  Flowt
//
//  Created by Wiktor Drab on 16/09/2025.
//

import SpriteKit

class GameScene: SKScene {
    let gameVM: GameViewModel
    let scoreVM: ScoreViewModel
    let cargoFactory: CargoFactory
    let upgradeFactory: UpgradeFactory
    let scoreLabel = ScoreLabel(position: CGPoint(x: 22, y: UIScreen.main.bounds.height - 30))
    let cameraNode = SKCameraNode()
    
    var ports: [Port] = []
    var routeLines: [RouteLine] = []
    var currentLineIndex: Int = 0
    var currentLine: RouteLine { routeLines[currentLineIndex] }
    var isDrawing: Bool = false
    var colorButtons: [SKShapeNode] = []
    var score: Int = 0 { didSet { scoreLabel.score = score } }
    var storm: Storm?
    var ocean: Ocean?
    var islands: [Island] = []
    var activePopup: SKNode?
    var pendingUpgrade: LineUpgrade?
    var backToMenuButton: SKLabelNode?
    var colors: [UIColor] = Array(GameConfig.routeColors.prefix(2))
    var cargoSpawnInterval: Double = GameConfig.spawnCargoInterval {
        didSet { resetCargoSpawnTimer() }
    }
    
    // Timery:
    enum TimerKeys {
        static let spawnPort = "SpawnPortAction"
        static let spawnCargo = "SpawnCargoAction"
        static let spawnStorm = "SpawnStormAction"
        static let upgrade = "UpgradeAction"
    }
    
    init(gameVM: GameViewModel, scoreVM: ScoreViewModel, cargoFactory: CargoFactory, upgradeFactory: UpgradeFactory) {
        self.gameVM = gameVM
        self.scoreVM = scoreVM
        self.cargoFactory = cargoFactory
        self.upgradeFactory = upgradeFactory
        
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    override func didMove(to view: SKView) {
        scoreVM.reset()
        setupBackground()
        setupButtons()
        setupCamera()
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
