import Foundation
import UIKit
import SpriteKit


public class Gear: SKView{
    
    public var gearTeeth: Int
    public var module: Double
    public var pitch: Double
    public var radius: Double {
        get {
            return self.module * Double(self.gearTeeth) / 2.0
        }
        set {}
    }
    
    
    public init(teeth: Int, module: Double) {
        self.gearTeeth = teeth
        self.module = module
        self.pitch = Double(module) * Double.pi
        
        super.init(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
            }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func getGearPath() -> UIBezierPath
    {

        let deltaAngle = 2 * Double.pi / Double(gearTeeth)
        let path = UIBezierPath()
        let midPoint = CGPoint(x:0, y:0)
        
        let gearOffset = -Double.pi / 100
        let addendum = Double(1 * module)
        let dedendum = 1.25 * Double(module)
        //let pressureAngle = 20 //Could be added on later 
        
        for i in 0...self.gearTeeth-1
        {
        
            let startAngle = (Double(i) * deltaAngle)
            let endAngle = ((Double(i) * deltaAngle + (deltaAngle/2.0)))
            
            path.addArc(withCenter: midPoint, radius: CGFloat(radius - dedendum), startAngle: CGFloat(startAngle) , endAngle: CGFloat(endAngle) , clockwise: true)
            path.lineJoinStyle = .round
            
            
            
            
            path.addArc(withCenter: midPoint, radius: CGFloat(radius + addendum), startAngle: CGFloat(endAngle - gearOffset) , endAngle: CGFloat(endAngle + gearOffset + deltaAngle/2) , clockwise: true)
            path.lineJoinStyle = .round
         
        }
        path.close()
        
        
        let maskPath = UIBezierPath()
        maskPath.addArc(withCenter: midPoint, radius: CGFloat(15), startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        path.append(maskPath)
        
        if gearTeeth>25
        {
            let maskPath2 = UIBezierPath()
            let maskPath3 = UIBezierPath()
            let maskPath4 = UIBezierPath()
            let maskPath5 = UIBezierPath()
            
            maskPath2.addArc(withCenter: CGPoint(x:0, y: radius/2), radius: CGFloat(radius/6), startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            path.append(maskPath2)
            
            maskPath3.addArc(withCenter: CGPoint(x:0, y: -radius/2), radius: CGFloat(radius/6), startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            path.append(maskPath3)
          
            maskPath4.addArc(withCenter: CGPoint(x:radius/2, y: 0), radius: CGFloat(radius/6), startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            path.append(maskPath4)
            
            maskPath5.addArc(withCenter: CGPoint(x:-radius/2, y: 0), radius: CGFloat(radius/6), startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            path.append(maskPath5)
            
        }
        path.usesEvenOddFillRule = true
        path.addClip()
        UIColor(white: 0, alpha: 0.5).setFill()
        path.fill()
        
        return path
    }
    
}

