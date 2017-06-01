//
//  GameScene.swift
//  Go Straight
//
//  Created by 石田陵 on 2017/05/01.
//  Copyright © 2017年 ryo.ishida. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

  var scrollNode: SKNode!
  var rightNode: SKNode!
  var leftNode: SKNode!
  var jumpNode: SKNode!
  var attackNode: SKNode!

  var player: SKSpriteNode!
  var player_a: SKSpriteNode!
  var player_b: SKSpriteNode!
  var ball: SKSpriteNode!
  
  var ground: SKSpriteNode!
  var floor: SKSpriteNode!
  var floorTheTop: SKSpriteNode!

  var fox: SKSpriteNode!
  var greenMonster: SKSpriteNode!
  
  var rightTouches: Bool = false
  var leftTouches: Bool = false
  
  var rightDirection: Bool = true
  var leftDirection: Bool = false
  
  var beganPos: CGPoint!
  
  var target: SKShapeNode!
  var playerTexture: SKTexture!
  var playerTextureA: SKTexture!
  var playerTextureB: SKTexture!
  var jump: Int = 0
  
  let playerCategory: UInt32 = 0b1
  let enemyCategory: UInt32 = 0b10
  let attackCategory: UInt32 = 0b100
  
  var timer: Timer?
  var timer_sec: Float = 0
  
  override func didMove(to view: SKView) {
    self.view?.isMultipleTouchEnabled = false

    backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    physicsWorld.contactDelegate = self
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -8.0)
        
    scrollNode = self.childNode(withName: "scrollNode")!
        
    ground = scrollNode.childNode(withName: "ground") as! SKSpriteNode

    floor = scrollNode.childNode(withName: "floor") as! SKSpriteNode

    floorTheTop = scrollNode.childNode(withName: "floorTheTop") as! SKSpriteNode
    
    rightNode = self.childNode(withName: "rightNode")!
    rightNode.alpha = 0.00001
    leftNode = self.childNode(withName: "leftNode")!
    leftNode.alpha = 0.00001
    jumpNode = self.childNode(withName: "jumpNode")!
    jumpNode.alpha = 0.00001
    attackNode = self.childNode(withName: "attackNode")!
    attackNode.alpha = 0.00001
    
    setUpPlayer()
    setUpGreenMonster()
  }
  
  func setUpPlayer() {
    let playerTexture = SKTexture(imageNamed: "player")
    playerTexture.filteringMode = SKTextureFilteringMode.linear
    player = SKSpriteNode(texture: playerTexture)
    player.position = CGPoint(x: -256, y: 0)
    player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
    player.physicsBody?.categoryBitMask = playerCategory
    player.physicsBody?.contactTestBitMask = 2 | enemyCategory
    target = SKShapeNode(circleOfRadius: 10)
    target.position = CGPoint(x: player.position.x, y: 300)
    scene?.addChild(target)
    let lookAtConstraint = SKConstraint.orient(to: target, offset: SKRange(constantValue: -CGFloat.pi / 2))
    player.constraints = [ lookAtConstraint ]
    let limitLookAt = SKConstraint.zRotation(SKRange(lowerLimit: -CGFloat.pi / 2, upperLimit: CGFloat.pi / 2))
    player.constraints = [ lookAtConstraint, limitLookAt ]
    addChild(player)
  }

  func setUpAttack() {
    let ballTexture = SKTexture(imageNamed: "ball")
    ballTexture.filteringMode = SKTextureFilteringMode.linear
    ball = SKSpriteNode(texture: ballTexture)
    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.height / 2)
    ball.physicsBody?.categoryBitMask = attackCategory
    ball.physicsBody?.contactTestBitMask = enemyCategory
    if rightDirection == true {
      ball.position = CGPoint(x: player.position.x + 10, y: player.position.y)
    let ballMove = SKAction.moveBy(x: 200, y: 0, duration: 0.5)
      let ballRemove = SKAction.removeFromParent()
      let ballsequence = SKAction.sequence([ballMove, ballRemove])
      addChild(ball)
      ball.run(ballsequence)
    } else {
      ball.position = CGPoint(x: player.position.x - 10, y: player.position.y)
      let ballMove = SKAction.moveBy(x: -200, y: 0, duration: 0.5)
      let ballRemove = SKAction.removeFromParent()
      let ballsequence = SKAction.sequence([ballMove, ballRemove])
      addChild(ball)
      ball.run(ballsequence)
    }
    
  }
  
  func setUpGreenMonster() {
    greenMonster = scrollNode.childNode(withName: "greenMonster") as! SKSpriteNode
    greenMonster.physicsBody = SKPhysicsBody(rectangleOf: greenMonster.size)
    greenMonster.physicsBody?.categoryBitMask = enemyCategory
    greenMonster.physicsBody?.contactTestBitMask = playerCategory

    fox = scrollNode.childNode(withName: "fox") as! SKSpriteNode
    fox.physicsBody = SKPhysicsBody(rectangleOf: fox.size)
    fox.physicsBody?.categoryBitMask = enemyCategory
    fox.physicsBody?.contactTestBitMask = playerCategory

}
  func moveToRight() {
    if rightTouches == true && jump == 0 {
      let names = ["player_a", "player", "player_b"]
      startAnimation(node: player, names: names)
    }
  }
  
  func moveToLeft() {
    if leftTouches == true && jump == 0 {
      let names = ["player_a", "player", "player_b"]
      startAnimation(node: player, names: names)
    }
  }
    
  func startAnimation(node: SKSpriteNode, names: [String]) {
    node.removeAction(forKey: "textureAnimation")
    var ary: [SKTexture] = []
    for name in names {
      ary.append(SKTexture(imageNamed: name))
    }
    let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: true, restore: false)
    let flap = SKAction.repeatForever(action)
    node.run(flap, withKey: "textureAnimation")
  }
  
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    if let touch = touches.first as UITouch! {

      let location = touch.location(in: self)
      beganPos = CGPoint(x: 0, y: 500)
      
      if self.atPoint(location).name == "rightNode" {
        print("rightNode touch")
        rightTouches = true
        player.xScale = fabs(player.xScale)
        beganPos = touch.location(in: self)
        moveToRight()
        rightDirection = true
        leftDirection = false
        
      } else if self.atPoint(location).name == "leftNode" {
        print("leftNode touch")
        leftTouches = true
        player.xScale = fabs(player.xScale) * -1
        beganPos = touch.location(in: self)
        moveToLeft()
        rightDirection = false
        leftDirection = true
        
        } else if self.atPoint(location).name == "jumpNode" && jump == 0 || jump == 1 {
        print("jumpNode touch")
        print(rightTouches)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        jump += 1
        if jump > 0 {
          rightTouches = false
        }
        } else if self.atPoint(location).name == "attackNode" {
        setUpAttack()
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    rightTouches = false
    leftTouches = false
    
    player.removeAction(forKey: "textureAnimation")
    player.texture = SKTexture(imageNamed: "player")

    if let touch = touches.first as UITouch! {
      let location = touch.location(in: self)
      let endedPos: CGPoint = touch.location(in: self)
      // タッチした場所 - 指を離した場所
      let testPos = beganPos.y - endedPos.y

      if self.atPoint(location).name == "rightNode" {
        print("rightNode ended")
        if testPos < -100 && testPos > -200 && jump == 0 {
          player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
          jump = 2

        } else if testPos < -200 && jump == 0 {
          player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
          jump = 3
          
        }
      } else if self.atPoint(location).name == "leftNode" {
        print("leftNode ended")
        if testPos < -100 && testPos > -200 && jump == 0 {
          player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
          jump = -2
          
        } else if testPos < -200 && jump == 0 {
          player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
          jump = -3
          
        }
      }
    }
  }
  
  override func update(_ currentTime: TimeInterval) {

    let player_x: CGFloat = player.position.x
    let player_y: CGFloat = player.position.y
    
    let scroll_x: CGFloat = scrollNode.position.x
    let scroll_y: CGFloat = scrollNode.position.y
    target.position = CGPoint(x: player.position.x, y: target.position.y)
    
    // 右ボタンを押したら
    if rightTouches == true && jump == 0 {

      // プレイヤーを右に動かす
      player.position = CGPoint(x: player_x + 4, y: player_y)
      
      // プレイヤーポジションが真ん中より右だったら
      if player.position.x > 0 {
        // プレイヤーを止める
        player.position = CGPoint(x: player_x, y: player_y)
        // スクロールノードを左に動かす
        scrollNode.position = CGPoint(x: scroll_x - 4, y: scroll_y)

      }// 左ボタンを押したら
    } else if leftTouches == true && jump == 0 {
      // スクロールノードポジションが真ん中より左だったら
      if scrollNode.position.x < 0 {
        // プレイヤーを左に動かす
        player.position = CGPoint(x: player_x - 4, y: player_y)
        // プレイヤーが初期位置より左だったら
        if player.position.x < -256 {
          // プレイヤーを止める
          player.position = CGPoint(x: player_x, y: player_y)
          // スクロールノードを右に動かす
          scrollNode.position = CGPoint(x: scroll_x + 4, y: scroll_y)
        
        }// スクロールノードが初期位置になったらプレイヤーを左に動かす
      } else if scrollNode.position.x >= 0 {
        player.position = CGPoint(x: player_x - 4, y: player_y)
      
      }
    } else if jump == 2 {
      
      player.position = CGPoint(x: player_x + 3, y: player_y)
      
      if player.position.x > 0 {
        
        player.position = CGPoint(x: player_x, y: player_y)
        
        scrollNode.position = CGPoint(x: scroll_x - 3, y: scroll_y)
        
      }
    } else if jump == 3 {
      
      player.position = CGPoint(x: player_x + 5, y: player_y)
      if player.position.x > 0 {
        
        player.position = CGPoint(x: player_x, y: player_y)
        
        scrollNode.position = CGPoint(x: scroll_x - 5, y: scroll_y)
        
      }
    } else if jump == -2 {
      if scrollNode.position.x < 0 {
        player.position = CGPoint(x: player_x - 3, y: player_y)
        
        if player.position.x < -256 {
          player.position = CGPoint(x: player_x, y: player_y)
          scrollNode.position = CGPoint(x: scroll_x + 3, y: scroll_y)
        }
      } else if scrollNode.position.x >= 0 {
        player.position = CGPoint(x: player_x - 3, y: player_y)
        
    }
    } else if jump == -3 {
      if scrollNode.position.x < 0 {
        player.position = CGPoint(x: player_x - 5, y: player_y)
        
        if player.position.x < -256 {
          player.position = CGPoint(x: player_x, y: player_y)
          scrollNode.position = CGPoint(x: scroll_x + 5, y: scroll_y)
        }
      } else if scrollNode.position.x >= 0 {
        player.position = CGPoint(x: player_x - 5, y: player_y)
        
      }
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
      
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
      
    }

    if firstBody.categoryBitMask & playerCategory != 0 && secondBody.categoryBitMask & (floorTheTop.physicsBody?.categoryBitMask)! != 0 {
      moveToRight()
      moveToLeft()
      jump = 0

    } else if firstBody.categoryBitMask & playerCategory != 0 && secondBody.categoryBitMask & enemyCategory != 0 {
      firstBody.node!.removeFromParent()
    } else if firstBody.categoryBitMask & attackCategory != 0 && secondBody.categoryBitMask & enemyCategory != 0 {
      firstBody.node!.removeFromParent()
    }

  }
}
