//
//  MAConstant.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
func async(onCompletion:@escaping()->Void){
    DispatchQueue.main.async {
        onCompletion()
    }
    
}
func asyncExecute(onCompletion:@escaping()->Void){
    DispatchQueue.main.async(execute: {
        onCompletion()
    })
}

var rootController:UIViewController?{
    return AppDelegate.shared.window?.rootViewController
}
var currentController:UIViewController?{
    if let navController  =  rootController as? UINavigationController {
        if  let visibleViewController = navController.visibleViewController{
            return visibleViewController
        }else{
            return navController
        }
    }else{
        return rootController
    }
}

var currentAlert:UIViewController?{
    if let controller  =  currentController as? UINavigationController{
        if  let visibleViewController = controller.visibleViewController{
            if let currentAlert = visibleViewController.presentedViewController as? UIAlertController{
                return currentAlert
            }else if let currentAlert = visibleViewController as? UIAlertController {
                return currentAlert
            }else{
                return visibleViewController
            }
            
        }else{
            if let currentAlert = controller.presentedViewController as? UIAlertController{
                return currentAlert
                
            }else{
                return controller
            }
        }
    }else if let controller  = currentController  {
        if let currentAlert = controller.presentedViewController as? UIAlertController{
            return currentAlert
            
        }else{
            return controller
        }
    }else{
        return nil
    }
}
var alertMessage: String? {
    didSet{
        async {
            guard let controller  =  currentAlert else {return}
            if let alertController = controller as? UIAlertController{
                let messageFont  =  UIFont.systemFont(ofSize: 17)
                alertController.set(message: alertMessage, font: messageFont, color: .darkGray)
            }else{
                controller.showAlert(message: alertMessage)
            }
            
        }
    }
}

func AppSettingAlert(title:String,message:String?){
    async {
        guard let controller  =  currentAlert else {return}
        if let alertController = controller as? UIAlertController{
            let messageFont  =  UIFont.systemFont(ofSize: 17)
            alertController.set(message: alertMessage, font: messageFont, color: .white)
        }else{
            controller.showAlertAction(title: title, message: message, cancelTitle: "OK", otherTitle: "Settings") { (index) in
                if index == 2{
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options:[:], completionHandler: nil)
                        
                    }
                    else{
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            }
        }
        
    }
}
struct Platform {
    static var isPhone:Bool { return UIDevice.current.userInterfaceIdiom == .phone ? true :false }
    static var isPad:Bool   { return UIDevice.current.userInterfaceIdiom == .pad ? true :false   }
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}

var kAppImage:UIImage?          {get{ return Bundle.kAppIcon }}
var kAppTitle :String           {get{return Bundle.kAppTitle}}
let kConnectionError            = "No Internet Connection!☹"
let kNotAvaialable              = "Not Available"

