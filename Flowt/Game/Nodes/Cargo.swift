//
//  Cargo.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Cargo: SKSpriteNode {
    let cargoType: CargoType
    
    init(cargoType: CargoType, useLightTexture: Bool) {
        self.cargoType = cargoType
        let textureName = useLightTexture ? cargoType.lightSymbol : cargoType.symbol
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: GameConfig.cargoSize)
        
        self.zPosition = 2
        self.name = "Cargo"
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
}

// MARK: - Enum: CargoType
enum CargoType: CaseIterable {
    case oil, gas, food
    
    var symbol: String {
        switch self {
        case .oil:
            return "OilTexture"
        case .gas:
            return "GasTexture"
        case .food:
            return "FoodTexture"
        }
    }
    
    var lightSymbol: String {
        switch self {
        case .oil:
            return "OilLightTexture"
        case .gas:
            return "GasLightTexture"
        case .food:
            return "FoodLightTexture"
        }
    }
}
