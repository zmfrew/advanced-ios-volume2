import SpriteKit
import ARKit

class Scene: SKScene {
    let remainingLabel = SKLabelNode()
    var timer: Timer!

    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            remainingLabel.text = "Remaining: \(targetCount)"
        }
    }

    let startTime = Date()

    override func didMove(to view: SKView) {
        remainingLabel.fontSize = 36
        remainingLabel.fontName = "AmericanTypewriter"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: 110)
        addChild(remainingLabel)
        targetCount = 0

        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.createTarget()
        }
    }
    
    func createTarget() {
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        guard let sceneView = self.view as? ARSKView else { return }
        
        let xRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * Float.random(in: 0...1), 0, 1, 0))
        let yRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * Float.random(in: 0...1), 0, 1, 0))
        
        let rotation = simd_mul(xRotation, yRotation)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        let transform = simd_mul(rotation, translation)
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let hit = nodes(at: location).filter { $0 != remainingLabel }
        
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(to: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            
            sprite.run(sequence)
            targetCount -= 1
            
            if targetsCreated >= 20 && targetCount == 0 {
                gameOver()
            }
        }
    }
    
    func gameOver() {
        remainingLabel.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
        
        let timeTaken = Date().timeIntervalSince(startTime)
        let timeLabel = SKLabelNode(text: "Time taken: \(Int(timeTaken)) seconds")
        timeLabel.fontSize = 36
        timeLabel.position = CGPoint(x: 0, y: 110)
        addChild(timeLabel)
    }
}
