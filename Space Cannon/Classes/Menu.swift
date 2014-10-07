//
//  Menu.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 10/7/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class Menu: SKNode {
	override init() {
		super.init()
		
		let title = SKSpriteNode(imageNamed: "Title")
		title.position = CGPointMake(0, 140)
		self.addChild(title)
		
		let scoreBoard = SKSpriteNode(imageNamed: "ScoreBoard")
		title.position = CGPointMake(0, 70)
		self.addChild(scoreBoard)
		
		let playButton = SKSpriteNode(imageNamed: "PlayButton")
		playButton.name = "Play"
		playButton.position = CGPointMake(0, -70)
		self.addChild(playButton)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}