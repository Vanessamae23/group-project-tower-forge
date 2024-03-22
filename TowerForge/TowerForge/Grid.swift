//
//  Grid.swift
//  TowerForge
//
//  Created by Keith Gan on 22/3/24.
//

import SpriteKit

class Grid: UnitSelectionNodeDelegate {
    let DEFAULT_NO_OF_ROWS = 8

    private var entityManager: EntityManager
    private var noOfRows: Int

    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        self.noOfRows = DEFAULT_NO_OF_ROWS
    }

    func unitSelectionNodeDidSpawn<T: BaseUnit & Spawnable>(ofType type: T.Type, position: CGPoint) {
        let snapPosition = CGPoint(x: position.x, y: snapYPosition(yPosition: position.y))
        let unit = UnitGenerator.spawn(ofType: type, at: snapPosition, player: Player.ownPlayer, entityManager: entityManager)
        entityManager.add(unit)
    }

    private func snapYPosition(yPosition: Double) -> Double {
        let normalizedYPosition = normalizeYPosition(yPosition: yPosition)
        let screenHeight = Double(UIScreen.main.bounds.height)
        let rowHeight = screenHeight / Double(noOfRows)
        let rowIndex = Int(normalizedYPosition / rowHeight)
        let centerY = Double(rowIndex) * rowHeight + rowHeight / 2
        return denormalizeYPosition(yPosition: centerY)
    }

    private func normalizeYPosition(yPosition: Double) -> Double {
        yPosition + UIScreen.main.bounds.height / 2
    }

    private func denormalizeYPosition(yPosition: Double) -> Double {
        yPosition - UIScreen.main.bounds.height / 2
    }
}