//
//  MAUtility.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

class MAUtility: NSObject {
    private var hud:JKProgressHUD!
    private override init() {
        super.init()
    }
    class var shared:MAUtility{
        struct Singlton{
            static let instance  = MAUtility()
        }
        return Singlton.instance
    }
    //MARK:- showProgressHud-
       func showHud(inView view:UIView? = nil,message title:String = ""){
           self.hideHud()
           let window  = view == nil ? UIApplication.shared.currentWindow : view
           if let vc = window {
                self.hud = JKProgressHUD.showProgressHud(inView: vc, titleLabel: title)
                      self.hud.lineColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
                      self.hud.setNeedsLayout()
           }
          
           
       }
       //MARK:- hideHud-
       func hideHud(){
           if (self.hud != nil) {
               self.hud.hideHud(animated: true)
           }
    
       }
      
       var isConnected:Bool{
          return NetworkReachability()!.isReachable
       }
    
}
