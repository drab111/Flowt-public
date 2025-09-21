//
//  GameConfig.swift
//  Flowt
//
//  Created by Wiktor Drab on 20/09/2025.
//

import SpriteKit

enum GameConfig {
    // Interwały czasu
    static let spawnPortInterval: TimeInterval = 30.0
    static let spawnCargoInterval: TimeInterval = 2.5 // Tylko początkowo
    static let spawnStormInterval: TimeInterval = 60.0
    static let upgradePopupInterval: TimeInterval = 90.0
    
    // Logika rozgrywki
    static let portConnectionTolerance: CGFloat = 30
    static let portMarginX: CGFloat = 25
    static let portMarginY: CGFloat = 50
    static let portBottomMargin: CGFloat = 80
    static let stormMargin: CGFloat = 50
    static let stormRadius: CGFloat = 100
    static let maxPortAttempts = 100
    
    // Spawnowanie
    static let minDistanceToPort: CGFloat = 50
    static let minDistanceToIsland: CGFloat = 52
    static let minDistanceToButton: CGFloat = 45
    
    // Cargo
    static let cargoSize = CGSize(width: 15, height: 15)
    
    // Port
    static let portMaxBuffer = 5
    static let overloadTime: CGFloat = 30
    static let indicatorRadius: CGFloat = 25
    static let portSize = CGSize(width: 20, height: 20)
    
    // Ship
    static let shipSpeed: CGFloat = 30
    static let portSpeed: CGFloat = 20
    static let stormSlowdown: CGFloat = 0.5
    static let portDetectionRadius: CGFloat = 15
    static let shipSize = CGSize(width: 30, height: 20)
    
    // Nagrody
    static let milestoneRewards: [Int: UIColor] = [
        20: .orange.withAlphaComponent(0.7),
        150: .green.withAlphaComponent(0.7),
        500: .blue.withAlphaComponent(0.7)
    ]
}
