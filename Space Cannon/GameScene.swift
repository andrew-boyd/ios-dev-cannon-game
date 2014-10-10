//
//  GameScene.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 9/28/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit
import AVFoundation

// global helper functions
func radiansToVector(radians:CGFloat) -> CGVector {
	var vector = CGVector(dx: CGFloat(cosf(Float(radians))), dy: CGFloat(sinf(Float(radians))))
	return vector
}
func randomInRange(low:CGFloat, high:CGFloat) -> CGFloat {
	var randomAssNumber = low + CGFloat(arc4random()) % (high - low);
	return CGFloat(randomAssNumber)
}

// music player
let _audioPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("ObservingTheStar", withExtension: "caf"), error: nil)

// global variables we need to access across classes
var _gameOver = true
var _activeHaloCount:Int = 0
var _multishotMode = false
var _activeBomb:Bool = false

let _pauseButton = SKSpriteNode(imageNamed: "PauseButton")
let _resumeButton = SKSpriteNode(imageNamed: "ResumeButton")
var _gamePaused:Bool = false {
	didSet {
		if !_gameOver {
			_pauseButton.hidden = _gamePaused
			_resumeButton.hidden = !_gamePaused
		}
	}
}

var _scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")

// this variable is a calculated value and can have
// willSet and didSet functions
var _score:Int = 0 {
	// function that runs after the calulated value of
	// the _score variable is set in Swift.
	didSet {
		_scoreLabel.text = "Score: " + String(_score)
	}
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// game variables that can stay in our scene
	let userDefaults = NSUserDefaults.standardUserDefaults()
	let _mainLayer = SKNode()
	let _cannon = SKSpriteNode(imageNamed: "Cannon")
	var _ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
	var _pointLabel = SKLabelNode(fontNamed: "DIN Alternate")
	var keyTopScore = "TopScore"
	
	var _shieldPool = [SKNode]()
	
	var pointValue:Int = 1 {
		didSet {
			_pointLabel.text = "Multiplier: " + String(pointValue)
		}
	}
	
	var ammo:Int = 5 {
		didSet {
			if self.ammo < 0 {
				self.ammo = 0
			}
			if self.ammo >= 0 && self.ammo <= 5 {
				let ammoTextureName = "Ammo" + String(self.ammo)
				_ammoDisplay.texture = SKTexture(imageNamed: ammoTextureName)
			}
		}
	}
	
	// mutishot powerup variables
	var _killCount:Int = 0 {
		didSet {
			if _killCount >= _multishotTargetKillCount {
				_multishotTargetKillCount += 20
				spawnMultishotPowerUp()
			}
		}
	}
	var _multishotTargetKillCount:Int = 15
	
	// canonball settings
	let SHOOT_SPEED = 1000.0
	
	// halo generation settings
	let HaloLowAngle = CGFloat(200 * M_PI / 180.0)
	let HaloMaxAngle = CGFloat(340 * M_PI / 180.0)
	let HaloSpeed:CGFloat = 100.0

	// instantiate the menu
	var _menu = Menu()
	
	// preload sounds as variables we can reference to avoid delays on load
	let bounceSound = SKAction.playSoundFileNamed("Bounce.caf", waitForCompletion: false)
	let explosionSound = SKAction.playSoundFileNamed("Explosion.caf", waitForCompletion: false)
	let deepExplosionSound = SKAction.playSoundFileNamed("DeepExplosion.caf", waitForCompletion: false)
	let laserSound = SKAction.playSoundFileNamed("Laser.caf", waitForCompletion: false)
	let zapSound = SKAction.playSoundFileNamed("Zap.caf", waitForCompletion: false)
	let shieldUpSound = SKAction.playSoundFileNamed("ShieldUp.caf", waitForCompletion: false)
	
	// set bitmask categories for our assets
	let HaloCategory:UInt32      = 0x1 << 0;
	let BallCategory:UInt32      = 0x1 << 1;
	let EdgeCategory:UInt32      = 0x1 << 2;
	let ShieldCategory:UInt32    = 0x1 << 3;
	let LifeBarCategory:UInt32   = 0x1 << 4;
	let ShieldUpCategory:UInt32  = 0x1 << 5;
	let MultishotCategory:UInt32 = 0x1 << 6;
	
	// helper variable to be set when we shoot.
	// actual shot fires at end of frame to avoid
	// player perception of lagging behind cannon aim
	var _didShoot = false
	
    override func didMoveToView(view: SKView) {
		
		// background music
		_audioPlayer.numberOfLoops = -1
		_audioPlayer.volume = 0.1
		_audioPlayer.play()
		
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
		
		// setup shield pool
		// setup shields
		for (var i = 0; i < 6; i++) {
			var shield = SKSpriteNode(imageNamed: "Block")
			shield.name = "shield"
			shield.size.width = self.size.width/6
			shield.position = CGPointMake(CGFloat(self.size.width/12 + (shield.size.width * CGFloat(i))), _cannon.size.height/2 + 15.0)
			shield.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: shield.size.width*0.75, height: shield.size.height*0.75))
			shield.physicsBody?.categoryBitMask = ShieldCategory
			shield.physicsBody?.collisionBitMask = 0
			_shieldPool.append(shield)
		}
		
		// create cannon rotation actions
		var rotateCannon = SKAction.sequence([
				SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),
				SKAction.rotateByAngle(CGFloat(-M_PI), duration: 2)
			])
		
		_cannon.runAction(SKAction.repeatActionForever(rotateCannon))
		
		// create spawn halo actions
		let spawnHaloAction = SKAction.sequence([
				SKAction.waitForDuration(2.0, withRange: 1.0),
				SKAction.runBlock(spawnHalo)
			])
		self.runAction(SKAction.repeatActionForever(spawnHaloAction), withKey: "spawnHalo")
		
		// create spawn shield powerup
		let spawnShieldUpAction = SKAction.sequence([
				SKAction.waitForDuration(25.0, withRange: 5.0),
				SKAction.runBlock(spawnShieldPowerUp)
			])
		self.runAction(SKAction.repeatActionForever(spawnShieldUpAction))

		// refill Ammo
		let incrementAmmo = SKAction.sequence([
				SKAction.waitForDuration(1),
				SKAction.runBlock({ () -> Void in
					if self.ammo < 5 && !_multishotMode {
						self.ammo++
					}
				}),
			])
		self.runAction(SKAction.repeatActionForever(incrementAmmo))
		
		// set up pause button
		_pauseButton.position = CGPoint(x: self.size.width - 30, y: 20)
		self.addChild(_pauseButton)
		
		//set up resume button
		_resumeButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		self.addChild(_resumeButton)
		
		// setup score display
		_scoreLabel.position = CGPointMake(15, 10)
		_scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		_scoreLabel.fontSize = 15
		self.addChild(_scoreLabel)
		
		// setup point value display
		_pointLabel.position = CGPointMake(15, 30)
		_pointLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		_pointLabel.fontSize = 15
		self.addChild(_pointLabel)
		
		// setup Menu
		_menu.position = CGPointMake(self.size.width/2, self.size.height - 220)
		_menu.zPosition = 10
		self.addChild(_menu)
		
		// load top score
		_menu.topScore = userDefaults.integerForKey(keyTopScore)
		
		// set initial values
		var ammo = 5
		_score = 0
		pointValue = 1
		_menu.setScore(0)
		_menu.setTopScore(_menu.topScore)
		_scoreLabel.hidden = true
		_pointLabel.hidden = true
		_pauseButton.hidden = true
		_resumeButton.hidden = true
	}
	
	func newGame() {
		_mainLayer.removeAllChildren()
		
		// set initial values
		self.actionForKey("spawnHalo")?.speed = 1
		_gameOver = false
		_menu.hideMenu()
		_scoreLabel.hidden = false
		_pointLabel.hidden = false
		var ammo = 5
		_score = 0
		pointValue = 1
		disableMultishotMode()
		_killCount = 0
		_pauseButton.hidden = false
		
		// add shields to game
		while _shieldPool.count > 0 {
			_mainLayer.addChild(_shieldPool[0])
			_shieldPool.removeAtIndex(0)
		}
		
		// setup life bar
		let lifeBar = SKSpriteNode(imageNamed: "BlueBar")
		lifeBar.position = CGPointMake(self.size.width/2, _cannon.size.height/2)
		lifeBar.size.width = self.size.width
		lifeBar.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-lifeBar.size.width/2, 0), toPoint: CGPointMake(lifeBar.size.width/2, 0))
		lifeBar.physicsBody?.categoryBitMask = LifeBarCategory
		_mainLayer.addChild(lifeBar)
	}
	
	func shoot() {
		if _multishotMode && self.ammo > 0 {
			let multishotAction = SKAction.sequence([
				SKAction.waitForDuration(0.1),
				SKAction.runBlock(fireShot)
				])
			self.runAction(SKAction.repeatAction(multishotAction, count: 5))
		} else if self.ammo > 0 {
			fireShot()
		}
		
		self.ammo -= 1
		
		if ammo == 0 && _multishotMode {
			disableMultishotMode()
		}
	}
	
	func fireShot() {
		self.runAction(laserSound)
		
		let ball = Ball(imageNamed: "Ball")
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
		ball.physicsBody?.usesPreciseCollisionDetection = true
		ball.physicsBody?.categoryBitMask = BallCategory
		ball.physicsBody?.collisionBitMask = EdgeCategory
		ball.physicsBody?.contactTestBitMask = EdgeCategory | ShieldUpCategory | MultishotCategory
		
		// create trail for ball
		let ballTrailPath = NSBundle.mainBundle().pathForResource("BallTrail", ofType: "sks")!
		let ballTrail = NSKeyedUnarchiver.unarchiveObjectWithFile(ballTrailPath) as SKEmitterNode
		ballTrail.targetNode = _mainLayer
		ball.trail = ballTrail
		_mainLayer.addChild(ballTrail)
		
		_mainLayer.addChild(ball)
	}
	
	func spawnHalo() {
		// inscrease spawn speed
		let spawnHaloAction = self.actionForKey("spawnHalo")
		
		if spawnHaloAction?.speed < 2.75 {
			spawnHaloAction?.speed = 1.0 + CGFloat(_score)/100.00
		}
		
		if _gameOver {
			spawnHaloAction?.speed = 1.0
		}
		
		let halo = Halo()
		halo.name = "halo"
		halo.position = CGPointMake(
			randomInRange(halo.size.width + 10, self.size.width - (halo.size.width + 10)),
			self.size.height + 100
		)
		halo.physicsBody = SKPhysicsBody(circleOfRadius: 16)
		var direction = radiansToVector(randomInRange(HaloLowAngle, HaloMaxAngle))
		halo.size.width = self.size.width/8
		halo.size.height = self.size.width/8
		halo.physicsBody?.velocity = CGVectorMake(direction.dx * HaloSpeed, direction.dy * HaloSpeed)
		halo.updateStoredVelocity()
		halo.physicsBody?.restitution = 1.0
		halo.physicsBody?.linearDamping = 0.0
		halo.physicsBody?.friction = 0.0
		halo.physicsBody?.categoryBitMask = HaloCategory
		halo.physicsBody?.collisionBitMask = EdgeCategory
		halo.physicsBody?.contactTestBitMask = BallCategory | EdgeCategory | ShieldCategory | LifeBarCategory
		_mainLayer.addChild(halo)
	}
	
	func spawnShieldPowerUp() {
		if _shieldPool.count > 0 {
			var shieldUp = SKSpriteNode(imageNamed: "Block")
			shieldUp.name = "shieldUp"
			shieldUp.size.width = self.size.width/6
			shieldUp.position = CGPointMake(self.size.width + shieldUp.size.width, randomInRange(150, self.size.height - 100))
			shieldUp.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: shieldUp.size.width*0.75, height: shieldUp.size.height*0.75))
			shieldUp.physicsBody?.categoryBitMask = ShieldUpCategory
			shieldUp.physicsBody?.collisionBitMask = 0
			shieldUp.physicsBody?.velocity = CGVectorMake(-60, randomInRange(-40, 40))
			shieldUp.physicsBody?.angularVelocity = CGFloat(M_PI)
			shieldUp.physicsBody?.linearDamping = 0
			shieldUp.physicsBody?.angularDamping = 0
			_mainLayer.addChild(shieldUp)
		}
	}

	func spawnMultishotPowerUp() {
		var multishot = SKSpriteNode(imageNamed: "MultiShotPowerUp")
		multishot.name = "shieldUp"
		multishot.size.width = self.size.width/8
		multishot.size.height = self.size.width/8
		multishot.position = CGPointMake(-multishot.size.width, randomInRange(150, self.size.height - 100))
		multishot.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: multishot.size.width*0.75, height: multishot.size.height*0.75))
		multishot.physicsBody?.categoryBitMask = MultishotCategory
		multishot.physicsBody?.collisionBitMask = 0
		multishot.physicsBody?.velocity = CGVectorMake(90, randomInRange(-40, 40))
		multishot.physicsBody?.angularVelocity = CGFloat(M_PI)
		multishot.physicsBody?.linearDamping = 0
		multishot.physicsBody?.angularDamping = 0
		_mainLayer.addChild(multishot)
	}
	
	func enableMultishotMode() {
		_multishotMode = true
		ammo = 5
		_cannon.texture = SKTexture(imageNamed: "GreenCannon")
	}
	
	func disableMultishotMode() {
		_multishotMode = false
		ammo = 5
		_cannon.texture = SKTexture(imageNamed: "Cannon")
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		var firstBody = SKPhysicsBody()
		var secondBody = SKPhysicsBody()
		
		if contact.bodyA? != nil && contact.bodyB? != nil {
			if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
				firstBody = contact.bodyA
				secondBody = contact.bodyB
			} else {
				firstBody = contact.bodyB
				secondBody = contact.bodyA
			}
		}
			
		if firstBody.node? != nil && secondBody.node? != nil {
		
			if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == EdgeCategory {
				// collision between ball and wall
				var ballNode = firstBody.node as Ball
				
				self.addExplosion(contact.contactPoint, name: "EdgeHit")
				self.runAction(bounceSound)
				
				ballNode.bounces++
				if ballNode.bounces > 3 {
					self.pointValue = 1
					ballNode.hidden = true
				}
			}
			if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ShieldUpCategory {
				// collision between ball and shield powerup
				if (_shieldPool.count > 0) {
					while _shieldPool.count > 0 {
						_mainLayer.addChild(_shieldPool[0])
						_shieldPool.removeAtIndex(0)
					}
				}
				
				self.runAction(shieldUpSound)
				secondBody.node?.removeFromParent()
			}
			if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == MultishotCategory {
				// collision between ball and multishot powerup
				self.runAction(shieldUpSound)
				enableMultishotMode()
				secondBody.node?.removeFromParent()
			}
			if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == EdgeCategory {
				// collision between halo and wall
				let haloNode = firstBody.node as Halo
				haloNode.forceBounce()
				self.runAction(zapSound)
			}
			if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == BallCategory {
				// collision between halo and ball
				_score += self.pointValue
				_killCount += 1
				
				let haloNode = firstBody.node as Halo
				
				if haloNode.userData?.valueForKey("Multiplier") != nil {
					if haloNode.userData?.valueForKey("Multiplier") as Bool {
						self.pointValue++
					}
				} else if haloNode.userData?.valueForKey("isBomb") != nil {
					if haloNode.userData?.valueForKey("isBomb") as Bool {
						_mainLayer.enumerateChildNodesWithName("halo") {
							node, stop in
							
							// give points for all on screen halos
							_score += self.pointValue
							self._killCount += 1
							
							self.addExplosion(node.position, name: "HaloExplosion")
							node.removeFromParent()
						}
						
						// compensate for adding score and kill twice
						_killCount -= 1
						_score -= self.pointValue
					}
				}
				
				// only allow 1 collision
				firstBody.categoryBitMask = 0
				
				self.addExplosion(firstBody.node!.position, name: "HaloExplosion")
				self.runAction(explosionSound)
				firstBody.node?.removeFromParent()
				secondBody.node?.hidden = true
			}
			if firstBody.categoryBitMask == HaloCategory && secondBody.categoryBitMask == ShieldCategory {
				// collision between halo and shield
				self.addExplosion(contact.contactPoint, name: "HaloExplosion")
				self.runAction(explosionSound)
				
				// check if hit by bomb and remove all shields
				let haloNode = firstBody.node as Halo
				if haloNode.userData?.valueForKey("isBomb") != nil {
					if haloNode.userData?.valueForKey("isBomb") as Bool {
						_mainLayer.enumerateChildNodesWithName("shield") { node, stop in
							self.addExplosion(node.position, name: "HaloExplosion")
							
							// add removed shields back to shield pool
							self._shieldPool.append(node)
							node.removeFromParent()
						}
					}
				} else {
					_shieldPool.append(secondBody.node!)
				}
				
				// only destroy one shield
				firstBody.categoryBitMask = 0
				
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
			self._shieldPool.append(node)
			node.removeFromParent()
		}
		_mainLayer.enumerateChildNodesWithName("shieldUp") { node, stop in
			node.removeFromParent()
		}
		
		runAction(
			SKAction.sequence([
				SKAction.waitForDuration(1),
				SKAction.runBlock({ () -> Void in
					self._menu.showMenu()
				})
			])
		)
		
		_scoreLabel.hidden = true
		_pointLabel.hidden = true
		_gameOver = true
		_menu.setScore(_score)
		_pauseButton.hidden = true
		
		if _score > _menu.topScore {
			_menu.setTopScore(_score)
			userDefaults.setInteger(_score, forKey: keyTopScore)
			userDefaults.synchronize()
		}
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
			if !_gameOver && !_gamePaused  {
				if !(_pauseButton.containsPoint(touch.locationInNode(_pauseButton.parent))) {
					_didShoot = true
				}
			}
		}
    }
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		for touch:AnyObject in touches {
			if _gameOver && _menu.touchable {
				var n = _menu.nodeAtPoint(touch.locationInNode(_menu))
				
				if n.name == "Play" {
					self.newGame()
				} else if n.name == "MusicToggle" {
					_menu.toggleMusic()
				}
			} else if !_gameOver {
				if _gamePaused {
					if _resumeButton.containsPoint(touch.locationInNode(_resumeButton.parent)) {
						_gamePaused = false
					}
				} else {
					if _pauseButton.containsPoint(touch.locationInNode(_pauseButton.parent)) {
						_gamePaused = true
					}
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
			
			let node = node as Ball
			
			node.updateTrail()
			
			if node.hidden == true {
				node.removeFromParent()
			}
			
			if !CGRectContainsPoint(self.frame, node.position) {
				node.removeFromParent()
				self.pointValue = 1
			}
		}
		
		// reset halo count because below loop will recount
		_activeHaloCount = 0
		_activeBomb = false
		_mainLayer.enumerateChildNodesWithName("halo") {
			node, stop in
			
			let node = node as Halo
			
			_activeHaloCount++
			
			// check if a bomb is on screen
			if node.userData?.valueForKey("isBomb") != nil {
				if node.userData?.valueForKey("isBomb") as Bool {
					//reset bomb flag
					_activeBomb = true
				}
			}

			if (node.position.y + node.frame.size.height < 0) {
				node.removeFromParent()
			}
		}
		
		_mainLayer.enumerateChildNodesWithName("shieldUp") {
			node, stop in
			
			if node.position.x + node.frame.size.width < 0 {
				node.removeFromParent()
			}
		}

	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
		self.paused = _gamePaused
    }
}
