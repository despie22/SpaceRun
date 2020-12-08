//
//  StarField.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/1/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import SpriteKit

class StarField: SKNode {

    override init() {
        super.init()
        
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func initSetup() {
        
        let update = SKAction.run ({
            [weak self] in
            
            if Int.random(in: 0..<10) < 3 {
                if let weakSelf = self {
                    weakSelf.launchStar()
                }
            }
            
        })
        
        let delay = SKAction.wait(forDuration: 0.01)
        
        let updateLoop = SKAction.sequence([delay, update])
        
        run(SKAction.repeatForever(updateLoop))
        
    }
    
    func launchStar() {
        
        if let scene = self.scene {
            
            let randX = Double(Int.random(in: 0..<Int(scene.size.width)))
            let maxY =  Double(scene.size.height)
            
            let randomStart = CGPoint(x: randX, y: maxY)
            
            let star = SKSpriteNode(imageNamed: "shootingstar")
            
            star.position = randomStart
            
            star.size = CGSize(width: 2.0, height: 10.0)
            star.alpha = 0.1 + (CGFloat(Int.random(in: 0..<10)) / 10)
            
            addChild(star)
            
            let destY = 0.0 - scene.size.height - star.size.height
            let duration = 0.1 + Double(Int.random(in: 0..<10)) / 10.0
            
            let move = SKAction.moveBy(x: 0.0, y: destY, duration: duration)
            
            let remove = SKAction.removeFromParent()
            
            star.run(SKAction.sequence([move, remove]))
            
        }
        
    }
    
}
