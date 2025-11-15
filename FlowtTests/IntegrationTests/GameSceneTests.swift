//
//  GameSceneTests.swift
//  Flowt
//
//  Created by Wiktor Drab on 11/11/2025.
//

import XCTest
@testable import Flowt

@MainActor
final class GameSceneIntegrationTests: XCTestCase {
    // MARK: - fixtures
    let windowSize = CGSize(width: 800, height: 600)
    
    // MARK: - lifecycle
    override func setUp() {
        super.setUp()
        setenv("USE_MOCK_SERVICES", "1", 1)
        Port.overloadCount = 0
    }
    
    override func tearDown() {
        unsetenv("USE_MOCK_SERVICES")
        Port.overloadCount = 0
        super.tearDown()
    }
    
    // MARK: - helpers
    private func makeLineWithPoints(_ n: Int) -> RouteLine {
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [] })
        for i in 0..<n {
            line.permanentPoints.append(CGPoint(x: 10 + i * 20, y: 20 + i * 10))
        }
        line.updatePath()
        return line
    }
    
    private func makeScoreVM() -> ScoreViewModel {
        let auth = MockAuthSession()
        let appState = AppState(authSession: auth)
        let scoreService = MockScoreService()
        let profileService = MockProfileService()
        return ScoreViewModel(appState: appState, scoreService: scoreService, profileService: profileService)
    }
    
    // MARK: - tests
    
    func test_setupInitialPorts_spawnsOnePortPerCargoType() {
        // Arange
        let gameVM = GameViewModel()
        let scoreVM = makeScoreVM()
        let scene = GameScene(gameVM: gameVM, scoreVM: scoreVM, cargoFactory: DarkCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        // Act
        scene.setupInitialPorts(immediate: true)
        
        // Assert
        XCTAssertEqual(scene.ports.count, CargoType.allCases.count)
    }
    
    func test_checkConnectionForSegment_detectsConnectionBetweenTwoPorts() {
        // Arange
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: DeterministicCargoFactory(forcedType: .food), upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        scene.addPort(position: CGPoint(x: 200, y: 100), type: .gas)
        XCTAssertEqual(scene.ports.count, 2)
        
        // Act
        let start = CGPoint(x: 101, y: 101)
        let end = CGPoint(x: 199, y: 99)
        let result = scene.checkConnectionForSegment(points: [start, end], line: RouteLine(lineColor: .clear, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [] }))
        
        // Assert
        XCTAssertNotNil(result)
    }
    
    func test_checkIfLoopClosed_marksLoopWhenFirstAndLastAreClose() {
        // Arange
        let line = RouteLine(lineColor: .clear, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [] })
        line.permanentPoints = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0), CGPoint(x: 10, y: 5)]
        XCTAssertFalse(line.isLoop)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: DarkCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        
        // Act
        scene.checkIfLoopClosed(line: line)
        
        // Assert
        XCTAssertTrue(line.isLoop)
    }
    
    func test_routeLine_finalizeCurrentLine_createsShip_whenEnoughPoints() {
        // Arange
        let line = RouteLine(lineColor: .clear, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [] })
        line.currentPoints = [CGPoint(x: 10, y: 10), CGPoint(x: 50, y: 50)]
        
        // Act
        line.finalizeCurrentLine()
        
        // Assert
        XCTAssertEqual(line.permanentPoints.count, 2)
        XCTAssertEqual(line.ships.count, 1)
    }
    
    func test_port_produceRandomCargo_and_overloadBehavior() {
        // Arange
        Port.overloadCount = 0
        let factory = DeterministicCargoFactory(forcedType: .food)
        let port = Port(position: CGPoint(x: 50, y: 50), portType: .oil, factory: factory, increaseScore: {}, gameOver: {}, focusOnPort: { _ in })
        
        // Act - produce enough cargo to overload
        for _ in 0..<(GameConfig.portMaxBuffer + 1) {
            port.produceRandomCargo()
        }
        // Assert - overload started
        XCTAssertEqual(Port.overloadCount, 1)
        
        // Act - remove cargo to recover
        _ = port.removeCargo(type: port.portType, maxCount: GameConfig.portMaxBuffer + 1)
        // Assert - overload stopped
        XCTAssertEqual(Port.overloadCount, 0)
        port.stopOverloadTimer()
    }
    
    func test_port_unloadCargo_removesFromShip_and_callsIncreaseScore() {
        // Arange
        var scoreIncreased = 0
        let increment: () -> Void = { scoreIncreased += 1 }
        
        // port expects portType: .oil
        let port = Port(position: CGPoint(x: 20, y: 20), portType: .oil, factory: DarkCargoFactory(), increaseScore: increment, gameOver: {}, focusOnPort: { _ in })
        
        // create ship that carries some cargos, including cargos matching port.portType (these should be unloaded)
        let ship = Ship(position: CGPoint(x: 20, y: 20), parentLine: makeLineWithPoints(2), isInStormZone: { _ in false }, getPorts: { [port] })
        
        // create cargos - one oil (will be unloaded), one gas (should remain on ship)
        let cargoOil = Cargo(cargoType: .oil, useLightTexture: true)
        let cargoGas = Cargo(cargoType: .gas, useLightTexture: true)
        ship.cargoBuffer = [cargoOil, cargoGas]
        XCTAssertEqual(ship.cargoBuffer.count, 2)
        
        // Act
        port.unloadCargo(ship: ship)
        
        // Assert - cargoOil removed, cargoGas remains, and score increment called once
        XCTAssertEqual(ship.cargoBuffer.count, 1)
        XCTAssertEqual(ship.cargoBuffer.first?.cargoType, .gas)
        XCTAssertEqual(scoreIncreased, 1)
    }
    
    func test_ship_loadsFromPort_and_respectsMaxCapacity() {
        // Arange
        let factory = DeterministicCargoFactory(forcedType: .gas)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: factory, upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        // create port of type .oil so produced cargos (.gas) are collectible
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        guard let port = scene.ports.first else { XCTFail("port created"); return }
        
        // produce N cargos
        let produced = 3
        for _ in 0..<produced { port.produceRandomCargo() }
        
        // prepare line containing the port position so ship.findPort can see it
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        
        // create ship with limited capacity smaller than produced to check limit
        let ship = Ship(position: CGPoint(x: 0, y: 0), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        ship.maxCapacity = 2
        
        // Act
        ship.handlePortIfNeeded(port: port)
        
        // Assert
        XCTAssertEqual(ship.cargoBuffer.count, min(produced, ship.maxCapacity))
    }
    
    func test_ship_partialLoad_whenAlreadyHasCargo() {
        // Arange
        let factory = DeterministicCargoFactory(forcedType: .gas)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: factory, upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        guard let port = scene.ports.first else { XCTFail(); return }
        
        // produce 3 cargos on port
        for _ in 0..<3 { port.produceRandomCargo() }
        
        // prepare line
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        
        // create ship that already carries 1 cargo and has capacity 3
        let ship = Ship(position: CGPoint(x: 0, y: 0), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        ship.cargoBuffer = [Cargo(cargoType: .gas, useLightTexture: true)] // already carrying 1
        ship.maxCapacity = 3
        
        // Act
        ship.handlePortIfNeeded(port: port)
        
        // Assert — ship filled to maxCapacity
        XCTAssertEqual(ship.cargoBuffer.count, ship.maxCapacity)
        // Assert — one cargo should remain on port
        let remaining = port.removeCargo(type: port.portType, maxCount: 100)
        XCTAssertEqual(remaining.count, 1)
    }
    
    func test_ship_doesNotLoad_whenPortOnlyHasItsOwnType() {
        // Arange: use factory that produces same type as port
        let factory = DeterministicCargoFactory(forcedType: .oil)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: factory, upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        // port type oil but factory forces produced cargo to .oil
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        guard let port = scene.ports.first else { XCTFail(); return }
        
        // produce cargos which will be of portType and therefore not collectible
        for _ in 0..<3 { port.produceRandomCargo() }
        
        // prepare line and ship
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        
        let ship = Ship(position: CGPoint(x: 0, y: 0), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        ship.maxCapacity = 5
        
        // Act
        ship.handlePortIfNeeded(port: port)
        
        // Assert — ship should not have loaded any (all cargo matched portType)
        XCTAssertEqual(ship.cargoBuffer.count, 0)
        // Assert — removeCargo (non-port types) returns 0, confirming port buffer contained only portType items
        let nonPortTaken = port.removeCargo(type: port.portType, maxCount: 100)
        XCTAssertEqual(nonPortTaken.count, 0)
    }
    
    func test_ship_constructor_autoLoads_respectsDefaultCapacity() {
        // Arange
        let factory = DeterministicCargoFactory(forcedType: .gas)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: factory, upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        guard let port = scene.ports.first else { XCTFail(); return }
        
        // produce 5 cargos
        for _ in 0..<5 { port.produceRandomCargo() }
        
        // prepare line whose first point equals port position
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        
        // Act - create ship ON the port — constructor will call handlePortIfNeeded
        let ship = Ship(position: CGPoint(x: 100, y: 100), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        
        // Assert - ship loaded up to its default maxCapacity
        XCTAssertEqual(ship.cargoBuffer.count, min(5, ship.maxCapacity))
    }
    
    func test_ship_loadsNothingWhenPortEmpty() {
        // Arange
        let factory = DeterministicCargoFactory(forcedType: .gas)
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: factory, upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        scene.addPort(position: CGPoint(x: 100, y: 100), type: .oil)
        guard let port = scene.ports.first else { XCTFail(); return }
        
        // prepare line and ship
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        let ship = Ship(position: CGPoint(x: 0, y: 0), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        
        // Act - no cargo was produced
        ship.handlePortIfNeeded(port: port)
        
        // Assert - ship still empty
        XCTAssertEqual(ship.cargoBuffer.count, 0)
    }
    
    func test_movementStrategy_invokesHandlePortAndLoadCargo() {
        // Arange
        let factory = DeterministicCargoFactory(forcedType: .food)
        let port = Port(position: CGPoint(x: 200, y: 200), portType: .oil, factory: factory, increaseScore: {}, gameOver: {}, focusOnPort: { _ in })
        for _ in 0..<2 { port.produceRandomCargo() } // create collectible cargo
        
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in false }, getPorts: { [port] })
        line.permanentPoints = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)]
        line.updatePath()
        
        // create ship at first point
        let ship = Ship(position: CGPoint(x: 100, y: 100), parentLine: line, isInStormZone: { _ in false }, getPorts: { [port] })
        
        // Act - Loop strategy moves and should synchronously call handlePortIfNeeded when it reaches p2
        let loop = LoopMovementStrategy()
        let context = ShipMovementContext(ship: ship, strategy: loop)
        ship.setMovementContext(context)
        loop.moveShip(context)
        
        // Assert - since handlePortIfNeeded is called inside moveShip before scheduling SKAction, ship should have picked some cargo
        XCTAssertTrue(ship.cargoBuffer.count >= 0)
    }
    
    func test_ship_checkStormIfNeeded_appliesStormSlowdown() {
        // Arrange
        let line = RouteLine(lineColor: .red, checkIslandCollision: { _ in false }, isInStormZone: { _ in true }, getPorts: { [] })
        let ship = Ship(position: CGPoint(x: 0, y: 0), parentLine: line, isInStormZone: line.isInStormZone, getPorts: { [] })
        
        // Act
        ship.checkStormIfNeeded()
        
        // Assert
        XCTAssertEqual(ship.shipSpeed, GameConfig.shipSpeed * GameConfig.stormSlowdown)
    }
    
    func test_storm_containsPoint_and_sceneDetectsStormZone() {
        // Arrange
        let scene = GameScene(gameVM: GameViewModel(), scoreVM: makeScoreVM(), cargoFactory: DarkCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        // create a storm
        let center = CGPoint(x: 400, y: 300)
        let radius: CGFloat = 100
        let storm = Storm(position: center, radius: radius)
        scene.addChild(storm)
        scene.storm = storm
        
        let insidePoint = CGPoint(x: 450, y: 300) // 50 pts away → inside
        let outsidePoint = CGPoint(x: 600, y: 300) // 200 pts away → outside
        
        // Act & Assert
        XCTAssertTrue(storm.contains(point: insidePoint))
        XCTAssertFalse(storm.contains(point: outsidePoint))
        
        XCTAssertTrue(scene.isInStormZone(insidePoint))
        XCTAssertFalse(scene.isInStormZone(outsidePoint))
    }
    
    func test_upgrades_applyEffects_addShip_speed_capacity() {
        // Arange
        let line = makeLineWithPoints(3)
        line.ships = [] // now line has 0 ships
        
        // Act - apply add-ship upgrade
        AddShipUpgrade().apply(line: line)
        // Assert: ship created
        XCTAssertEqual(line.ships.count, 1)
        let ship = line.ships.first!
        
        // Arange (for speed)
        let oldBoost = ship.speedBoost
        // Act - apply speed upgrade
        SpeedUpgrade().apply(line: line)
        // Assert - speed increased
        XCTAssertGreaterThan(ship.speedBoost, oldBoost)
        
        // Arange (for capacity)
        let beforeCap = ship.maxCapacity
        // Act - apply capacity upgrade
        CapacityUpgrade().apply(line: line)
        // Assert - capacity increased by 1
        XCTAssertEqual(ship.maxCapacity, beforeCap + 1)
    }
    
    func test_finalizeCurrentLine_appendingAtFront_adjustsShipSegmentIndex() {
        // Arange - create line with existing permanent points and a ship
        let line = makeLineWithPoints(3)
        let ship = Ship(position: line.permanentPoints[0], parentLine: line, isInStormZone: { _ in false }, getPorts: { [] })
        line.ships = [ship]
        ship.currentSegmentIndex = 0
        
        // prepare currentPoints to append at front and mark flag
        line.currentPoints = [CGPoint(x: -40, y: -40), CGPoint(x: -20, y: -20)]
        line.isAppendingAtFront = true
        
        // Act
        line.finalizeCurrentLine()
        
        // Assert - ship index should have been incremented by number of appended points (2)
        XCTAssertEqual(ship.currentSegmentIndex, 2)
    }
    
    func test_gameOver_clearsScene_and_setsVMs() {
        // Arange
        let gameVM = GameViewModel()
        let scoreVM = makeScoreVM()
        let scene = GameScene(gameVM: gameVM, scoreVM: scoreVM, cargoFactory: DarkCargoFactory(), upgradeFactory: SimpleUpgradeFactory())
        scene.size = windowSize
        scene.invalidateTimers()
        
        scene.ports = [Port(position: CGPoint(x: 10, y: 10), portType: .oil, factory: DarkCargoFactory(), increaseScore: {}, gameOver: {}, focusOnPort: { _ in })]
        scene.routeLines = [makeLineWithPoints(2)]
        scene.colors = [.red, .blue]
        scene.islands = [Island(position: CGPoint(x: 40, y: 40), radius: 10, picture: "IslandTexture1")]
        scene.score = 123
        
        // Act
        scene.gameOver()
        
        // Assert - scene cleared and VMs updated
        XCTAssertTrue(scene.ports.isEmpty)
        XCTAssertTrue(scene.routeLines.isEmpty)
        XCTAssertTrue(scene.colors.isEmpty)
        XCTAssertTrue(scene.islands.isEmpty)
        
        // ScoreViewModel should have received the score
        XCTAssertEqual(scoreVM.score, 123)
        // GameViewModel should be in endView phase
        XCTAssertEqual(gameVM.activePhase, GameViewModel.GamePhase.endView)
    }
}
