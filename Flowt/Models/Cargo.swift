//
//  Cargo.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Cargo: SKSpriteNode {
    private let cargoType: CargoType
    
    init(cargoType: CargoType) {
        self.cargoType = cargoType
        let texture = SKTexture(imageNamed: cargoType.symbol)
        super.init(texture: texture, color: .clear, size: CGSize(width: 15, height: 15))
        
        self.color = .black
        self.colorBlendFactor = 0.0
        
        self.name = "Cargo"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

enum CargoType: CaseIterable {
    case oil, gas, food
    
    var symbol: String {
        switch self {
        case .oil:
            return "drop"
        case .gas:
            return "flame"
        case .food:
            return "leaf"
        }
    }
}

protocol CargoFactory {
    func createCargo(of type: CargoType, color: UIColor) -> Cargo
}

class SimpleCargoFactory: CargoFactory {
    func createCargo(of type: CargoType, color: UIColor) -> Cargo {
        let prefix = (color == .white) ? "white_" : ""
        switch type {
        case .food:
            return Cargo(cargoType: .food)
        case .oil:
            return Cargo(cargoType: .oil)
        case .gas:
            return Cargo(cargoType: .gas)
        }
    }
}
