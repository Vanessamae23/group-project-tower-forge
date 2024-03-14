//
//  TFNode.swift
//  TowerForge
//
//  Created by MacBook Pro on 14/03/24.
//

import Foundation
import SpriteKit
import CoreGraphics

class TFNode: SKSpriteNode {
    public var textures: TFTextures?
    public var width: CGFloat
    public var height: CGFloat
    
    init(textures: TFTextures?, height: CGFloat, width: CGFloat) {
        if let textures = textures {
            self.textures = textures
        }
        self.width = width
        self.height = height
        super.init(texture: textures?.mainTexture, color: .clear, size: CGSize(width: width, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
