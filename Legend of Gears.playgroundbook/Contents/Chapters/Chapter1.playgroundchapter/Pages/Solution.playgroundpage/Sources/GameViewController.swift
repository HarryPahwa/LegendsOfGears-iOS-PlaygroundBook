import Foundation
import UIKit
import SpriteKit
import PlaygroundSupport
import MetalKit

public class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    var scene: GameScene?
    var detailView: UIView?
    var flag: Bool?
    var gearList = [gearNodes]()
    var labels = [UILabel]()
    let totalHeight = 600
    let totalWidth = 800
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        scene = GameScene(size: view.bounds.size)
        print(view.bounds.size)
        //scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        let skView = self.view as! SKView
        let view2 = SKView(frame: self.view.frame)
        
        scene?.scaleMode = .resizeFill
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.showDetailView(_:)))
        
        
        skView.addGestureRecognizer(pinch)
        skView.isUserInteractionEnabled=true
        //MARK: Adding the gradient
        skView.addGradientWithColor(UIColor.orange, UIColor.white, CGRect(x:0, y:0, width: totalWidth, height: totalHeight * 2))
        skView.addGradientWithColor(UIColor.orange, UIColor.white, CGRect(x:0, y:0, width: totalWidth, height: totalHeight))
        
        view2.presentScene(scene)
        skView.addSubview(view2)
        scene!.backgroundColor = SKColor.clear
        //skView.addSubview(metalView)
        //metalView.sendSubview(toBack: skView)
        
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: (scene?.size.width)!/2, y: (scene?.size.height)!/2)
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        
        let zoomOutAction = SKAction.scale(to: 1.7, duration: 1)
        cameraNode.run(zoomOutAction)
        
        
        //blurred view
        detailView = UIView(frame:CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        skView.addSubview(detailView!)
        detailView!.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = detailView!.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        detailView!.addSubview(blurEffectView)
        detailView!.alpha = 0
        
        flag = false
    }
    
    
    
    override public func loadView() {
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        print("In loadview")
        
    }
    
    func drawGearDetails(_ gearList: [gearNodes]) {
        
        
        
        var counter = 0
        //var teeth = 1
        var speed = CGFloat(0.0)
        let smallLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        for gear in gearList {
            counter += 1
            speed = (gear.node.physicsBody?.angularVelocity)!
            
            smallLabel.center = CGPoint(x: gear.node.position.x, y: (detailView?.bounds.height)! - gear.node.position.y)
            smallLabel.textAlignment = .center
            smallLabel.textColor = UIColor.white
            smallLabel.numberOfLines = 0
            smallLabel.text = "Gear \(counter) \r Teeth: \(gear.teeth) \r Radius: \(gear.radius) units \r Angular Velocity: \((speed).format(".2")) rotation/sec"
            //smalllabel.layer.borderWidth = 0.5
            //smalllabel.layer.borderColor = UIColor.white as? CGColor
            //smallLabel.isHidden = false
            labels.append(smallLabel)
            //teeth = gear.teeth
        }
        
        if labels.count > 0 {
            for label in labels {
                //label.isHidden = false
                detailView?.addSubview(label)
            }
        }
        
    }
    
    func showDetailView (_ recognizer: UIPinchGestureRecognizer) {
        print("print it all")
        switch recognizer.state {
        case .ended:    for label in labels {
                            label.removeFromSuperview()
                        }
                        labels.removeAll()
                        if flag == false {
                            detailView?.fadeIn()
                            gearList = (scene?.getGearList())!
                            drawGearDetails(gearList)
                            flag = true
                        } else {
                            detailView?.fadeOut()
                            flag = false
                        }
            default: break
        }
        
        
        
    }
}

public extension UIView {
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}

extension SKNode {
    
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
    
}

extension UIView {
    func addGradientWithColor(_ color1: UIColor, _ color2: UIColor, _ frame: CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.opacity = 0.7
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension CGFloat {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

//uncomment for playground book
extension GameViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        // We don't need to do anything in particular when the connection opens.
        //        var myString: NSString!
        //        myString = " LIVE VIEW OPENED"
        //
        //        NSLog("%@" , myString)
        //        scene?.makeAGear(5, CGPoint(x:0, y:0))
    }
    
    public func liveViewMessageConnectionClosed() {
        // We don't need to do anything in particular when the connection closes.
    }
    
    public func receive(_ teeth: PlaygroundValue) {
        var myString: NSString!
        myString = " In receive"
        
        NSLog("%@" , myString)
        switch teeth {
        case let .integer(number):
            myString = " In receive2"
            
            NSLog("%@" , myString)
            scene?.shouldItFly = true
            let _ = scene?.makeAGear(number, CGPoint(x:view.bounds.midX, y: 500))
            myString = " In receive3"
            
            NSLog("%@" , myString)
        default: break
        }
    }
    
}
