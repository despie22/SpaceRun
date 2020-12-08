//
//  MenuViewController.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/1/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import SpriteKit

class MenuViewController: UIViewController {

    @IBOutlet weak var difficultyChooser: UISegmentedControl!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    private var demoView: SKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Displays highscore
        let scoreFormatter = NumberFormatter()
        scoreFormatter.numberStyle = .decimal
        
        let defaults = UserDefaults.standard
        defaults.register (defaults: ["highScore": 0])
        let score = defaults.integer(forKey: "highScore")
        
        let scoreText = "High Score: \(scoreFormatter.string(from: NSNumber(value: score))!)"
    
        self.highScoreLabel.text = scoreText
        
        // Set background
        demoView = SKView(frame: self.view.bounds)
        let scene = SKScene(size: self.view.bounds.size)
        
        scene.backgroundColor = SKColor.black
        scene.scaleMode = SKSceneScaleMode.aspectFill
        
        scene.addChild(StarField())
        
        if let demoView = demoView {
            demoView.presentScene(scene)
            view.insertSubview(demoView, at: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let demoView = self.demoView {
            demoView.removeFromSuperview()
            self.demoView = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PlayGame") {
            let gameController = segue.destination as! GameViewController
            gameController.easyMode = self.difficultyChooser.selectedSegmentIndex == 0
        }
    }
    
}
