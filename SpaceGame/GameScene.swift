//
//  GameScene.swift
//  SpaceGame
//
//  Created by yerinaoh on 2016. 9. 1..
//  Copyright (c) 2016년 yerinaoh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var player : SKSpriteNode = SKSpriteNode()
    var lastYieldTimeInterval : NSTimeInterval = NSTimeInterval()
    var updateTimeInterval : NSTimeInterval = NSTimeInterval()
    var aliens : Int = 0
    
    let alienCategory : UInt32 = 0x1 << 1 //외계인
    let torpedoCategory : UInt32 = 0x1 << 0 //미사일
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
        
        
    }
    
    override init(size : CGSize) {
        
        super.init(size : size)
        
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPointMake(self.frame.size.width / 2, player.size.height / 2 + 20)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
   
    func didBeginContact(contact: SKPhysicsContact){
        
        // Body1 and 2 depend on the categoryBitMask << 0 und << 1
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        torpedoDidCollideWithAlien(contact.bodyA.node as! SKSpriteNode, alien: contact.bodyB.node as! SKSpriteNode)
        
        
    }
    
    func addAlian() {
        let alien : SKSpriteNode = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = torpedoCategory
        
        alien.physicsBody?.collisionBitMask = 0 //충돌될 때 물리적으로 갖는 마스크..(didbegincontact)
        
        //랜덤 호출
        let minX = alien.frame.size.width - alien.size.width / 2
        let maxX = self.frame.size.width - alien.size.width / 2
        let rangeX = maxX - minX
        let position : CGFloat = CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minX)
        
        alien.position = CGPointMake(position, self.frame.size.height + alien.size.height)
        
        self.addChild(alien)
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)


        let move = SKAction.moveTo(CGPointMake(position, -alien.size.height), duration: NSTimeInterval(duration))

        let remove = SKAction.removeFromParent()
   
        alien.runAction(SKAction.sequence([move,remove]))
        
        
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate:CFTimeInterval){
        lastYieldTimeInterval += timeSinceLastUpdate
        if (lastYieldTimeInterval > 1){
            lastYieldTimeInterval = 0
            self.addAlian()
        }
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        var timeSinceLastUpdate = currentTime - updateTimeInterval
        updateTimeInterval = currentTime
        if (timeSinceLastUpdate > 1){
            timeSinceLastUpdate = 1/60
            updateTimeInterval = currentTime
        }
        self.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        self.runAction(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let touch = touches.first
        let location:CGPoint = touch!.locationInNode(self)
        
        let torpedo:SKSpriteNode = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = player.position
        
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody!.dynamic = true
        
        torpedo.physicsBody!.categoryBitMask = torpedoCategory
        torpedo.physicsBody!.contactTestBitMask = alienCategory
        torpedo.physicsBody!.collisionBitMask = 0
        torpedo.physicsBody!.usesPreciseCollisionDetection = true
        let offSet:CGPoint = vecSub(location, b: torpedo.position)

        if (offSet.y < 0){
            return
        }
    
        self.addChild(torpedo)
        
        let direction:CGPoint = vecNoramlize(offSet)
        let shotLength:CGPoint = vecMulti(direction, b: 1000)
        let finalDestination:CGPoint = vecAdd(shotLength, b: torpedo.position)

        let velocity = 568/1
        let moveDuration:Float = Float(self.size.width) / Float(velocity)

        let move = SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration))
        let remove = SKAction.removeFromParent()
        torpedo.runAction(SKAction.sequence([move,remove]))
    }

    func torpedoDidCollideWithAlien(torpedo:SKSpriteNode, alien:SKSpriteNode){
        torpedo.removeFromParent()
        alien.removeFromParent()
        aliens += 1
    }
    
    func vecAdd(a:CGPoint,b:CGPoint)->CGPoint{
        return CGPointMake(a.x + b.x, a.y + b.y);
    }
    
    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y);
    }
    
    func vecMulti(a:CGPoint,b:CGFloat)->CGPoint{
        return CGPointMake(a.x * b, a.y * b);
    }
    
    func vecLength (a:CGPoint)->CGFloat{
        return CGFloat(sqrtf(CFloat(a.x) * CFloat(a.x) + CFloat(a.y) * CFloat(a.y)));
    }
    
    func vecNoramlize (a:CGPoint)->CGPoint{
        let length:CGFloat = self.vecLength(a)
        return CGPointMake(a.x / length, a.y / length);
    }
    
}
