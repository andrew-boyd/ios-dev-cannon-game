//
//  Halo.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 10/9/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class Halo:SKSpriteNode {
	override init() {
		super.init()
	}
	
	override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var storedVelocity:CGVector?
	
	func updateStoredVelocity() {
		self.storedVelocity = self.physicsBody?.velocity
	}
	
	func forceBounce() {
		self.physicsBody?.velocity.dx = -(storedVelocity!.dx)
		self.updateStoredVelocity()
	}
}