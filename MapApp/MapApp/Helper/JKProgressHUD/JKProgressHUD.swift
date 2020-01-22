//
//  JKProgressHUD.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

public class JKProgressHUD: UIView {
    
   public enum Position:Int {
        case center = 0
        case  top
        case  bottom
    }
   public enum BackgroundStyle:Int {
        case  solid = 0
        case  clear
        case  darkBlur
    }
    public var lineColor: UIColor = #colorLiteral(red: 0.2431372549, green: 0.3137254902, blue: 0.7058823529, alpha: 1){
        didSet{
            setNeedsDisplay()
        }
    }
    public var lineWidth: CGFloat = 3{
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var textColor: UIColor = UIColor.darkGray{
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var messageString: String = ""{
        didSet{
            self.setNeedsDisplay()
        }
    }
    public var hudPosition : Position = .center
    public var backgroundStyle:BackgroundStyle = .solid
    
     fileprivate var hudContentView:JKCardView!
     fileprivate var indicatorView :JKIndicatorView!
     fileprivate var label : UILabel!
     private override init(frame: CGRect) {
         super.init(frame: frame)
         self.backgroundColor = UIColor.clear
     }
     required public init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
     }
    private init(backgroundStyle style:BackgroundStyle = .solid,hudPosition position:Position = .center,titleLabel title:String = "") {
         super.init(frame: .zero)
         self.hudPosition = position
         self.backgroundStyle = style
         self.messageString =   title.isEmpty ? "" : title
     }

      //MARK:-showProgressHud inView-
        class func showProgressHud(inView superView:UIView,backgroundStyle style:BackgroundStyle = .solid,hudPosition position:Position = .center,titleLabel title:String = "")->JKProgressHUD{
            let hud = JKProgressHUD(backgroundStyle: style, hudPosition: position, titleLabel: title)
            superView.addSubview(hud)
            hud.updatehudContraints(item: hud, toItem: superView)
            hud.showHud(animated: true)
            return hud
        }
        
        
        
        //MARK:-updatehudContraints-
        fileprivate  func updatehudContraints(item:UIView, toItem:UIView){
            item.translatesAutoresizingMaskIntoConstraints = false
            [
                item.topAnchor.constraint(equalTo: toItem.topAnchor, constant: 0),
                item.bottomAnchor.constraint(equalTo: toItem.bottomAnchor, constant: 0),
                item.leadingAnchor.constraint(equalTo: toItem.leadingAnchor, constant: 0),
                item.trailingAnchor.constraint(equalTo: toItem.trailingAnchor, constant: 0),
                ].forEach({$0.isActive = true})
            self.layoutIfNeeded()
            //self.setNeedsDisplay()
        }
        //MARK:-initilaize-
        fileprivate func initilaize(){
            self.backgroundColor = self.backgroundStyle == .clear ? UIColor.clear : UIColor(white: 0.1, alpha: 0.45)
            self.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1.0
                self.addContentView()
            })
            
            
            
        }
        fileprivate func addBlurView(style:UIBlurEffect.Style = .light){
            let blurEffect = UIBlurEffect(style:style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.addSubview(blurEffectView)
            self.updatehudContraints(item: blurEffectView, toItem: self)
        }
        //MARK:-addContentView-
        fileprivate func addContentView(){
            
            hudContentView = JKCardView()
            self.addSubview(hudContentView)
            hudContentView.translatesAutoresizingMaskIntoConstraints = false
            var topConstraint : NSLayoutConstraint
            var bottomConstraint : NSLayoutConstraint
            var widthRelation: NSLayoutConstraint.Relation =  .equal
            if messageString.isEmpty == false {
                widthRelation = .lessThanOrEqual
            }
            guard let hudContentView = hudContentView else {return}
            var heightConstant:CGFloat = 0.0
            var widthConstant:CGFloat = 200
            
            if messageString.isEmpty == false {
                heightConstant = 50
                hudContentView.cornerRadius = 5
            }
            else{
                widthConstant = 45
                heightConstant = 45
                hudContentView.cornerRadius = max(widthConstant, heightConstant)/2
            }
            
            //HUD POSITIONS
            
            var layoutConstraints:[NSLayoutConstraint] = [
                widthRelation == .lessThanOrEqual ? hudContentView.widthAnchor.constraint(lessThanOrEqualToConstant: widthConstant):hudContentView.widthAnchor.constraint(equalToConstant: widthConstant),
                hudContentView.heightAnchor.constraint(equalToConstant: heightConstant),
                hudContentView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
                
            ]
            switch hudPosition {
            case .top:
                topConstraint = NSLayoutConstraint(item: hudContentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80)
                layoutConstraints.append(topConstraint)
            case .bottom:
                bottomConstraint = NSLayoutConstraint(item: hudContentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -40)
                layoutConstraints.append(bottomConstraint)
            default:
                let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                layoutConstraints.append(yConstraint)
            }
            
            NSLayoutConstraint.activate(layoutConstraints)
            hudContentView.shadowOffset = CGSize(width: 0, height: 0)
            hudContentView.shadowRadius = 7
            hudContentView.isShadow = true
            hudContentView.masksToBounds = false
            hudContentView.clipsToBound = true
            hudContentView.shadowColor = UIColor.black
            hudContentView.backgroundColor = UIColor.white
            hudContentView.setNeedsLayout()
            addHudView()
        }
        //MARK:-addHudView-
        fileprivate func addHudView(){
                //Indeterminate
                indicatorView  = JKIndicatorView()
                indicatorView.lineColor = lineColor
                indicatorView.lineWidth = (lineWidth > 3) ? lineWidth : 3
                hudContentView.addSubview(indicatorView!)
                
                
                //Indeterminate
                indicatorView.translatesAutoresizingMaskIntoConstraints = false
                guard let indicatorView = indicatorView else{return}
                let layoutConstraints = [
                    indicatorView.centerYAnchor.constraint(equalTo: hudContentView.centerYAnchor, constant: 0),
                    indicatorView.widthAnchor.constraint(equalToConstant:  messageString.isEmpty == false ? 32 : 25),
                    indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor, multiplier: 1),
                    messageString.isEmpty == false ?  indicatorView.leadingAnchor.constraint(equalTo: hudContentView.leadingAnchor, constant: 5) :indicatorView.centerXAnchor.constraint(equalTo: hudContentView.centerXAnchor, constant: 0)
                ]
                NSLayoutConstraint.activate(layoutConstraints)
                indicatorView.setNeedsDisplay()
            
            if messageString.isEmpty == false{
                addLabel()
            }
        }
        
        fileprivate func addLabel(){
            label = UILabel()
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.textColor = textColor
            label.text = messageString
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            hudContentView.addSubview(label!)
                guard let label = label, let hudContentView = hudContentView else{return}
                let layoutConstraints = [
                    label.leadingAnchor.constraint(equalTo: indicatorView.rightAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: hudContentView.trailingAnchor, constant: -10),
                    label.heightAnchor.constraint(equalToConstant: 30),
                    label.centerYAnchor.constraint(equalTo: hudContentView.centerYAnchor, constant: 0)
                    
                ]
                NSLayoutConstraint.activate(layoutConstraints)
                label.layoutIfNeeded()
            
        }
        //MARK:-hideHudafterDelay-
        public func hideHud(animated animate:Bool, afterDelay delay:Int,completion:@escaping (_ complete: Bool) -> Void){
            DispatchQueue.main.after(TimeInterval(delay)) {
                self.hideHud(animated: animate, completion: completion)
            }
        }
        public  func hideHud(animated animate:Bool, afterDelay delay:Int){
            let completion = { (complete: Bool) -> Void in}
            self.hideHud(animated: true, afterDelay: delay, completion: completion)
        }
        //MARK:-hideHud-
        public  func hideHud(animated animate:Bool,completion:@escaping(_ complete: Bool) -> Void){
            let completion = { (complete: Bool) -> Void in
                if complete {
                   //Indeterminate
                   self.indicatorView?.stopAnimation()
                   self.indicatorView?.removeFromSuperview()
                    if self.label != nil{
                        self.label.removeFromSuperview()
                    }
                    self.removeFromSuperview()
                    completion(complete)
                }
            }
            DispatchQueue.main.async {
                self.alpha = 1.0
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 0.0
                }, completion: completion)
            }
            
        }
        public func hideHud(animated animate:Bool){
            
            let completion = { (complete: Bool) -> Void in}
            self.hideHud(animated: true, completion: completion)
        }
        //MARK:-showHud-
        fileprivate func showHud(animated animate:Bool){
            DispatchQueue.main.async {
                self.initilaize()
                //Indeterminate
                self.indicatorView?.startAnimation()
               
                
            }
            
        }
       
        override public func layoutSubviews() {
            super.layoutSubviews()
            
        }
        override public func draw(_ rect: CGRect) {
            super.draw(rect)
            
            if backgroundStyle == .darkBlur {
                let context : CGContext = UIGraphicsGetCurrentContext()!
                UIGraphicsPushContext(context)
                //Gradient colours
                let gradLocationsNum : size_t = 2
                let gradLocations:[CGFloat] = [0.0, 1.0]
                let gradColors:[CGFloat] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.45]
                let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
                let gradient : CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors, locations: gradLocations, count: gradLocationsNum)!
                //Gradient center
                let gradCenter:CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
                //Gradient radius
                let gradRadius:CGFloat = min(self.bounds.size.width , self.bounds.size.height)
                //Gradient draw
                context.drawRadialGradient(gradient, startCenter: gradCenter, startRadius: 0, endCenter: gradCenter, endRadius: gradRadius, options: .drawsAfterEndLocation)
            }
            self.setNeedsDisplay()
            
        }
        
    }

