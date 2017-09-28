//
//  PlaneAnchorViewController.swift
//  arkit-demo
//
//  Created by ttillage on 7/9/17.
//  Copyright © 2017 CapTech. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class PlaneMapperViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    fileprivate var planes: [String : SCNNode] = [:]
    fileprivate var showPlanes: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Plane Mapper"
        
        self.sceneView.antialiasingMode = .multisampling4X
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide Planes", style: .plain, target: self, action: #selector(tapTogglePlanes))
        
        self.configureWorldBottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showHelperAlertIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: - UI Events
    
    @IBAction func tapScreen() {
        if let camera = self.sceneView.pointOfView {
            let sphere = NodeGenerator.generateCubeInFrontOf(node: camera, physics: true)
            self.sceneView.scene.rootNode.addChildNode(sphere)
            print("Added box to scene")
        }
    }
    
    @objc private func tapTogglePlanes() {
        self.showPlanes = !self.showPlanes
        self.planes.values.forEach({ NodeGenerator.update(planeNode: $0, hidden: !self.showPlanes) })
        self.navigationItem.rightBarButtonItem?.title = self.showPlanes ? "Hide Planes" : "Show Planes"
    }
    
    // MARK: - Private Methods
    
    private func showHelperAlertIfNeeded() {
        let key = "PlaneMapperViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: "Plane Mapper", message: "Look around to identify horizontal planes. Tap to drop a cube into the world.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    
    private func configureWorldBottom() {
        let bottomPlane = SCNBox(width: 1000, height: 0.005, length: 1000, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        bottomPlane.materials = [material]
        
        let bottomNode = SCNNode(geometry: bottomPlane)
        bottomNode.position = SCNVector3(x: 0, y: -10, z: 0)
        
        let physicsBody = SCNPhysicsBody.static()
        physicsBody.categoryBitMask = CollisionTypes.bottom.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.shape.rawValue
        bottomNode.physicsBody = physicsBody
        
        self.sceneView.scene.rootNode.addChildNode(bottomNode)
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }
}

extension PlaneMapperViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        let planeNode = NodeGenerator.generatePlaneFrom(planeAnchor: planeAnchor, physics: true, hidden: !self.showPlanes)
        node.addChildNode(planeNode)
        self.planes[key] = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            NodeGenerator.update(planeNode: existingPlane, from: planeAnchor, hidden: !self.showPlanes)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            existingPlane.removeFromParentNode()
            self.planes.removeValue(forKey: key)
        }
    }
}

extension PlaneMapperViewController : SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        if CollisionTypes(rawValue: mask) == [CollisionTypes.bottom, CollisionTypes.shape] {
            if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.bottom.rawValue {
                contact.nodeB.removeFromParentNode()
            } else {
                contact.nodeA.removeFromParentNode()
            }
        }
    }
}

struct CollisionTypes : OptionSet {
    let rawValue: Int
    
    static let bottom  = CollisionTypes(rawValue: 1 << 0)
    static let shape = CollisionTypes(rawValue: 1 << 1)
}
