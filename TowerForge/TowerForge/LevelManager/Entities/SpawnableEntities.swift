//
//  Entities.swift
//  TowerForge
//
//  Created by Zheng Ze on 21/3/24.
//

import Foundation

struct SpawnableEntities {
    static let possibleUnits: [(BaseUnit & Spawnable).Type] = [MeleeUnit.self,
                                                               SoldierUnit.self]
}