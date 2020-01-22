//
//  JKIndicatorView.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
let mpi :CGFloat = CGFloat(Double.pi)
@IBDesignable
public class JKIndicatorView: UIView {
    fileprivate var strokeLineAnimation: CAAnimationGroup!
       fileprivate var rotationAnimation: CAAnimation!
       fileprivate var strokeColorAnimation: CAAnimation!
       
       /**
        * Array of UIColor
        */
       @IBInspectable public var colorArray:[UIColor] = [UIColor.blue]{
           didSet {
               if colorArray.count < 0  {
                   colorArray = [UIColor.blue]
               }
               self.setNeedsDisplay()
           }
       }
       
       @IBInspectable public var roundTime = 1.5{
           didSet {
               if roundTime < 1.5 {
                   roundTime = 1.5
               }
               self.setNeedsDisplay()
           }
       }
       public var animating: Bool = false
       /**
        * lineWidth of the stroke
        */
       @IBInspectable public var lineWidth:CGFloat = 3.0 {
           didSet {
               circleLayer.lineWidth = lineWidth
               self.setNeedsDisplay()
           }
           
       }
       @IBInspectable public var lineColor:UIColor = UIColor.blue {
           didSet {
               colorArray = [lineColor]
               self.updateAnimations()
           }
       }
       
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           
           self.initialSetup()
       }
       
       required public init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           self.initialSetup()
           
           
       }
       lazy public var circleLayer:CAShapeLayer! = {
           let layer = CAShapeLayer()
           layer.fillColor = nil
           layer.lineWidth = self.lineWidth
           layer.lineCap = CAShapeLayerLineCap.round
           return layer
       }()
       
       
       // MARK: - Initial Setup
       
       fileprivate func initialSetup() {
           
           self.layer.addSublayer(self.circleLayer)
           self.backgroundColor = UIColor.clear
           
           if self.colorArray.count == 0
           {
               self.colorArray = [lineColor]
           }
           
           self.updateAnimations()
       }
       // MARK: - Layout
       
       override public func layoutSubviews() {
           super.layoutSubviews()
           
           let center : CGPoint = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
           let radius :CGFloat = min(self.bounds.size.width, self.bounds.size.height)/2.0 - self.circleLayer.lineWidth / 2.0
           let startAngle : CGFloat = 0
           let endAngle : CGFloat = 2*CGFloat(mpi)
           let path : UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
           circleLayer.path = path.cgPath
           circleLayer.frame = self.bounds
           
           
       }
       // MARK: - updateAnimations
       fileprivate func updateAnimations() {
           // Stroke Head
           let headAnimation = CABasicAnimation(keyPath: "strokeStart")
           headAnimation.beginTime = roundTime / 3.0
           headAnimation.fromValue = 0
           headAnimation.toValue = 1
           headAnimation.duration = 2 * roundTime / 3.0
           headAnimation.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
           // Stroke Tail
           let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
           tailAnimation.fromValue = 0
           tailAnimation.toValue = 1
           tailAnimation.duration = 2 * roundTime / 3.0
           tailAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)        // Stroke Line Group
           let animationGroup = CAAnimationGroup()
           animationGroup.duration = roundTime
           animationGroup.repeatCount = .infinity
           animationGroup.animations = [headAnimation, tailAnimation]
           self.strokeLineAnimation = animationGroup
           // Rotation
           let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
           rotationAnimation.fromValue = 0
           rotationAnimation.toValue = (2 * mpi)
           rotationAnimation.duration = roundTime
           rotationAnimation.repeatCount = .infinity
           self.rotationAnimation = rotationAnimation
           let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
           strokeColorAnimation.values = self.prepareColorValues()
           strokeColorAnimation.keyTimes = self.prepareKeyTimes()
           strokeColorAnimation.calculationMode = CAAnimationCalculationMode.discrete
           strokeColorAnimation.duration = Double(Double(self.colorArray.count) * roundTime)
           strokeColorAnimation.repeatCount = .infinity
           self.strokeColorAnimation = strokeColorAnimation
           self.setNeedsDisplay()
       }
       // MARK: - Animation Data Preparation
       
       fileprivate func prepareColorValues() -> [AnyObject] {
           var cgColorArray = [AnyObject]()
           for color: UIColor in self.colorArray {
               cgColorArray.append(color.cgColor)
               
           }
           return cgColorArray
       }
       
       fileprivate func prepareKeyTimes() -> [NSNumber] {
           var keyTimesArray = [NSNumber]()
           for i in 0..<self.colorArray.count + 1{
               keyTimesArray.append(NSNumber(value:  (Float(i)  *  1.0) / Float(self.colorArray.count)))
           }
           return keyTimesArray
       }
       // MARK: -startAnimation
       
       public func startAnimation(){
           self.animating = true
           self.circleLayer.add(self.strokeLineAnimation, forKey: "strokeLineAnimation")
           self.circleLayer.add(self.rotationAnimation, forKey: "rotationAnimation")
           self.circleLayer.add(self.strokeColorAnimation, forKey: "strokeColorAnimation")
       }
       // MARK: -stopAnimation
       public func stopAnimation() {
           self.animating = false
           self.circleLayer.removeAnimation( forKey: "strokeLineAnimation")
           self.circleLayer.removeAnimation( forKey: "rotationAnimation")
           self.circleLayer.removeAnimation( forKey: "strokeColorAnimation")
       }
       
       public  func stopAnimation(after timeInterval: TimeInterval){
           DispatchQueue.main.after(timeInterval) {
               self.stopAnimation()
           }
       }
       
       fileprivate func isAnimating() -> Bool {
           return animating
       }

}
