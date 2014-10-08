//
//  Menu.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 10/7/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class Menu: SKNode {
	
	var score:Int = 0
	var topScore:Int = 0
	
	let scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
	let topScoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
	
	let title = SKSpriteNode(imageNamed: "Title")
	let scoreBoard = SKSpriteNode(imageNamed: "ScoreBoard")
	let playButton = SKSpriteNode(imageNamed: "PlayButton")

	override init() {
		super.init()
		
		scoreLabel.fontSize = 30
		scoreLabel.position = CGPointMake(-52, -20)
		self.addChild(scoreLabel)
		
		topScoreLabel.fontSize = 30
		topScoreLabel.position = CGPointMake(48, -20)
		self.addChild(topScoreLabel)
		
		title.position = CGPointMake(0, 140)
		self.addChild(title)
		
		title.position = CGPointMake(0, 70)
		self.addChild(scoreBoard)
		
		playButton.name = "Play"
		playButton.position = CGPointMake(0, -70)
		self.addChild(playButton)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setScore(score:Int) {
		self.score = score
		scoreLabel.text = String(self.score)
	}
	
	func setTopScore(topScore:Int) {
		self.topScore = topScore
		topScoreLabel.text = String(self.topScore)
	}
}