//
//  GameScene.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 9/28/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

let _mainLayer = SKNode()
let _cannon = SKSpriteNode(imageNamed: "Cannon")

let SHOOT_SPEED = 400.0

func radiansToVector(radians:CGFloat) -> CGVector {
	var vector = CGVector(CGFloat(cosf(Float(radians))), CGFloat(sinf(Float(radians))))
	return vector
}

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
		
		// Disable gravity
		self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
		
		// Add background
		let background = SKSpriteNode(imageNamed: "Starfield")
		background.position = CGPointMake(0, 0)
		background.size = self.size
		background.anchorPoint = CGPointMake(0, 0)
		background.blendMode = SKBlendMode.Replace
		_mainLayer.addChild(background)
		
		// Add main layer
		_mainLayer.position = CGPointMake(0, 0)
		self.addChild(_mainLayer)
		
		// Add cannon layer
		_cannon.position = CGPointMake(self.size.width/2, 0)
		_cannon.size.width = self.size.width/2.5
		_cannon.size.height = self.size.width/2.5
		_mainLayer.addChild(_cannon)
		
		// create cannon rotation actions
		var rotateCannon = SKAction.sequence([
				SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),
				SKAction.rotateByAngle(CGFloat(-M_PI), duration: 2)
			])
		
		_cannon.runAction(SKAction.repeatActionForever(rotateCannon))
    }
	
	func shoot() {
		let ball = SKSpriteNode(imageNamed: "Ball")
		ball.name = "ball"
		let rotationVector = radiansToVector(_cannon.zRotation)
		
		ball.position = CGPointMake(_cannon.position.x + (_cannon.size.width/2.5 * rotationVector.dx),
									_cannon.position.y + (_cannon.size.width/2.5 * rotationVector.dy))
		ball.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
		
		let x_speed = CGFloat(Double(rotationVector.dx) * SHOOT_SPEED)
		let y_speed = CGFloat(Double(rotationVector.dy) * SHOOT_SPEED)
		
		ball.physicsBody?.velocity = CGVectorMake(x_speed, y_speed)
		
		_mainLayer.addChild(ball)
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
			
			shoot()
			
		}
    }
	
	override func didSimulatePhysics() {
		_mainLayer.enumerateChildNodesWithName("ball") {
			node, stop in
			if ( !CGRectContainsPoint(self.frame, node.position) ) {
				node.removeFromParent()
			}
		}
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
