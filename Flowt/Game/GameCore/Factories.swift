//
//  Factories.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

// MARK: Ulepszenia
protocol UpgradeFactory {
    func createUpgrade(option: UpgradeOption) -> LineUpgrade
}

class SimpleUpgradeFactory: UpgradeFactory {
    func createUpgrade(option: UpgradeOption) -> LineUpgrade {
        switch option {
        case .addShip:
            return AddShipUpgrade()
        case .speedBoost:
            return SpeedUpgrade()
        case .capacityBoost:
            return CapacityUpgrade()
        }
    }
}

// MARK: Ładunki
protocol CargoFactory {
    func createCargo(type: CargoType) -> Cargo
}

class SimpleCargoFactory: CargoFactory {
    func createCargo(type: CargoType) -> Cargo {
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

// TODO: Fabryka tworząca Cargo w trybie ciemnym
