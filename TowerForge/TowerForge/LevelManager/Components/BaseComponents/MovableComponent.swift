//
//  MovableComponent.swift
//  TowerForge
//
//  Created by Vanessa Mae on 15/03/24.
//

import Foundation
import CoreGraphics

class MovableComponent: TFComponent {
    public var velocity: CGVector
    public var position: CGPoint

    init(position: CGPoint, velocity: CGVector = .zero) {
        self.velocity = velocity
        self.position = position
        super.init()
    }

    override func update(deltaTime: TimeInterval) {
        guard let entity = entity,
              let positionComponent = entity.component(ofType: PositionComponent.self) else {
            return
        }
        
        positionComponent.position.x += velocity.dx * CGFloat(deltaTime)
        positionComponent.position.y += velocity.dy * CGFloat(deltaTime)
    }
}
