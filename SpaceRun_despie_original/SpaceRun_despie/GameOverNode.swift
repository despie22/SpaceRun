//
//  GameOverNode.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/2/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import SpriteKit

class GameOverNode: SKNode {

    override init() {
        super.init()
        
        // Game OVer label
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.fontSize = 32.0
        label.fontColor = SKColor.white
        label.text = "Game Over"
        addChild(label)
        
        // Fade in and grow label
        label.alpha = 0.0
        label.xScale = 0.2
        label.yScale = 0.2
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
        let scaleIn = SKAction.scale(to: 1.0, duration: 2.0)
        let fadeAndScaleIn = SKAction.group([fadeIn, scaleIn])
        label.run(fadeAndScaleIn)
        
        // Try again label
        let instructions = SKLabelNode(fontNamed: "AvenirNext-Medium")
        instructions.fontSize = 14.0
        instructions.fontColor = SKColor.white
        instructions.text = "Tap to try again."
        instructions.position = CGPoint(x: 0.0, y: -45.0)
        addChild(instructions)
        
        // Try again label animation
        instructions.alpha = 0.0
        let wait = SKAction.wait(forDuration: 4.0)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let popUp = SKAction.scale(to: 1.1, duration: 0.1)
        let dropDown = SKAction.scale(to: 1.0, duration: 0.1)
        let pauseAndAppear = SKAction.sequence([wait, appear, popUp, dropDown])
        instructions.run(pauseAndAppear)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
