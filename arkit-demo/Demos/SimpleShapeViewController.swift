//
//  SimpleShapeViewController.swift
//  arkit-demo
//
//  Created by ttillage on 7/9/17.
//  Copyright © 2017 CapTech. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class SimpleShapeViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Simple Shape"
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.antialiasingMode = .multisampling4X
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingSessionConfiguration.isSupported {
            let configuration = ARWorldTrackingSessionConfiguration()
            self.sceneView.session.run(configuration)
        } else if ARSessionConfiguration.isSupported {
            let configuration = ARSessionConfiguration()
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
            let sphere = NodeGenerator.generateSphereInFrontOf(node: camera)
            self.sceneView.scene.rootNode.addChildNode(sphere)
            print("Added sphere to scene")
        }
    }
    
    @IBAction func twoFingerTapScreen() {
        if let camera = self.sceneView.pointOfView {
            let sphere = NodeGenerator.generateCubeInFrontOf(node: camera, physics: false)
            self.sceneView.scene.rootNode.addChildNode(sphere)
            print("Added cube to scene")
        }
    }
    
    // MARK: - Private Methods
    
    private func showHelperAlertIfNeeded() {
        let key = "SimpleShapeViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: "Simple Shape", message: "Tap to anchor a sphere to the world. 2-finger tap to anchor a cube into the world.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
