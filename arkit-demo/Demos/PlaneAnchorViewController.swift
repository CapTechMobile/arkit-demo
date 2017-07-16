//
//  PlaneAnchorViewController.swift
//  arkit-demo
//
//  Created by ttillage on 7/10/17.
//  Copyright © 2017 CapTech. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class PlaneAnchorViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Plane Anchor"
        
        self.sceneView.antialiasingMode = .multisampling4X
        self.sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingSessionConfiguration.isSupported {
            let configuration = ARWorldTrackingSessionConfiguration()
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
    
    private var mugs: Set<String> = []
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        
        print(results)
        
        if let match = results.first {
            let scene = SCNScene(named: "art.scnassets/mug.scn")!
            let node = scene.rootNode.childNode(withName: "mug", recursively: true)!
            
            let t = match.worldTransform
            node.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    // MARK: - Private Methods
    
    private func showHelperAlertIfNeeded() {
        let key = "PlaneAnchorViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: "Plane Anchor", message: "Tap to search for a horizontal plane and, if found, attach a coffee mug to it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
