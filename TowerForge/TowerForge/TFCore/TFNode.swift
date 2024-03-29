//
//  TFNode.swift
//  TowerForge
//
//  Created by Zheng Ze on 29/3/24.
//

import SpriteKit

class TFNode {
    var node: SKNode
    private var children: [String: TFNode] = [:]

    var name: String? {
        get { node.name }
        set(name) { node.name = name }
    }

    var position: CGPoint {
        get { node.position }
        set(position) { node.position = position }
    }

    var zPosition: CGFloat {
        get { node.zPosition }
        set(zPosition) { node.zPosition = zPosition}
    }

    var zRotation: CGFloat {
        get { node.zRotation }
        set(zRotation) { node.zRotation = zRotation }
    }

    var xScale: CGFloat {
        get { node.xScale }
        set(xScale) { node.xScale = xScale }
    }

    var yScale: CGFloat {
        get { node.yScale }
        set(yScale) { node.yScale = yScale }
    }

    var size: CGSize {
       node.frame.size
    }

    var isUserInteractionEnabled: Bool {
        get { node.isUserInteractionEnabled }
        set(isEnabled) { node.isUserInteractionEnabled = isEnabled }
    }

    init() {
        node = SKNode()
    }

    func add(child: TFNode) {
        guard let name = child.name, children[name] == nil else {
            return
        }
        children[name] = child
        node.addChild(child.node)
    }

    func removeChild(withName name: String) -> TFNode? {
        guard let child = children.removeValue(forKey: name) else {
            return nil
        }
        child.node.removeFromParent()
        return child
    }

    func child(withName name: String) -> TFNode? {
        children[name]
    }

    func removeFromParent() {
        node.removeFromParent()
    }
}
