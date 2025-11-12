//
//  DeterministicCargoFactory.swift
//  Flowt
//
//  Created by Wiktor Drab on 11/11/2025.
//

@testable import Flowt

class DeterministicCargoFactory: CargoFactory {
    let forcedType: CargoType
    init(forcedType: CargoType) { self.forcedType = forcedType }
    func createCargo(type: CargoType) -> Cargo { Cargo(cargoType: forcedType, useLightTexture: true) }
}
