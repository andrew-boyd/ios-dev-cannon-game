//
//  GameScene.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 9/28/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

func radiansToVector(radians:CGFloat) -> CGVector {
	var vector = CGVector(dx: CGFloat(cosf(Float(radians))), dy: CGFloat(sinf(Float(radians))))
	return vector
}
func randomInRange(low:CGFloat, high:CGFloat) -> CGFloat {
	var randomAssNumber = low + CGFloat(arc4random()) % (high - low);
	return CGFloat(randomAssNumber)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	let _mainLayer = SKNode()
	let _cannon = SKSpriteNode(imageNamed: "Cannon")
	var _ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
	var _scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
	var ammo = 5
	var _score = 0
	let SHOOT_SPEED = 1000.0
	let HaloLowAngle = CGFloat(200 * M_PI / 180.0)
	let HaloMaxAngle = CGFloat(340 * M_PI / 180.0)
	let HaloSpeed:CGFloat = 100.0

	var _menu = Menu()
	
	let bounceSound = SKAction.playSoundFileNamed("Bounce.caf", waitForCompletion: false)
	let explosionSound = SKAction.playSoundFileNamed("Explosion.caf", waitForCompletion: false)
	let deepExplosionSound = SKAction.playSoundFileNamed("DeepExplosion.caf", waitForCompletion: false)
	let laserSound = SKAction.playSoundFileNamed("Laser.caf", waitForCompletion: false)
	let zapSound = SKAction.playSoundFileNamed("Zap.caf", waitForCompletion: false)
	
	let HaloCategory:UInt32 = 0x1 << 0;
	let BallCategory:UInt32 = 0x1 << 1;
	let EdgeCategory:UInt32 = 0x1 << 2;
	let ShieldCategory:UInt32 = 0x1 << 3;
	let LifeBarCategory:UInt32 = 0x1 << 4;
	
	var _didShoot = false
	var _gameOver = true
	
    override func didMoveToView(view: SKView) {
		
		// Disable gravity
		self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
		self.physicsWorld.contactDelegate = self
		
		// Add background
		let background = SKSpriteNode(imageNamed: "Starfield")
		background.position = CGPointMake(0, 0)
		background.size = self.size
		background.anchorPoint = CGPointMake(0, 0)
		background.blendMode = SKBlendMode.Replace
		self.addChild(background)
		
		// Add Edges
		let leftEdge = SKNode()
		leftEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height * 2))
		leftEdge.position = CGPointMake(5.0, 0.0)
		leftEdge.zPosition = 3
		leftEdge.physicsBody?.categoryBitMask = EdgeCategory
		
		let rightEdge = SKNode()
		rightEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height * 2))
		rightEdge.position = CGPointMake(self.size.width - 5.0, 0.0)
		rightEdge.zPosition = 3
		rightEdge.physicsBody?.categoryBitMask = EdgeCategory
		
		self.addChild(leftEdge)
		self.addChild(rightEdge)
		
		// Add main layer
		_mainLayer.position = CGPointMake(0, 0)
		self.addChild(_mainLayer)
		
		// Add cannon layer
		_cannon.position = CGPointMake(self.size.width/2, 0)
		_cannon.size.width = self.size.width/2.5
		_cannon.size.height = self.size.width/2.5
		self.addChild(_cannon)
		
		// add ammo display
		_ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0)
		_ammoDisplay.position = _cannon.position
		self.addChild(_ammoDisplay)
		
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
		
		// refill Ammo
		let incrementAmmo = SKAction.sequence([
				SKAction.waitForDuration(1),
				SKAction.runBlock({ () -> Void in
					if self.ammo < 5 {
						self.ammo++
						self.updateAmmo()
					}
				}),
			])
		self.runAction(SKAction.repeatActionForever(incrementAmmo))
		
		// setup score display
		_scoreLabel.position = CGPointMake(15, 10)
		_scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		_scoreLabel.fontSize = 15
		self.addChild(_scoreLabel)
		
		// setup Menu
		_menu.position = CGPointMake(self.size.width/2, self.size.height - 220)
		_menu.zPosition = 10
		self.addChild(_menu)
		
		// set initial values
		var ammo = 5
		updateAmmo()
		setScore(0)
		_menu.setScore(0)
		_menu.setTopScore(_menu.topScore)
		_scoreLabel.hidden = true
	}
	
	func newGame() {
		_gameOver = false
		_menu.hidden = true
		_scoreLabel.hidden = false
		var ammo = 5
		updateAmmo()
		setScore(0)
		
		_mainLayer.removeAllChildren()
		
		//setup shields
		for (var i = 0; i < 6; i++) {
			var shield = SKSpriteNode(imageNamed: "Block")
			shield.name = "shield"
			shield.size.width = self.size.width/6
			shield.position = CGPointMake(CGFloat(self.size.width/12 + (shield.size.width * CGFloat(i))), _cannon.size.height/2 + 15.0)
			shield.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: shield.size.width*0.75, height: shield.size.height*0.75))
			shield.physicsBody?.categoryBitMask = ShieldCategory
			shield.physicsBody?.collisionBitMask = 0
			_mainLayer.addChild(shield)
		}
		
		// add life bar
		let lifeBar = SKSpriteNode(imageNamed: "BlueBar")
		lifeBar.position = CGPointMake(self.size.width/2, _cannon.size.height/2)
		lifeBar.size.width = self.size.width
		lifeBar.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-lifeBar.size.width/2, 0), toPoint: CGPointMake(lifeBar.size.width/2, 0))
		lifeBar.physicsBody?.categoryBitMask = LifeBarCategory
		_mainLayer.addChild(lifeBar)
	}
	
	func shoot() {
		if self.ammo > 0 {
			self.ammo -= 1
			updateAmmo()
			
			self.runAction(laserSound)
			
			let ball = SKSpriteNode(imageNamed: "Ball")
			ball.name = "ball"
			let rotationVector = radiansToVector(_cannon.zRotation)
			
			ball.position = CGPointMake(_cannon.position.x + (_cannon.size.width/2.5 * rotationVector.dx),
										_cannon.position.y + (_cannon.size.width/2.5 * rotationVector.dy))
			ball.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
			
			let x_speed = CGFloat(Double(rotationVector.dx) * SHOOT_SPEED)
			let y_speed = CGFloat(Double(rotationVector.dy) * SHOOT_SPEED)
			ball.physicsBody?.velocity = CGVectorMake(x_speed, y_speed)
			ball.size.width = self.size.width/12
			ball.size.height = self.size.width/12
			ball.physicsBody?.restitution = 1.0
			ball.physicsBody?.linearDamping = 0.0
			ball.physicsBody?.friction = 0.0
			ball.physicsBody?.categoryBitMask = BallCategory
			ball.physicsBody?.collisionBitMask = EdgeCategory
			ball.physicsBody?.contactTestBitMask = EdgeCategory
			
			_mainLayer.addChild(ball)
		}
	}
	
	func updateAmmo() {
		if self.ammo >= 0 && self.ammo <= 5 {
			let ammoTextureName = "Ammo" + String(self.ammo)
			_ammoDisplay.texture = SKTexture(imageNamed: ammoTextureName)
		}
	}

	func setScore(score:Int) {
		_score = score
		_scoreLabel.text = "Score: " + String(_score)
	}
	
	func spawnHalo() {
		let halo = SKSpriteNode(imageNamed: "Halo")
		halo.name = "halo"
		halo.position = CGPointMake(
			randomInRange(halo.size.width/2, self.size.width - (halo.size.width/2)),
			self.size.height + (halo.size.width/2)
		)
		halo.physicsBody = SKPhysicsBody(circleOfRadius: 16)
		var direction = radiansToVector(randomInRange(HaloLowAngle, HaloMaxAngle))
		halo.size.width = self.size.width/8
		halo.size.height = self.size.width/8
		halo.physicsBody?.velocity = CGVectorMake(direction.dx * HaloSpeed, direction.dy * HaloSpeed)
		halo.physicsBody?.restitution = 1.0
		halo.physicsBody?.linearDamping = 0.0
		halo.physicsBody?.friction = 0.0
		halo.physicsBody?.categoryBitMask = HaloCategory
		halo.physicsBody?.collisionBitMask = EdgeCategory
		halo.physicsBody?.contactTestBitMask = BallCategory | EdgeCategory | ShieldCategory | LifeBarCategory
		_mainLayer.addChild(halo)
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		var firstBody:SKPhysicsBody
		var secondBody:SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == EdgeCategory {
			// collision between ball and wall
			self.addExplosion(contact.contactPoint, name: "EdgeHit")
			self.runAction(bounceSound)
		}
		if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == EdgeCategory {
			// collision between halo and wall
			self.runAction(zapSound)
			
		}
		if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == BallCategory {
			// collision between halo and ball
			self.addExplosion(firstBody.node!.position, name: "HaloExplosion")
			self.runAction(explosionSound)
			setScore(_score + 1)
			firstBody.node?.removeFromParent()
			secondBody.node?.removeFromParent()
		}
		if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == ShieldCategory {
			// collision between halo and shield
			self.addExplosion(contact.contactPoint, name: "HaloExplosion")
			self.runAction(explosionSound)
			firstBody.node?.removeFromParent()
			secondBody.node?.removeFromParent()
		}
		if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == LifeBarCategory {
			// collision between halo and lifeBar
			self.addExplosion(secondBody.node!.position, name: "LifeBarExplosion")
			self.runAction(deepExplosionSound)
			secondBody.node?.removeFromParent()
			
			gameOver()
		}
	}
	
	func addExplosion(position:CGPoint, name:String) {
		let explosionPath:String = NSBundle.mainBundle().pathForResource(name, ofType: "sks")!
		let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath) as SKEmitterNode
		explosion.position = position;
		_mainLayer.addChild(explosion)
		
		let removeExplosion = SKAction.sequence([
				SKAction.waitForDuration(1.5),
				SKAction.removeFromParent()
			])
		explosion.runAction(removeExplosion)
	}
	
	func gameOver() {
		_mainLayer.enumerateChildNodesWithName("halo") { node, stop in
			self.addExplosion(node.position, name: "HaloExplosion")
			node.removeFromParent()
		}
		_mainLayer.enumerateChildNodesWithName("ball") { node, stop in
			node.removeFromParent()
		}
		_mainLayer.enumerateChildNodesWithName("shield") { node, stop in
			node.removeFromParent()
		}
		
		_menu.hidden = false
		_scoreLabel.hidden = true
		_gameOver = true
		_menu.setScore(_score)
		
		if _score > _menu.topScore {
			_menu.setTopScore(_score)
		}
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
			if !(_gameOver) {
				_didShoot = true
			}
		}
    }
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		for touch:AnyObject in touches {
			if _gameOver {
				var n = _menu.nodeAtPoint(touch.locationInNode(_menu))
				
				if n.name == "Play" {
					self.newGame()
				}
			}
		}
	}
	
	override func didSimulatePhysics() {
		
		if (_didShoot) {
			shoot()
			_didShoot = false
		}
		
		_mainLayer.enumerateChildNodesWithName("ball") {
			node, stop in
			if !CGRectContainsPoint(self.frame, node.position) {
				node.removeFromParent()
			}
		}
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
