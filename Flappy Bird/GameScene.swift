import UIKit
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	var bird = SKSpriteNode()
	
	var bg = SKSpriteNode()
	
	var scoreLabel = SKLabelNode()
	
	var score = 0
	
	var gameOverLabel = SKLabelNode()
	
	var gameStartLabel = SKLabelNode()
	
	var timer = Timer()
	
	var gameBackgroundMusic: SKAudioNode!
	
	var sound = SKAction.playSoundFileNamed("sfx_point.wav" , waitForCompletion: true)

	var sound2 = SKAction.playSoundFileNamed("sfx_die.wav" , waitForCompletion: true)
	
	enum ColliderType: UInt32 {
		
		case Bird = 1
		case Object = 2
		case Gap = 4
		
	}
	
	var gameOver = false
	
// DONT MAKE PIPES WHILE GAME IS PAUSED OR SCENE IS STOPPED
	
	@objc func checkTimer() {
		
		if self.speed == 1 {
			
			if isPaused == false {
				
				self.makePipes()
				
			}
		}
	}
	
	func makePipes() {
		
		let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
		let removePipes = SKAction.removeFromParent()
		let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
		
		let gapHeight = bird.size.height * 4
		
		let movementAmount = arc4random() % UInt32(self.frame.height / 2)
		
		let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
		
		let pipeTexture = SKTexture(imageNamed: "pipe1.png")
		
		let pipe1 = SKSpriteNode(texture: pipeTexture)
		
		pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
		
		pipe1.run(moveAndRemovePipes)
		
		pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
		pipe1.physicsBody!.isDynamic = false
		
		pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
		pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
		pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
		
		pipe1.zPosition = -1
		
		self.addChild(pipe1)
		
		let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
		
		let pipe2 = SKSpriteNode(texture: pipe2Texture)
		
		pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
		
		pipe2.run(moveAndRemovePipes)
		
		pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
		pipe2.physicsBody!.isDynamic = false
		
		pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
		pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
		pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
		
		pipe2.zPosition = -1
		
		self.addChild(pipe2)
		
		let gap = SKNode()
		
		gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
		
		gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
		
		gap.physicsBody!.isDynamic = false
		
		gap.run(moveAndRemovePipes)
		
		gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
		gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
		gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
		
		self.addChild(gap)
		
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		
		if gameOver == false {
			
			if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
				
				score += 1
				
				 run(sound)
				
				
				if score > high {
					
					high = score
					
					let userDefaults = Foundation.UserDefaults.standard
					userDefaults.set(high, forKey:  "Record")
					
				}
				scoreLabel.text = "Current Score: " + String (format: "%3d",score) + "  High Score: " + String (format: "%3d",high)
				
			} else {
				
				self.gameBackgroundMusic.run(SKAction.stop())
				
				run(sound2)
				
				self.speed = 0
				
				gameOver = true
				
				timer.invalidate()
				
				gameOverLabel.fontName = "SuperMarioGalaxy"
				
				gameOverLabel.fontSize = 25
				
				gameOverLabel.text = "Game Over! Tap to play again."
				
				gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY / 2 + 300)
				
				self.addChild(gameOverLabel)
				
			}
			
		}
		
	}
	
	override func didMove(to view: SKView) {
		
		self.physicsWorld.contactDelegate = self
		
		self.physicsWorld.gravity = CGVector.init(dx: 0, dy: -2)
		
		setupGame()
		
	}
	
	func setupGame() {
		
		let  backGroundMusic = SKAudioNode(fileNamed: "Flappy Bird Theme Song.mp3")

		self.addChild(backGroundMusic)
		
		self.gameBackgroundMusic = backGroundMusic
		
		timer = Timer.scheduledTimer(timeInterval: 3 , target: self, selector: #selector(self.checkTimer), userInfo: nil, repeats: true)
		
		let bgTexture = SKTexture(imageNamed: "bg.png")
		
		let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 5.5)
		let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width , dy: 0), duration: 0)
		let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
		
		var i: CGFloat = 0
		
		while i < 3 {
			
			bg = SKSpriteNode(texture: bgTexture)
			
			bg.position = CGPoint(x: bgTexture.size().width  * i , y: self.frame.midY)
			
			bg.size.height = self.frame.height
			
			bg.size.width = self.frame.width * 2.20
			
			bg.run(moveBGForever)
			
			bg.zPosition = -2
			
			self.addChild(bg)
			
			i += 1
			
			self.speed = 0
			
		}
		
		
		let birdTexture = SKTexture(imageNamed: "flappy1.png")
		let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
		
		let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
		let makeBirdFlap = SKAction.repeatForever(animation)
		
		bird = SKSpriteNode(texture: birdTexture)
		
		bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
		
		bird.run(makeBirdFlap)
		
		bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
		
		bird.physicsBody!.isDynamic = false
		
		bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
		bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
		bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
		
		self.addChild(bird)
		
		let ground = SKNode()
		
		ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
		
		ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
		
		ground.physicsBody!.isDynamic = false
		
		ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
		ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
		ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
		
		self.addChild(ground)
		
		gameStartLabel.fontName = "SuperMarioGalaxy"
		
		gameStartLabel.fontSize = 25
		
		gameStartLabel.text = "Tap to Start Game Play"
		
		gameStartLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY / 2 + 300)
		
		self.addChild(gameStartLabel)
		
		scoreLabel.fontName = "SuperMarioGalaxy"
		
		scoreLabel.fontSize = 25
		
		scoreLabel.text = "Current Score: " + String (format: "%3d",score) + "  High Score: " + String (format: "%3d",high)
		
		scoreLabel.position = CGPoint(x: self.frame.midX   , y: self.frame.height / 2 - 100)
		
		self.addChild(scoreLabel)
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		self.speed = 1
		
		if gameOver == false {
			
			gameStartLabel.text = ""
			
			bird.physicsBody!.isDynamic = true
			
			bird.physicsBody!.velocity = CGVector(dx: 0 , dy: 0)
			
			bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 25))
			
		} else {
			
			timer.invalidate()
			
			gameOver = false
			
			score = 0
			
			self.speed = 1
			
			self.removeAllChildren()
			
			setupGame()
			
		}
		
	}
	
	override func update(_ currentTime: TimeInterval) {
		
		// Called before each frame is rendered
	}
}
