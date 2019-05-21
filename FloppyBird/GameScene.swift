//
//  GameScene.swift
//  FloppyBird
//
//  Created by Mirza Ahmed Baig on 25/05/18.
//  Copyright © 2018 MAB. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var gameBackgroung = SKSpriteNode()
    var pipeNode = SKSpriteNode()
    var pipeNode2 = SKSpriteNode()
    var scoreNode = SKLabelNode()
    var gameOverNode = SKLabelNode()
    var score = 0
    
    var timer: Timer = Timer()
    
    
    enum ObjectType: UInt32{
        case bird = 1
        case object  = 2
        case gap = 4
    }
    
    private var gameOver = false
    private var gameStarted = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setUpGame()
    
    }
    
    
    
    
    
    private func setUpGame(){
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let background = SKTexture(imageNamed: "bg.png")
        
        
        let animation = SKAction.animate(with: [birdTexture,birdTexture2], timePerFrame: 0.1)
        let birdFlapAnimation = SKAction.repeatForever(animation)
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -background.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: background.size().width, dy:0), duration: 0)
        let repeatBGAnimation = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,shiftBGAnimation]))
        var i = 0
        while i < 3 {
            self.gameBackgroung = SKSpriteNode(texture: background)
            self.gameBackgroung.position = CGPoint(x: background.size().width / 2 * CGFloat(i), y: self.frame.midY)
            self.gameBackgroung.size.height = self.frame.height
            self.gameBackgroung.run(repeatBGAnimation)
            gameBackgroung.zPosition = -2
            self.addChild(gameBackgroung)
            i += 1
        }
        
        
        self.bird = SKSpriteNode(texture: birdTexture)
        self.bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.bird.run(birdFlapAnimation)
        self.addChild(bird)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        bird.physicsBody!.categoryBitMask = ObjectType.bird.rawValue
        bird.physicsBody!.collisionBitMask = ObjectType.bird.rawValue
        
        let groud = SKNode()
        groud.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        groud.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        groud.physicsBody!.isDynamic = false
        self.addChild(groud)
        
        groud.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        groud.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        groud.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        
        scoreNode.fontSize = 70
        scoreNode.fontName = "Helvetica"
        scoreNode.text = "0"
        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        self.addChild(scoreNode)
        
    }
    
    @objc private func createPipe(){
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffeset = CGFloat(movementAmount) - self.frame.height / 4
        
        let removePipes = SKAction.removeFromParent()
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/80))
        let pipeAction = SKAction.sequence([movePipes, removePipes])
        
        self.pipeNode = SKSpriteNode(texture: pipeTexture)
        self.pipeNode.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffeset)
        self.pipeNode.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        self.pipeNode.physicsBody!.isDynamic = false
        self.pipeNode.run(pipeAction)
        
        pipeNode.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        pipeNode.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        pipeNode.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        self.pipeNode.zPosition = -1
        self.addChild(pipeNode)
        
        
        
        self.pipeNode2 = SKSpriteNode(texture: pipeTexture2)
        self.pipeNode2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture.size().height / 2 - gapHeight / 2 + pipeOffeset)
        self.pipeNode2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        self.pipeNode2.physicsBody!.isDynamic = false
        self.pipeNode2.run(pipeAction)
        
        pipeNode2.physicsBody!.contactTestBitMask = ObjectType.object.rawValue
        pipeNode2.physicsBody!.categoryBitMask = ObjectType.object.rawValue
        pipeNode2.physicsBody!.collisionBitMask = ObjectType.object.rawValue
        
        self.pipeNode2.zPosition = -1
        self.addChild(pipeNode2)
        
        
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffeset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(pipeAction)
        
        
        gap.physicsBody!.contactTestBitMask = ObjectType.bird.rawValue
        gap.physicsBody!.categoryBitMask = ObjectType.gap.rawValue
        gap.physicsBody!.collisionBitMask = ObjectType.gap.rawValue
        
        self.addChild(gap)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            gameStarted=true
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.createPipe), userInfo: nil, repeats: true)
        }
        if(!gameOver){
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        }else{
            gameOver = false
            gameStarted = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setUpGame()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
        if (contact.bodyA.categoryBitMask == ObjectType.gap.rawValue || contact.bodyB.categoryBitMask == ObjectType.gap.rawValue) && !gameOver {
            print("gap contacted")
            score += 1
            self.scoreNode.text = String(score)
        }else {
            print("View contacted")
            self.speed = 0
            self.gameOver = true
            self.timer.invalidate()
            gameOverNode.fontSize = 70
            gameOverNode.fontName = "Helvetica"
            gameOverNode.text = "Game Over"
            gameOverNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.addChild(gameOverNode)
        }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
