//
//  GameViewController.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 11/24/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // MARK: - Variables
    var easyMode: Bool!
    
    // Run Onload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        // Show FPS and Node count
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Set background color
        let blackScene = SKScene(size: skView.bounds.size)
        blackScene.backgroundColor = SKColor.black
        skView.presentScene(blackScene)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let skView = self.view as! SKView
        
        let openingScene = OpeningScene(size: skView.bounds.size)
        openingScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        skView.presentScene(openingScene, transition: transition)
        
        openingScene.sceneEndCallback = {
            [weak self] in
            if let weakSelf = self {
                let scene = GameScene(size: skView.bounds.size)
                
                scene.backgroundColor = SKColor.black
                
                scene.scaleMode = .aspectFill
                
                scene.easyMode = weakSelf.easyMode
                
                scene.endGameCallback = {
                    [weak self] in
                    if let ws = self {
                        ws.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                skView.presentScene(scene)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
