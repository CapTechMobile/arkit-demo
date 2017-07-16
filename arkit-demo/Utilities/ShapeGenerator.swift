//
//  ShapeGenerator.swift
//  arkit-demo
//
//  Created by ttillage on 7/9/17.
//  Copyright © 2017 CapTech. All rights reserved.
//

import Foundation
import SceneKit

struct NodeGenerator {
    
    static func generateSphereInFrontOf(node: SCNNode, physics: Bool) -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        
        let color = SCNMaterial()
        color.diffuse.contents = self.randomColor()
        sphere.materials = [color]
        
        let sphereNode = SCNNode(geometry: sphere)
        
        let position = SCNVector3(x: 0, y: 0, z: -0.6)
        sphereNode.position = node.convertPosition(position, to: nil)
        
        if physics {
            let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphere, options: nil))
            physicsBody.mass = 2.0
            physicsBody.categoryBitMask = CollisionTypes.sphere.rawValue
            sphereNode.physicsBody = physicsBody
        }
        
        return sphereNode
    }
    
    private static func randomColor() -> UIColor {
        return UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
    }
}
