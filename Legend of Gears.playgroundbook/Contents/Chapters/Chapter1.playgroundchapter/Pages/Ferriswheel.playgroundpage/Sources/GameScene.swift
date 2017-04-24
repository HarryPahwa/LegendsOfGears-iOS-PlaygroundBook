import Foundation
import SpriteKit
import PlaygroundSupport
import AVFoundation
import MetalKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let gearLevel : UInt32 = 0b001
    static let hoverLevel: UInt32 = 0b010
}

struct NameCategory {
    static let gear: String = "gear"
    static let background: String = "background"
    static let pin: String = "pin"
    static let ground: String = "ground"
    static let ferrisWheel: String = "ferrisWheel"
    static let initialGear: String = "initialGear"
    static let finalGear: String = "finalGear"
    static let deleteEmpty: String = "deleteEmpty"
    static let deleteFull: String = "deleteFull"
    static let totalGearLabel: String = "totalGearLabel"
    static let pauseButton: String = "pauseButton"
    static let flyingGear: String = "flyingGear"
    static let playButton: String = "playButton"
    static let ferrisWin: String = "ferrisWin"
}

let degree = CGFloat(Double.pi / 2) / 90

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temporaryA = a
    a = b
    b = temporaryA
}

public class GameScene: SKScene, SKPhysicsContactDelegate {
    var selectedNode: SKNode?
    var shakeAction: SKAction?
    var gearList = [gearNodes]()
    var background: SKSpriteNode
    //SKSpriteNode(imageNamed: "background")
    public var shouldItFly = false
    var midPoint: CGPoint
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    public var initialVelocity = 1.0
    var pinJointsBodies = [PinJointBody]()
    let initialGearTeeth = 25
    let finalGearTeeth = 40
    var pinList = [String] ()
    var finalGearSpinCheck: SKNode?
    var deleteFlag = false
    var totalGearLabel = SKLabelNode(text: "0")
    var pauseButton: SKNode!
    let backgroundMusic = SKAudioNode(fileNamed: "Enchanted Festival.mp3")
    let winningMusic = SKAudioNode(fileNamed: "Grassy World.mp3")
    var isMusicPaused = false
    var flyingGear: SKNode?
    var flyingEnded = false
    var isFlying = false
    var gearCreated = false
    var playButton: SKNode!
    var winCounter = 0
    var won = false
    var ferrisNode = SKSpriteNode(imageNamed: "FerrisWheelWin0")
    var animation: SKAction?

    override public init(size: CGSize) {
        
        midPoint = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        background = SKSpriteNode(color: SKColor.clear, size: CGSize(width: size.width, height: size.height))
        super.init(size: size)
        makeBackground()
        initializeGear()
        setupSprites()
        makeShakeAction()
    }
    
    func initializeGear() {
        let initialGearLocation = CGPoint(x: 50, y: 150)
        let finalGearLocation = CGPoint(x: 650, y:260)
        
        let post = SKShapeNode(rect: CGRect(x: -25, y: -190, width: 50, height: 200))
        post.fillColor = UIColor.brown
        post.position = initialGearLocation
        thingsShouldHover(post, PhysicsCategory.None)
        addChild(post)
        
        let finalGear = makeAGear(finalGearTeeth, finalGearLocation, UIColor.red)
        let initialGear = makeAGear(initialGearTeeth, initialGearLocation, UIColor.orange)
        finalGear.name = NameCategory.finalGear
        initialGear.name = NameCategory.initialGear
        
        for joint in pinJointsBodies {
            if finalGear == joint.pin {
                joint.gear.alpha = 0.5
                finalGearSpinCheck = joint.gear
            }
            if finalGear == joint.pin || initialGear == joint.pin {
                thingsShouldHover(joint.pin, PhysicsCategory.gearLevel)
                thingsShouldHover(joint.gear, PhysicsCategory.gearLevel)
            }
        }
        
        
        
    }
    
    func makeBackground() {
        
        background.position = CGPoint(x: size.width/2, y: size.height / 2)
        background.physicsBody?.isDynamic=false
        background.name = NameCategory.background
        
        addChild(background)
    }
    
    func setupSprites() {
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.position = CGPoint(x: (size.width/2) + 25, y: 0)
        ground.name = NameCategory.ground
        thingsShouldHover(ground, PhysicsCategory.None)
        
        
        let f0 = SKTexture.init(imageNamed: "FerrisWheelWin0")
        let f1 = SKTexture.init(imageNamed: "FerrisWheelWin1")
        let f2 = SKTexture.init(imageNamed: "FerrisWheelWin2")
        let f3 = SKTexture.init(imageNamed: "FerrisWheelWin3")
        let f4 = SKTexture.init(imageNamed: "FerrisWheelWin4")
        let f5 = SKTexture.init(imageNamed: "FerrisWheelWin5")
        let f6 = SKTexture.init(imageNamed: "FerrisWheelWin6")
        let f7 = SKTexture.init(imageNamed: "FerrisWheelWin7")
        let f8 = SKTexture.init(imageNamed: "FerrisWheelWin8")
        let f9 = SKTexture.init(imageNamed: "FerrisWheelWin9")
        let frames: [SKTexture] = [f0, f1, f2, f3, f4, f5, f6, f7, f8, f9]
        
        // Load the first frame as initialization
        ferrisNode.position = CGPoint(x: 650, y: 250)
        thingsShouldHover(ferrisNode, PhysicsCategory.None)
        ferrisNode.name = NameCategory.ferrisWin
        ferrisNode.zPosition = -10
        // Change the frame per 0.2 sec
        animation = SKAction.animate(with: frames, timePerFrame: 0.2)
        
        
        
//        let ferrisWheel = SKSpriteNode(imageNamed: "ferris_wheel")
//        ferrisWheel.position = CGPoint(x: 650, y: 250)
//        ferrisWheel.name = NameCategory.ferrisWheel
//        thingsShouldHover(ferrisWheel, PhysicsCategory.None)
//        ferrisWheel.zPosition = -10
        
        
        let deleteEmpty = SKSpriteNode(imageNamed: "Delete_Empty")
        deleteEmpty.position = CGPoint(x: 850, y: 575)
        deleteEmpty.name = NameCategory.deleteEmpty
        thingsShouldHover(deleteEmpty, PhysicsCategory.None)
        deleteEmpty.scale(to: CGSize(width: 25, height: 25))
        
        let deleteFull = SKSpriteNode(imageNamed: "Delete_Full")
        deleteFull.position = CGPoint(x: 850, y: 575)
        deleteFull.name = NameCategory.deleteFull
        thingsShouldHover(deleteFull, PhysicsCategory.None)
        deleteFull.alpha = 0
        deleteFull.scale(to: CGSize(width: 25, height: 25))
        
        totalGearLabel.position = CGPoint(x: -75, y: 500)
        totalGearLabel.name = NameCategory.totalGearLabel
        totalGearLabel.fontColor=UIColor.white
        thingsShouldHover(totalGearLabel, PhysicsCategory.None)
        
        pauseButton = SKSpriteNode(imageNamed: "Pause")
        pauseButton.position = CGPoint(x: -75, y: 575)
        pauseButton.alpha = 1
        pauseButton.name = NameCategory.pauseButton
        thingsShouldHover(pauseButton, PhysicsCategory.None)
        
        playButton = SKSpriteNode(imageNamed: "Play")
        playButton.position = CGPoint(x: -75, y: 575)
        playButton.alpha = 0
        playButton.name = NameCategory.playButton
        thingsShouldHover(playButton, PhysicsCategory.None)
        
        backgroundMusic.isPositional = true
        backgroundMusic.position = CGPoint(x: 0, y: 0)
        
        
        addChild(backgroundMusic)
        addChild(winningMusic)
        addChild(pauseButton)
        addChild(playButton)
        addChild(totalGearLabel)
        addChild(deleteEmpty)
        addChild(deleteFull)
//        addChild(ferrisWheel)
        self.addChild(ferrisNode)
        addChild(ground)
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        print(flyingGear?.name ?? "Nothing flying")

        
        if gearList.count > 1 {
            gearList[1].node.physicsBody?.angularVelocity = CGFloat(initialVelocity)
        }
        
        if flyingGear?.hasActions() == false {
            flyingEnded = true
        }
        
        if flyingEnded && isFlying {
            if let selectedNode = flyingGear {
                var counter = 0
                for node in self.nodes(at: selectedNode.position) {
                    if node.name == NameCategory.gear {
                        counter += 1
                    }
                }
                if counter == 1 {
                    for joint in pinJointsBodies {
                        if selectedNode == joint.pin {
                            thingsShouldHover(joint.pin, PhysicsCategory.gearLevel)
                            thingsShouldHover(joint.gear, PhysicsCategory.gearLevel)
                        }
                    }
                    flyingEnded = false
                    isFlying = false
                    flyingGear = nil
                    gearCreated = false
                }
        }
        }
        
        if let finalGear = finalGearSpinCheck {
            if (finalGear.physicsBody?.angularVelocity)! > CGFloat(0.0) || (finalGear.physicsBody?.angularVelocity)! < CGFloat(0.0) {
                //print("YOU WIN")
                if won == false {
                    winScenario()
                }
            } else {
                won = false
                ferrisNode.removeAction(forKey: "winningCelebration")
                //ferrisNode = SKSpriteNode(imageNamed: "FerrisWheelWin0")
                if isMusicPaused == false {
                    backgroundMusic.run(SKAction.play())
                }
                winningMusic.run(SKAction.pause())
            }
        }
    }
    
    func winScenario() {
        won = true
        ferrisNode.run(SKAction.repeatForever(animation!), withKey: "winningCelebration")
        
        backgroundMusic.run(SKAction.pause())
        
        if isMusicPaused == false {
            winningMusic.run(SKAction.play())
        }
    }
    
    public override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        
        view.allowsTransparency = true
        view.isOpaque=false
        view.backgroundColor=UIColor.clear
    }
    
    
    public func makeAGear(_ teeth: Int,_ positionInScene: CGPoint,_ gearColor: UIColor = .randomColor()) -> SKNode {
        var gearAddition: Gear
        
        if teeth == 0 {
            gearAddition = Gear(teeth: Int(randRange(lower: 25, upper: 43)), module: 5)
        } else {
            gearAddition = Gear(teeth: teeth, module: 5)
        }
        
        let path = gearAddition.getGearPath()
        let gearNode = SKShapeNode(path: path.cgPath)
        gearNode.position = positionInScene
        gearNode.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        gearNode.fillColor = gearColor
        
        gearNode.physicsBody?.allowsRotation = true
        gearNode.physicsBody?.linearDamping = 1.0
        gearNode.physicsBody?.angularDamping = 0.5
        
        gearNode.physicsBody?.usesPreciseCollisionDetection = true
        gearNode.physicsBody?.isDynamic=true
        gearNode.name = NameCategory.gear
        //gearNode.physicsBody?.velocityFactor  = (0.0,0.0,0.0)
        addChild(gearNode)
        gearList.append(gearNodes(teeth: gearAddition.gearTeeth, radius: gearAddition.radius, module: gearAddition.module, node: gearNode))
        //trying to attach a pin
        
        let pinBody = SKShapeNode(circleOfRadius:15)
        pinBody.fillColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        pinBody.position = gearNode.position
        pinBody.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(10))
        pinBody.physicsBody?.isDynamic=false
        pinBody.name = NameCategory.pin + String(pinList.count)
        pinList.append(pinBody.name!)
        addChild(pinBody)
        totalGearLabel.text = String(gearList.count) + " gears"
        
        // MARK: Physics pin joint
        
        let pinJoint = SKPhysicsJointPin.joint(withBodyA: gearNode.physicsBody!, bodyB: pinBody.physicsBody!, anchor: positionInScene)
        
        scene?.physicsWorld.add(pinJoint)
        
        pinJointsBodies.append(PinJointBody(gear: gearNode, pin: pinBody))
        
        thingsShouldHover(gearNode, PhysicsCategory.hoverLevel)
        thingsShouldHover(pinBody, PhysicsCategory.hoverLevel)
        
        
//        // MARK: Speech Utterance Module
//        myUtterance = AVSpeechUtterance(string: "Gear of teeth \(gearAddition.gearTeeth)")
//        myUtterance.rate = 0.5
//        synth.speak(myUtterance)
 
        shouldItFly = true
        gearCreated = true
        
        return pinBody
    }
    
    func makeGearFly(_ pinBody: SKNode) {
        let count = gearList.count
        if count > 1 {
            let point1 = gearList[count - 2].node.position
            let point2 = pinBody.position
            let difference = point2 - point1
            let slope = Double(difference.y/difference.x)
            let centerToCenterDist = (gearList[count - 2].radius + gearList[count - 1].radius) + 2 * 1 * gearList[count - 1].module
            var multiplier = 1.0
            if difference.x < 0.0 {
                multiplier *= -1.0
            }
            let xCoord = Double(point1.x) + multiplier * pow(pow(centerToCenterDist,2)/(1+pow(slope,2)),0.5)
            let pointToMoveTo = CGPoint(x: xCoord, y: slope*(xCoord-Double(point1.x))+Double(point1.y))
            
            print("point1:", point1, "point2:", point2, "with slope:", slope, "and CTC: ", centerToCenterDist, "and point to move to:", pointToMoveTo, separator: " ")
            shouldItFly = false
            pinBody.run(SKAction.move(to: pointToMoveTo, duration: 1.5), withKey: NameCategory.flyingGear)
            flyingGear = pinBody
            
            isFlying = true
            
        }
        
    }
    
    public func getGearList() -> [gearNodes] {
            return gearList
    }
    
    func makeShakeAction(){
        var sequence = [SKAction]()
        for _ in 0..<10 {
            let shake = CGFloat(drand48() * 2) + 1
            let shake2 = CGFloat(drand48() * 2) + 1
            let duration = 0.08 // + (drand48() * 0.14)
            let antiClockwise = SKAction.group([
                SKAction.rotate(byAngle: degree * shake, duration: duration),
                SKAction.moveBy(x: shake, y: shake2, duration: duration)
                ])
            let clockWise = SKAction.group([
                SKAction.rotate(byAngle: degree * shake * -2, duration: duration * 2),
                SKAction.moveBy(x: shake * -2, y: shake2 * -2, duration: duration * 2)
                ])
            sequence += [antiClockwise, clockWise, antiClockwise]
        }
        
        
        shakeAction = SKAction.repeatForever(SKAction.sequence(sequence))
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    // MARK: Touch Functions
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let positionInScene = touch?.location(in: self) else {return}
        
        print(self.nodes(at: positionInScene).count)
        print(self.nodes(at: positionInScene).first?.name ?? "NO NODE")
        
        if let touchedNode = self.nodes(at: positionInScene).first{
            print("in here")
            if pinList.contains(touchedNode.name!)// == childNode(withName: NameCategory.pin)
            {
                selectedNode = touchedNode
                print((selectedNode?.name)! + "HELLO")
                //selectedNode?.run(shakeAction!, withKey: "shake")
                //selectedNode?.removeAction(forKey: "rotate")
                
            }
            else if touchedNode == childNode(withName: NameCategory.background) {
                
//                let gearNode = makeAGear(0, positionInScene)
//                selectedNode = gearNode
//                shouldItFly = true
//                gearCreated = true
            }
        }
        
    
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        //print(touch.location(in: self))
        let translationInScene = touch.location(in: self) - touch.previousLocation(in: self)
        
        backgroundMusic.position += translationInScene
        
        if let selected = selectedNode {
            selected.position += translationInScene
            
            
            for joint in pinJointsBodies {
                if selected == joint.pin {
                    thingsShouldHover(joint.pin, PhysicsCategory.hoverLevel)
                    thingsShouldHover(joint.gear, PhysicsCategory.hoverLevel)
                }
                
            }
            
            if shouldItFly {
                createLine(initialPoint: touch.location(in: self), finalPoint: gearList[gearList.count - 2].node.position)
            }
            
            if touch.location(in: self).x > 825 && touch.location(in: self).y > 550 {
                self.childNode(withName: NameCategory.deleteEmpty)?.alpha = 0
                self.childNode(withName: NameCategory.deleteFull)?.alpha = 1
                deleteFlag = true
                selectedNode?.alpha = 0.4
                for joint in pinJointsBodies {
                    if selectedNode == joint.pin {
                        joint.gear.alpha = 0.4
                    }
                }
            }
            
            if touch.location(in: self).x < 825 && touch.location(in: self).y < 550 {
                self.childNode(withName: NameCategory.deleteEmpty)?.alpha = 1
                self.childNode(withName: NameCategory.deleteFull)?.alpha = 0
                deleteFlag = false
                selectedNode?.alpha = 1.0
                for joint in pinJointsBodies {
                    if selectedNode == joint.pin {
                        joint.gear.alpha = 1.0
                    }
                }
            }
            //print(selectedNode?.physicsBody. ?? "No Joint")
            //selectedNode?.physicsBody?.isDynamic=false
        }
    }
    
    
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //guard let positionInScene = touches.first?.location(in: self) else {return}
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        if pauseButton.contains(location) {
            print("Yea it does")
            print(backgroundMusic.isPaused)
            if isMusicPaused == false {
                print("music is paused")
                backgroundMusic.run(SKAction.pause())
                
                winningMusic.run(SKAction.pause())
                
                pauseButton.alpha = 0
                playButton.alpha = 1.0
                
                isMusicPaused = !isMusicPaused
            }
            else {
                print("music is not paused")
                if won == false {
                    backgroundMusic.run(SKAction.play())
                } else {
                    winningMusic.run(SKAction.play())
                }
                pauseButton.alpha = 1.0
                playButton.alpha = 0.0
               
                isMusicPaused = !isMusicPaused
            }
        }
        
        if selectedNode != nil {
            selectedNode?.removeAction(forKey: "shake")
            if shouldItFly {
                makeGearFly(selectedNode!)
                isFlying = true
            }
            
            if flyingEnded == false && isFlying == false && gearCreated == false {
                var counter = 0
                for node in self.nodes(at: location) {
                    if node.name == NameCategory.gear {
                        counter += 1
                    }
                }
                if counter == 1 {
                    for joint in pinJointsBodies {
                        if selectedNode == joint.pin {
                            thingsShouldHover(joint.pin, PhysicsCategory.gearLevel)
                            thingsShouldHover(joint.gear, PhysicsCategory.gearLevel)
                            }
                        }
                }
            }
            
            if deleteFlag == true {
                
                self.childNode(withName: NameCategory.deleteEmpty)?.alpha = 1
                self.childNode(withName: NameCategory.deleteFull)?.alpha = 0
                selectedNode?.alpha = 1.0
                deleteGear(selectedNode!)
                deleteFlag = false
                
            }
            
            
            selectedNode = nil
        }
    }
    
    func createLine(initialPoint: CGPoint, finalPoint: CGPoint) {
        let path: UIBezierPath = UIBezierPath()
        path.move(to: initialPoint)
        path.addLine(to: finalPoint)
        
        let pathNode = SKShapeNode(path: path.cgPath)
        pathNode.strokeColor = SKColor.gray
        
        pathNode.lineWidth = 2.0
        pathNode.alpha = 0.5
        addChild(pathNode)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let fadeIn = SKAction.fadeOut(withDuration: 0.5)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        pathNode.run(SKAction.repeatForever(pulse), withKey: "drawLine")
    }
    
    func deleteGear(_ pinBody: SKNode) {
        for i in 0...pinJointsBodies.count - 1 {
            let joint = pinJointsBodies[i]
            if pinBody == joint.pin {
                for j in 0...gearList.count - 1 {
                    if gearList[j].node == joint.gear {
                        gearList.remove(at: j)
                        break
                    }
                }
                
                joint.pin.removeFromParent()
                joint.gear.removeFromParent()
                pinJointsBodies.remove(at: i)
                break
            }
        }
        totalGearLabel.text = String(gearList.count) + " gears"

    }
    
    func thingsShouldHover(_ node: SKNode, _ category: UInt32) {
        node.physicsBody?.categoryBitMask = category
        node.physicsBody?.contactTestBitMask = category
        node.physicsBody?.collisionBitMask = category
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        
        print(contact.bodyA.node?.name ?? "NO NODE A")
        print(contact.bodyB.node?.name ?? "NO NODE B")
        if contact.bodyA.node?.name == "gear" || contact.bodyB.node?.name == "gear" {
            // execute code to respond to object hitting ground
            for joint in pinJointsBodies {
                if contact.bodyA.node == joint.gear || contact.bodyB.node == joint.gear{
                    joint.pin.removeAllActions()
                }
            }
        }

    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}





