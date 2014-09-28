//
//  GameScene.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 9/28/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	let _mainLayer = SKNode()
	let _cannon = SKSpriteNode(imageNamed: "Cannon")
	let SHOOT_SPEED = 1000.0
	let HaloLowAngle = CGFloat(200 * M_PI / 180.0)
	let HaloMaxAngle = CGFloat(340 * M_PI / 180.0)
	let HaloSpeed:CGFloat = 100.0
	var _didShoot = false
	
	func radiansToVector(radians:CGFloat) -> CGVector {
		var vector = CGVector(CGFloat(cosf(Float(radians))), CGFloat(sinf(Float(radians))))
		return vector
	}
	
	func randomInRange(low:CGFloat, high:CGFloat) -> CGFloat {
		var randomAssNumber = low + CGFloat(arc4random()) % (high - low);
		return CGFloat(randomAssNumber)
	}
	
	func spawnHalo() {
		let halo = SKSpriteNode(imageNamed: "Halo")
		halo.position = CGPointMake(
			randomInRange(halo.size.width/2, high: self.size.width - (halo.size.width/2)),
			self.size.height + (halo.size.width/2)
		)
		
		halo.physicsBody = SKPhysicsBody(circleOfRadius: 16)
		var direction = radiansToVector(randomInRange(HaloLowAngle, high: HaloMaxAngle))
		halo.physicsBody?.velocity = CGVectorMake(direction.dx * HaloSpeed, direction.dy * HaloSpeed)
		halo.physicsBody?.restitution = 1.0
		halo.physicsBody?.linearDamping = 0.0
		halo.physicsBody?.friction = 0.0
		
		self.addChild(halo)
	}
	
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
		
		// Add Edges
		let leftEdge = SKNode()
		let rightEdge = SKNode()
		leftEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height * 2))
		rightEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height * 2))
		leftEdge.position = CGPointZero
		rightEdge.position = CGPointMake(self.size.width, 0.0)
		
		self.addChild(leftEdge)
		self.addChild(rightEdge)
		
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
		
		// create spawn halo actions
		let spawnHaloAction = SKAction.sequence([
				SKAction.waitForDuration(2.0),
				SKAction.runBlock(spawnHalo)
			])
		
		self.runAction(SKAction.repeatActionForever(spawnHaloAction))
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
		ball.physicsBody?.restitution = 1.0
		ball.physicsBody?.linearDamping = 0.0
		ball.physicsBody?.friction = 0.0
		
		_mainLayer.addChild(ball)
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
			_didShoot = true
		}
		
		spawnHalo()
    }
	
	override func didSimulatePhysics() {
		
		if (_didShoot) {
			shoot()
			_didShoot = false
		}
		
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
