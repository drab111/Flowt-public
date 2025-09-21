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
    func createCargo(type: CargoType) -> Cargo { Cargo(cargoType: type) }
}

// TODO: Fabryka tworząca Cargo w trybie ciemnym
