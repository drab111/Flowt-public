//
//  Cargo.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Cargo: SKSpriteNode {
    let cargoType: CargoType
    
    init(cargoType: CargoType) {
        self.cargoType = cargoType
        let texture = SKTexture(imageNamed: cargoType.symbol)
        super.init(texture: texture, color: .clear, size: CGSize(width: 15, height: 15))
        
        //self.color = .black
        //self.colorBlendFactor = 0.0 // 100% tekstura, 0% kolor (brak mieszania)
        self.zPosition = 2
        self.name = "Cargo"
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
}

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
}
