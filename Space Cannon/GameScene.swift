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

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
		
		// Add background
		let background = SKSpriteNode(imageNamed: "Starfield")
		background.position = CGPointMake(0, 0)
		background.anchorPoint = CGPointMake(0, 0)
		background.blendMode = SKBlendMode.Replace
		_mainLayer.addChild(background)
		
		// Add main layer
		_mainLayer.position = CGPointMake(0, 100)
		self.addChild(_mainLayer)
		
		// Add cannon layer
		_cannon.position = CGPointMake(self.size.width/2, 0)
		_mainLayer.addChild(_cannon)
		
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
			
			
			
		}
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
