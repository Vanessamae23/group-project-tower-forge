//
//  GameWorld.swift
//  TowerForge
//
//  Created by Zheng Ze on 20/3/24.
//

import Foundation

class GameWorld {
    private unowned var scene: GameScene?
    private var entityManager: EntityManager
    private var systemManager: SystemManager
    private var eventManager: EventManager
    private var selectionNode: UnitSelectionNode
    private var grid: Grid
    private var renderer: Renderer?

    init(scene: GameScene?) {
        self.scene = scene
        entityManager = EntityManager()
        systemManager = SystemManager()
        eventManager = EventManager()
        selectionNode = UnitSelectionNode()
        grid = Grid(entityManager: entityManager)
        renderer = Renderer(target: self, scene: scene)

        self.setUpSelectionNode()
    }

    func update(deltaTime: TimeInterval) {
        systemManager.update(deltaTime)
        eventManager.executeEvents(in: self)
        entityManager.update(deltaTime)
        renderer?.render()
    }

    func spawnUnit(at location: CGPoint) {
        selectionNode.unitNodeDidSpawn(location)
    }

    func handleContact(between idA: UUID, and idB: UUID) {
        guard let entityA = entityManager.entity(with: idA), let entityB = entityManager.entity(with: idB),
              let event = entityA.collide(with: entityB) else {
            return
        }

        eventManager.add(event)
    }

    func handleSeparation(between idA: UUID, and idB: UUID) {
        guard let entityA = entityManager.entity(with: idA), let entityB = entityManager.entity(with: idB) else {
            return
        }
        // TODO: Handle any separation logic here.
    }

    private func setUpSelectionNode() {
        selectionNode.delegate = grid
        scene?.addChild(selectionNode)
        // Position unit selection node on the left side of the screen
        selectionNode.position = CGPoint(x: selectionNode.frame.width / 2, y: scene?.frame.midY ?? 300)

        // Calculate vertical spacing between unit nodes
        let verticalSpacing = selectionNode.frame.height
        var verticalY = 10.0
        // Position unit nodes vertically aligned
        for unitNode in selectionNode.unitNodes {
            unitNode.position = CGPoint(x: selectionNode.frame.width / 2,
                                        y: verticalY)
            verticalY += verticalSpacing
        }
    }
}

extension GameWorld: EventTarget {
    func system<T: TFSystem>(ofType type: T.Type) -> T? {
        systemManager.system(ofType: type)
    }
}

extension GameWorld: Renderable {
    func entitiesToRender() -> [TFEntity] {
        entityManager.entities
    }
}