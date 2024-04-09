//
//  PlayerRenderStage.swift
//  TowerForge
//
//  Created by Zheng Ze on 29/3/24.
//

import Foundation

class PlayerRenderStage: RenderStage {
    func transform(node: TFNode, for entity: TFEntity) {
        guard let playerComponent = entity.component(ofType: PlayerComponent.self) else {
            return
        }

        // prevent HUD labels from being scaled
        if entity.hasComponent(ofType: LabelComponent.self) {
            return
        }

        if playerComponent.player == .oppositePlayer {
            node.xScale *= -1
        }
    }
}
