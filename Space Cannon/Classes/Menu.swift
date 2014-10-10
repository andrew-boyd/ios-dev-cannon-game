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
	
	let musicOnButton = SKSpriteNode(imageNamed: "MusicOffButton")
	let musicOffButton = SKSpriteNode(imageNamed: "MusicOnButton")

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
		playButton.position = CGPointMake(-10, 0)
		self.addChild(playButton)
		
		musicOffButton.position = CGPointMake(75, 0)
		musicOffButton.name = "MusicToggle"
		self.addChild(musicOffButton)
		
		musicOnButton.position = CGPointMake(75, 0)
		musicOnButton.name = "MusicToggle"
		musicOnButton.hidden = true
		self.addChild(musicOnButton)
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
		musicOnButton.alpha = 0
		musicOffButton.alpha = 0
		musicOnButton.runAction(animatePlayButton)
		musicOffButton.runAction(animatePlayButton)
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
	
	func toggleMusic() {
		if musicOnButton.hidden {
			// mute music
			_audioPlayer.volume = 0
			musicOnButton.hidden = false
			musicOffButton.hidden = true
		} else {
			_audioPlayer.volume = 0.1
			musicOnButton.hidden = true
			musicOffButton.hidden = false
		}
	}
}