//
//  HUDNode.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/3/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode {
    
    // MARK: - Constants
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    
    private let HealthGroupName = "elapsedGroup"
    private let HealthValueName = "elapsedValue"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "showPowerupTimer"
    
    // MARK - Variables
    var score: Int = 0
    
    // String format for score
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // String format for timers
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override init() {
        super.init()
        
        createHealthGroup()
        
        createScoreGroup()
        
        createPowerupGroup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coderL) has not been implemented")
    }
    
    // MARK: - Hud Groups
    func createScoreGroup() {
        
        // Create score node
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Score title label
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreTitle.fontSize =  12.0
        scoreTitle.fontColor = SKColor.white
        
        // Score title positioning and text
        scoreTitle.horizontalAlignmentMode = .left
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Add title to score group
        scoreGroup.addChild(scoreTitle)
        
        // Score value label
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        // Score value positioning and text
        scoreValue.horizontalAlignmentMode = .left
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        // Add value to score group
        scoreGroup.addChild(scoreValue)
        
        // Add score group
        addChild(scoreGroup)
    }
    
    func createHealthGroup() {
        
        // Create health node
        let healthGroup = SKNode()
        healthGroup.name = HealthGroupName
        
        // Health title label
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        healthTitle.fontSize =  12.0
        healthTitle.fontColor = SKColor.white
        
        // Health title positioning and text
        healthTitle.horizontalAlignmentMode = .right
        healthTitle.verticalAlignmentMode = .bottom
        healthTitle.text = "HEALTH"
        healthTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Add health title to health group
        healthGroup.addChild(healthTitle)
        
        // Health value label
        let healthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healthValue.fontSize = 20.0
        healthValue.fontColor = SKColor.white
        
        // Health value positioning and text
        healthValue.horizontalAlignmentMode = .right
        healthValue.verticalAlignmentMode = .top
        healthValue.name = HealthValueName
        healthValue.text = ""
        healthValue.position = CGPoint(x: 0.0, y: -4.0)
        
        // Add health value to health group
        healthGroup.addChild(healthValue)
        
        // Add health group
        addChild(healthGroup)
    }
    
    func createPowerupGroup() {
        
        // Create power-up node
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        // Power-up title label
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        // Power-up title positioning and text
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Add power-up to power-up group
        powerupGroup.addChild(powerupTitle)
        
        // Power-up value label
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        // Power-up value positioning and text
        powerupValue.verticalAlignmentMode = .top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        // Power-up animation
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let pulseForever = SKAction.repeatForever(pulse)
        
        // Pulse title
        powerupTitle.run(pulseForever)
        
        // Add power-up value to power-up group
        powerupGroup.addChild(powerupValue)
        
        // Add power-up group
        addChild(powerupGroup)
        powerupGroup.alpha = 0.0
    }
    
    func layoutForScene () {
        
        if let scene = scene {
            
            let sceneSize = scene.size
            
            var groupSize = CGSize.zero
            
            // Set up score group in HUD
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width / 2 + 20.0, y: sceneSize.height / 2.0 - groupSize.height - 22.0)
            }
            
            // Set up power-up group in HUD
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height / 2 - groupSize.height - 22.0)
            }
            
            // Set up health group in HUD
            if let healthGroup = childNode(withName: HealthGroupName) {
                groupSize = healthGroup.calculateAccumulatedFrame().size
                
                healthGroup.position = CGPoint(x: sceneSize.width / 2.0 - 20.0, y: sceneSize.height / 2.0 - groupSize.height - 35.0)
            }
        }
    }
    
    // MARK: - HUD Functions
    func updateHealth(_ health: CGFloat) {
        
        if let healthValue = childNode(withName: "\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            
            // Set health text based on incoming health
            switch health {
            case 1.0 : healthValue.text = "25%"
            case 2.0 : healthValue.text = "50%"
            case 3.0 : healthValue.text = "75%"
            case 4.0 : healthValue.text = "100%"
            default: healthValue.text = "0%"
                
            }
        }
    }
    
    func addPoints(_ points: Int) {
        
        score += points
        
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            // Set score value text based on incoming points
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            // Score animation
            let scale = SKAction.scale(to: 1.1, duration: 0.02)
            let shrink = SKAction.scale(to: 1.0, duration: 0.07)
            
            // Run score animation
            scoreValue.run(SKAction.sequence([scale, shrink]))
        }
    }
    
    func endGame() {
        
        // Removes power-up group and fades power-up group
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            powerupGroup.run(fadeOut)
        }
    }
    
    func showPowerupTimer(_ time: TimeInterval) {
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            // Remove action incase its already running
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            if let powerupValue = powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                // Power-up timer
                let start = NSDate.timeIntervalSinceReferenceDate
                
                let block = SKAction.run({
                    [weak self] in
                    if let weakSelf = self {
                        let elapsed = NSDate.timeIntervalSinceReferenceDate - start
                        let left = max(time - elapsed, 0)
                        let leftFormat = weakSelf.timeFormatter.string(from: NSNumber(value: left))!
                        
                        powerupValue.text = "\(leftFormat)s left"
                    }
                })
                
                let blockPause = SKAction.wait(forDuration: 0.05)
                let countDownSequence = SKAction.sequence([block, blockPause])
                let countDown = SKAction.repeatForever(countDownSequence)
                
                // Power-up timer animation
                let fadeIn = SKAction.fadeAlpha(by: 1.0, duration: 0.1)
                let wait = SKAction.wait(forDuration: time)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                let stopAction = SKAction.run({
                    () -> Void in
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                })
                
                // Power-up animation group
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                
                // Run power-up timer
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
            }
        }
    }
    
}
