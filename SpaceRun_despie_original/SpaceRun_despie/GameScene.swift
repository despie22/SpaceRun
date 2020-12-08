//
//  GameScene.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 11/24/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//

// CLEAN UP START GAME DELETE ANYTHING YOU DID NOT USE
// ADD HIGH SCORES TO HARD AND EASY
// CHANGE SPRITES TO BE WATER GAME!

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Constants
    private let ShipSideSize = 40.0
    private let ForceFieldSideSize = 60.0
    private let SpaceshipNodeName = "Spaceship"
    private let ForceFieldNodeName = "forceField"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HealthPowerupNodeName = "healthPowerUp"
    private let HUDNodeName = "hud"
    private let TimerActionName = "timer"
    
    private let defualtFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    
    // MARK: - Variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private var shipFireRate: Double = 0.5
    private var shipHealthRate: CGFloat = 2.0
    var elapsedTime: TimeInterval = 0.0
    var easyMode: Bool = true
    private var tapGesture: UITapGestureRecognizer?
    
    // MARK: - Sounds
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // MARK: - Explosions
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode(fileNamed: "shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode(fileNamed: "obstacleExplode.sks")!
    
    typealias endGameCallbackType = () -> Void
    var endGameCallback: endGameCallbackType?
    
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGame(_ size: CGSize) {
        
        // Ship and force field nodes
        let ship = SKSpriteNode(imageNamed: SpaceshipNodeName)
        let forceField = SKSpriteNode(imageNamed: ForceFieldNodeName)
        
        // Ship and force field position
        ship.position = CGPoint(x: size.width / 2.0, y: size.height / 2)
        forceField.position = ship.position
        
        // Ship and force field size
        ship.size = CGSize(width: ShipSideSize, height: ShipSideSize)
        forceField.size = CGSize(width: ForceFieldSideSize, height: ForceFieldSideSize)
        forceField.alpha = 0.5
        
        // Ship and force field names
        ship.name = SpaceshipNodeName
        forceField.name = ForceFieldNodeName
        
        // Add ship and force field
        addChild(ship)
        addChild(forceField)
        
        // Add thrust to bottom of ship
        if let thrust = SKEmitterNode(fileNamed: "thrust.sks") {
            thrust.position = CGPoint(x: 0.0, y: -20.0)
            ship.addChild(thrust)
        }
        
        // Add background
        addChild(StarField())
        
        // HUD name and position
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        hudNode.zPosition = 100.0
        hudNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        
        // Add HUD
        addChild(hudNode)
        hudNode.layoutForScene()
        
        // Display starting health
        hudNode.updateHealth(shipHealthRate)
        
        // Start timer for score
        let startTime = NSDate.timeIntervalSinceReferenceDate
        
        let update = SKAction.run({
            [weak self] in
            
            if let weakSelf = self {
                let now = NSDate.timeIntervalSinceReferenceDate
                let elapsed = now - startTime
                
                weakSelf.elapsedTime = elapsed
            }
            
        })
        
        let delay = SKAction.wait(forDuration: 0.05)
        let updateAndDelay = SKAction.sequence([update, delay])
        let timer = SKAction.repeatForever(updateAndDelay)
        
        // Set key for stopping action later
        run(timer, withKey: TimerActionName)
        
    }
    
    override func willMove(from view: SKView) {
        if let view = self.view {
            if tapGesture != nil {
                view.removeGestureRecognizer(tapGesture!)
                tapGesture = nil
            }
        }
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            self.shipTouch = touch
        }
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let timeDelta = currentTime - lastUpdateTime
        
        // Move and shoot if user is touching or taps the screen
        if let shipTouch = shipTouch {
            moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                
                shoot()
                
                lastShotFireTime = currentTime
            }
        }
        
        // Easy or Hard drop probility
        let thingProbility: Int
        if (self.easyMode) {
            thingProbility = 15
        } else {
            thingProbility = 30
        }
        
        // Random number to check if we should drop thing
        if Int.random(in: 0..<1000) < thingProbility {
            dropThing()
        }
        
        // Check if anything has interacted
        checkCollisions()
        
        lastUpdateTime = currentTime
    }
    
    // Moves ship to tapped position
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Sets speed of ship
        let shipSpeed = CGFloat(130)
        
        // Moves ship and force field based on tapped position
        if let ship = self.childNode(withName: SpaceshipNodeName), let forceField = self.childNode(withName: ForceFieldNodeName) {
            
            let distanceToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            if distanceToTravel > 4 {
                
                // Find angle the ship needs to move at
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                // Sets ship and force field position
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                forceField.position = ship.position
            }
            
        }
        
    }
    
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Photon node and position
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoNodeName)
            
            photon.name = PhotonTorpedoNodeName
            photon.position = ship.position
            
            self.addChild(photon)
            
            // Photon animation
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            let remove = SKAction.removeFromParent()
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            // Photon sound
            self.run(self.shootSound)
            
        }
    }
    
    // MARK - Drop Methods
    // Drop Random object
    func dropThing() {
        
        let dice = Int.random(in: 0..<100)
        
        if dice < 3 {
            dropHealth()
        } else if dice < 5 {
            dropPowerUp()
        } else if dice < 20 {
            dropEnemyShip()
        } else {
            dropAsteroid()
        }
    }
    
    // Drop Asteroid
    func dropAsteroid() {
        
        // Define size of astroid
        let sideSize = Double(15 + Int.random(in: 0..<30))
        
        // Determine the starting x and y position
        let maxX = Double(self.size.width)
        let quarterX = maxX / 4.0
        let startX = Double(Int.random(in: 0..<Int((maxX + (quarterX * 2))))) - quarterX
        let startY = Double(self.size.height) + sideSize
        
        let endX = Double(Int.random(in: 0..<Int(maxX)))
        let endY = 0.0 - sideSize
        
        // Create and configure astroid
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Astroid animation
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + Int.random(in: 0..<5)))
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        let spin = SKAction.rotate(byAngle: 3, duration: Double(Int.random(in: 0..<2) + 1))
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.run(all)
        
    }
    
    // Drop enemy ships
    func dropEnemyShip() {
        
        // Define size of ship
        let sideSize = 30.0
        
        // Determine starting x and y position
        let startX = Double(Int.random(in: 0..<(Int(self.size.width - 40))) + 20)
        let startY = Double(self.size.height) + sideSize
        
        // Ceate and configure ship
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        let shipPath = buildEnemyShipMovementPath()
        
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        let remove = SKAction.removeFromParent()
        
        let followPathAndRemove = SKAction.sequence([followPath, remove])
        
        enemy.run(followPathAndRemove)
    }
    
    // Drop Powerups
    func dropPowerUp() {
        
        // Define size of powerup
        let sideSize = 30.0
        
        // Determine starting x and y position
        let startX = Double(Int.random(in: 0..<Int(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize
        let endY = 0 - sideSize
        
        // Create and configure powerup
        let powerUp = SKSpriteNode(imageNamed: PowerupNodeName)
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        // Move and clean up node
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 6)
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Rotate powerup by 3 radians (just less than 180 degrees) over a 1-3 second duration
        let spin = SKAction.rotate(byAngle: 1, duration: 1)
        let spinForever = SKAction.repeatForever(spin)
        let all = SKAction.group([spinForever, travelAndRemove])
        
        powerUp.run(all)
        
    }
    
    func dropHealth() {
        
        // Define size of health
        let sideSize = 20.0
        
        // Determine starting x and y position
        let startX = Double(Int.random(in: 0..<Int(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize
        let endY = 0 - sideSize
        
        // Create and configure heath drop
        let healthPowerUp = SKSpriteNode(imageNamed: HealthPowerupNodeName)
        
        // Health powerup attributes
        healthPowerUp.size = CGSize(width: sideSize, height: sideSize)
        healthPowerUp.position = CGPoint(x: startX, y: startY)
        healthPowerUp.name = "shipHealth"
        
        self.addChild(healthPowerUp)
        
        // Move and clean up node
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 5)
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Health scales down to 50% and fades out over set duration in seconds
        let scaleDown = SKAction.scale(to: 0.5, duration: 5)
        let fadeOut = SKAction.fadeOut(withDuration: 5)
        
        // Scale down and fade out at the same time
        let scaleDownFadeOut = SKAction.group([scaleDown, fadeOut])
        
        // Combine action groups
        let all = SKAction.group([scaleDownFadeOut, travelAndRemove])
        
        healthPowerUp.run(all)
    }
    
    // Path enemy ship will follow
    func buildEnemyShipMovementPath() -> CGPath {
        let yMax = -1.0 * self.size.height
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
    }
    
    // MARK - Collisions
    func checkCollisions() {
        
        // Assign local constants for ship and force field nodes
        if let ship = self.childNode(withName: SpaceshipNodeName), let forceField = self.childNode(withName: ForceFieldNodeName) {
            
            // Ship runs into a power-up
            enumerateChildNodes(withName: PowerupNodeName) {
                powerUp, _ in
                
                if ship.intersects(powerUp) {
                    
                    // Shows Power-up on HUD
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showPowerupTimer(self.powerUpDuration)
                    }
                    
                    // Remove power-up to screen
                    powerUp.removeFromParent()
                    
                    // Increase ship's firing rate
                    self.shipFireRate = 0.1
                    
                    // Power down after duration
                    let powerDown = SKAction.run({
                        self.shipFireRate = self.defualtFireRate
                    })
                    
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    // Remove action incase one is already running
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    ship.run(waitAndPowerDown, withKey: powerDownActionKey)
                    
                    
                }
            }
            
            // Ship runs into health power up
            enumerateChildNodes(withName: "shipHealth") { health, _ in
                
                if ship.intersects(health) {
                    
                    // Remove health from screen
                    health.removeFromParent()
                    
                    // Increase health and force field visibility
                    self.shipHealthRate = 4.0
                    forceField.alpha = 1.0
                    
                    // Update HUD with new health
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.updateHealth(self.shipHealthRate)
                    }
                    
                }
            }
            
            // Astroid hits ship
            enumerateChildNodes(withName: ObstacleNodeName) { obstacle, _ in
                
                if ship.intersects(obstacle) {
                    
                    // Remove obstacle from screen
                    obstacle.removeFromParent()
                
                    // New heatlh and force field visibilty
                    self.shipHealthRate -= 1
                    forceField.alpha -= 0.25
                    
                    // Update HUD with new health
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.updateHealth(self.shipHealthRate)
                    }
                    
                    // Obstacle hits and kills
                    if self.shipHealthRate == 0 {
                    
                        // Ship explotion sound
                        self.run(self.shipExplodeSound)
                        
                        // Explosion animation
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = ship.position
                        explosion.dieOutInDuration(0.3)
                        self.addChild(explosion)
                        ship.removeFromParent()
                        forceField.removeFromParent()
                        
                        // Ends game
                        self.shipTouch = nil
                        self.endGmae()
                    } else {
                        // Obstacle hits and no death
                        // Obstacle explotion sound
                        self.run(self.obstacleExplodeSound)
                    }
                }
                
                // Torpedo hits an obstacle
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName) { myPhoton, stop in
                    
                    if myPhoton.intersects(obstacle) {
                        
                        // Remove photon and obstacle from screen
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        // Obstacle explotion sound
                        self.run(self.obstacleExplodeSound)
                        
                        // Explotion animation
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.dieOutInDuration(0.1)
                        
                        self.addChild(explosion)
                        
                        // Add points if easy or hard and add points to HUD
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            let score = 10 * Int(self.elapsedTime) * (self.easyMode ? 1 : 2)
                            hud.addPoints(score)
                        }
                        
                        stop.pointee = true
                    }
                }
            }
        }
    }
    
    // MARK: - End Game
    func endGmae() {
        if let view = self.view {
            
            // Goes to home screen on next tap
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapped))
            view.addGestureRecognizer(tapGesture!)
            
            // Adds game over node
            let node = GameOverNode()
            node.position = CGPoint(x: self.size.width/2.0, y: self.size.height/2.0)
            addChild(node)
        }
        
        // Stops timer
        removeAction(forKey: TimerActionName)
        
        // Removes actions in HUDNodeName
        let hud = childNode(withName: HUDNodeName) as! HUDNode
        hud.endGame()
        
        // Updates high score
        let defaults = UserDefaults.standard
        let highScore = defaults.value(forKey: "highScore")
        
        if ((highScore as AnyObject).integerValue < hud.score) {
            defaults.setValue(hud.score, forKey: "highScore")
        }
        
    }
    
    // End game tap
    @objc func tapped() {
        if let endGameCallback = endGameCallback {
            endGameCallback()
        }
    }

}
