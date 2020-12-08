//
//  SKEmitterNodeExtension.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/1/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

import SpriteKit

extension SKEmitterNode {
    
    func dieOutInDuration(_ duration: TimeInterval) {
        
        let firstWait = SKAction.wait(forDuration: duration)
        
        let stop = SKAction.run({
            
            [weak self] in
            if let weakSelf = self {
                weakSelf.particleBirthRate = 0
            }
        
        })
        
        let secondWait = SKAction.wait(forDuration: TimeInterval(self.particleLifetime))
        
        let remove = SKAction.removeFromParent()
        
        let dieOut = SKAction.sequence([firstWait, stop, secondWait, remove])
        
        run(dieOut)
        
    }
    
}
