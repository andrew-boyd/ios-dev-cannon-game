//
//  Ball.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 10/9/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class Ball:SKSpriteNode {
	override init() {
		super.init()
	}
	
	override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	var trail:SKEmitterNode?
	var bounces:Int = 0
	
	func updateTrail() {
		if (self.trail != nil) {
			self.trail!.position = self.position
		}
	}
	
	override func removeFromParent() {
		if (self.trail != nil) {
			self.trail!.particleBirthRate = 0
			
			let removeTrail = SKAction.sequence([
					SKAction.waitForDuration(Double(self.trail!.particleLifetime + self.trail!.particleLifetimeRange)),
					SKAction.removeFromParent()
				])
			self.runAction(removeTrail)
		}
		
		super.removeFromParent()
	}
}