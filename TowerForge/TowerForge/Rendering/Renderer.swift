//
//  Renderer.swift
//  TowerForge
//
//  Created by Zheng Ze on 21/3/24.
//

import Foundation
import SpriteKit

class Renderer {
    private unowned var target: Renderable
    private unowned var scene: SKScene?

    private var renderedNodes: [UUID: TFAnimatableNode] = [:]

    init(target: Renderable, scene: GameScene?) {
        self.target = target
        self.scene = scene
    }

    func render() {
        var nodesToBeRemoved = renderedNodes

        for entity in target.entitiesToRender() {
            guard nodesToBeRemoved[entity.id] != nil else {
                addAndCache(entity: entity)
                continue
            }

            nodesToBeRemoved.removeValue(forKey: entity.id)
            update(entity: entity)
        }

        for entityId in nodesToBeRemoved.keys {
            removeAndUncache(with: entityId)
        }
    }

    private func update(entity: TFEntity) {
        guard let positionComponent = entity.component(ofType: PositionComponent.self),
              let node = renderedNodes[entity.id] else {
            return
        }

        node.position = positionComponent.position
    }

    private func addAndCache(entity: TFEntity) {
        guard let spriteComponent = entity.component(ofType: SpriteComponent.self),
              let positionComponent = entity.component(ofType: PositionComponent.self) else {
            return
        }

        let node = TFAnimatableNode(textures: spriteComponent.textures,
                                    height: spriteComponent.height,
                                    width: spriteComponent.width,
                                    animatableKey: spriteComponent.animatableKey)
        node.position = positionComponent.position
        node.playAnimation()
        node.name = entity.id.uuidString
        renderedNodes[entity.id] = node
        scene?.addChild(node)
    }

    private func removeAndUncache(with id: UUID) {
        guard let node = renderedNodes.removeValue(forKey: id) else {
            return
        }
        node.removeFromParent()
    }
}
