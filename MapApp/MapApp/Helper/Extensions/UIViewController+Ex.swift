//
//  UIViewController+Ex.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

extension UIViewController{
    
    //MARK: - modalPresentation -
       func modalPresentation(){
           self.modalTransitionStyle(.crossDissolve)
        
       }
       
       //MARK: - modalFromSheet -
       func modalFromSheet(){
        if Platform.isPhone {
            self.modalTransitionStyle(.crossDissolve)
            self.modalPresentationStyle(.overCurrentContext)
        }else{
            self.modalTransitionStyle(.crossDissolve)
            self.modalPresentationStyle(.formSheet)
        }
           
       }
       func modalTransitionStyle(_ style:UIModalTransitionStyle){
           self.modalTransitionStyle = style
       }
       func modalPresentationStyle(_ style:UIModalPresentationStyle){
           self.modalPresentationStyle = style
       }
       //MARK:- showAlert-
         func showAlertAction(title:String = kAppTitle,message:String?,cancelTitle:String = "Cancel",otherTitle:String = "OK",onCompletion:@escaping (_ didSelectIndex:Int)->Void){
             self.alertControl(title: title, message: message, cancelTitle: cancelTitle, otherTitle: otherTitle, onCompletion: onCompletion)
         }
         
         //MARK:- showAlert-
         func showAlert(title:String = kAppTitle,message:String?,completion:((_ didSelectIndex:Int)->Swift.Void)? = nil){
             
             self.alertControl(title: title, message: message, cancelTitle: "OK", otherTitle: nil, onCompletion: completion)
         }
         
         fileprivate func alertControl(title:String = kAppTitle,message:String?,cancelTitle:String = "OK",otherTitle:String?,onCompletion:((_ didSelectIndex:Int)->Swift.Void)? = nil){
             let titleFont  = UIFont.systemFont(ofSize: 20, weight: .semibold)
             let messageFont  = UIFont.systemFont(ofSize:  17)
             let msge  = (message != nil && !message!.isEmpty) ? "\n\(message!)" : nil
             let alertModel = AlertControllerModel(contentViewController: nil, title: title, message: msge, titleFont: titleFont, messageFont: messageFont, titleColor: .darkBlue, messageColor: .darkGray, tintColor: .darkBlue)
             var actions:[AlertActionModel] = [AlertActionModel]()
             
             let alertActionTitle = AlertActionTitle(title: cancelTitle, titleColor: .darkBlue)
             let cancel = AlertActionModel(actionIcon: nil, actionTitle: alertActionTitle, style: .cancel)
             actions.append(cancel)
             if let otherTitle = otherTitle {
                 let alertActionTitle = AlertActionTitle(title: otherTitle, titleColor: .darkBlue)
                 let other = AlertActionModel(actionIcon: nil, actionTitle:alertActionTitle, style: .default)
                 actions.append(other)
             }
             
             _ = UIAlertController.showAlert(from: self, controlModel: alertModel, actions: actions) { (alert:UIAlertController, action:UIAlertAction, index:Int) in
                 if let handler = onCompletion {
                     handler(index)
                 }
                 
             }
         }

         var isModal: Bool {
             return presentingViewController != nil ||
                 navigationController?.presentingViewController?.presentedViewController === navigationController ||
                 tabBarController?.presentingViewController is UITabBarController
         }
}
