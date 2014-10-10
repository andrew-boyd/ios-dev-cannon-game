//
//  Menu.swift
//  Space Cannon
//
//  Created by Andrew Boyd on 10/7/14.
//  Copyright (c) 2014 Boyd. All rights reserved.
//

import SpriteKit

class Menu:SKNode {
	
	var touchable = true
	
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
		scoreBoard.addChild(scoreLabel)
		
		topScoreLabel.fontSize = 30
		topScoreLabel.position = CGPointMake(48, -20)
		scoreBoard.addChild(topScoreLabel)
		
		title.position = CGPointMake(0, 140)
		self.addChild(title)
		
		scoreBoard.position = CGPointMake(0, 70)
		self.addChild(scoreBoard)
		
		playButton.name = "Play"
		playButton.position = CGPointMake(0, 0)
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
	
	func showMenu() {
		self.hidden = false
		
		let fadeIn = SKAction.fadeInWithDuration(0.5)
		
		title.position = CGPointMake(0, 280)
		title.alpha = 0
		
		let animateTitle = SKAction.group([
			SKAction.moveToY(140, duration: 0.5),
			fadeIn
			])
		animateTitle.timingMode = SKActionTimingMode.EaseOut
		
		title.runAction(animateTitle)
		
		scoreBoard.xScale = 4
		scoreBoard.yScale = 4
		scoreBoard.alpha = 0
		
		let animateScoreBoard = SKAction.group([
				SKAction.scaleTo(1.0, duration: 0.5),
				fadeIn
			])
		scoreBoard.runAction(animateScoreBoard)
		
		playButton.alpha = 0
		let animatePlayButton = SKAction.fadeInWithDuration(1.0)
		animatePlayButton.timingMode = SKActionTimingMode.EaseIn
		playButton.runAction(
			SKAction.sequence([
				animatePlayButton,
				SKAction.runBlock({
					self.touchable = true
				})
			])
		)
	}
	
	func hideMenu() {
		self.touchable = false
		
		let animateMenu = SKAction.scaleTo(0.0, duration: 0.5)
		animateMenu.timingMode = SKActionTimingMode.EaseIn
		
		self.runAction(
			SKAction.sequence([
				animateMenu,
				SKAction.runBlock({
					self.hidden = true
					self.xScale = 1
					self.yScale = 1
				})
			])
		)
	}
}