//
//  LineUpgrade.swift
//  Flowt
//
//  Created by Wiktor Drab on 18/09/2025.
//

protocol LineUpgrade {
    func apply(line: RouteLine)
}

class AddShipUpgrade: LineUpgrade {
    func apply(line: RouteLine) {
        guard !line.permanentPoints.isEmpty else { return }
        let newShip = Ship(position: line.permanentPoints[0], parentLine: line, isInStormZone: line.isInStormZone, getPorts: line.getPorts)
        line.ships.append(newShip)
        line.addChild(newShip)
        newShip.setMovementContext(ShipMovementContext(ship: newShip, strategy: BackAndForthMovementStrategy()))
        newShip.startNextSegment() // TODO: to niech będzie odpalane w init contextu
    }
}

class SpeedUpgrade: LineUpgrade {
    func apply(line: RouteLine) {
        for ship in line.ships { ship.speedBoost *= 1.25 }
    }
}

class CapacityUpgrade: LineUpgrade {
    func apply(line: RouteLine) {
        for ship in line.ships { ship.maxCapacity += 1 }
    }
}

enum UpgradeOption: CaseIterable {
    case addShip, speedBoost, capacityBoost
    
    var title: String {
        switch self {
        case .addShip: return "New Ship"
        case .speedBoost: return "+25% Speed"
        case .capacityBoost: return "+1 Capacity"
        }
    }
}
