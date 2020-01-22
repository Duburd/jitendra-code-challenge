//
//  UIAlertController+Ex.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

typealias UIAlertActionHandler = (_ controller:UIAlertController, _ action:UIAlertAction, _ buttonIndex:Int)->Void
enum UIAlertActionIndex:Int {
    case cancel = 0
    case destructive = 1
    case firstOther = 2
    case otherField = 4
}

struct AlertFields {
    var placeholder:String = ""
    var isSecureTextEntry:Bool = false
    var borderStyle:UITextField.BorderStyle = .none
    init(placeholder:String,isSecure:Bool = false,borderStyle:UITextField.BorderStyle = .none) {
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.borderStyle = borderStyle
    }
    
}



struct AlertControllerModel {
    var contentViewController:UIViewController? = nil
    var title:String?
    var message:String?
    var titleFont:UIFont? = nil
    var messageFont:UIFont? = nil
    var titleColor:UIColor? = nil
    var messageColor:UIColor? = nil
    var tintColor:UIColor = UIColor.black
    init(contentViewController controller: UIViewController? = nil, title: String?  = nil, message: String?  = nil, titleFont: UIFont? = nil, messageFont: UIFont? = nil, titleColor: UIColor? = nil, messageColor: UIColor? = nil, tintColor: UIColor = UIColor.black){
        self.contentViewController = controller
        self.title = title
        self.message = message
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.tintColor = tintColor
        
    }
    
}

struct AlertActionModel {
    var actionIcon: AlertActionIcon? = nil
    var actionTitle: AlertActionTitle!
    var style: UIAlertAction.Style = .cancel
    var alignmentMode:CATextLayerAlignmentMode?
    init(actionIcon icon:AlertActionIcon? = nil,actionTitle title:AlertActionTitle = AlertActionTitle(title: "Cancel") , style:UIAlertAction.Style = .cancel,alignmentMode mode:CATextLayerAlignmentMode? = nil) {
        actionIcon = icon
        actionTitle = title
        self.style = style
        alignmentMode = mode
    }
}
struct AlertActionIcon {
    var image: UIImage!
    var imageColor:UIColor? = nil
    var imageSize:CGSize? = nil
    init(image icon:UIImage, imageColor color:UIColor? = nil, imageSize size:CGSize? = nil) {
        self.image = icon
        self.imageColor = color
        self.imageSize = size
        
    }
    
    var icon:UIImage?{
        if let image = self.image,let color = imageColor , let size = imageSize{
            let img =  image.tinted(with: color)
           return img.resize(to: size)
            
        }else if let image = self.image,let color = imageColor{
           return image.tinted(with: color)
        }else{
            return image
        }
      
    }
}
struct AlertActionTitle {
    var title: String = "Cancel"
    var color: UIColor? = nil
    init(title :String = "Cancel", titleColor color:UIColor? = nil) {
        self.title = title
        self.color = color
    }
   
}
extension UIAlertController{
    
    fileprivate struct ActionCustomKey{
        static let imageKey = "image"
        static let titleTextColorKey = "titleTextColor"
        static let attributedTitleKey = "attributedTitle"
        static let titleTextAlignmentKey = "titleTextAlignment"
        static let attributedMessageKey = "attributedMessage"
        static let contentViewControllerKey = "contentViewController"
    }
    
    fileprivate var cancelButtonIndex        :Int  { return UIAlertActionIndex.cancel.rawValue       }
    fileprivate var firstOtherButtonIndex    :Int  { return UIAlertActionIndex.firstOther.rawValue   }
    fileprivate var destructiveButtonIndex   :Int  { return UIAlertActionIndex.destructive.rawValue  }
    fileprivate var addTextFieldIndex        :Int  { return UIAlertActionIndex.otherField.rawValue   }
    
    //MARK: - convenience init
    convenience init(model:AlertControllerModel, preferredStyle:UIAlertController.Style = .alert, source: Any? = nil) {
        self.init(title: model.title, message: model.message, preferredStyle: preferredStyle, source: source, tintColor: model.tintColor)
        
        if let controller = model.contentViewController {
            self.set(vc: controller)
        }
        if let title  = model.title, let font = model.titleFont , let color  = model.titleColor{
            self.set(title: title, font: font, color: color)
        }
        if let message  = model.message, let font = model.messageFont , let color  = model.messageColor{
            self.set(message: message, font: font, color: color)
        }
    }
    convenience init(title:String?  = nil, message:String?  = nil , preferredStyle:UIAlertController.Style = .alert, source: Any? = nil, tintColor:UIColor = UIColor.black){
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        
        // TODO: for iPad or other views
        #if os(iOS)
        if preferredStyle == .actionSheet, let source = source {
            
            if let barButtonItem = source as? UIBarButtonItem {
                
                if let popoverController = self.popoverPresentationController {
                    popoverController.barButtonItem = barButtonItem
                   
                }
                
            }else if let source = source as? UIView{
                if let popoverController = self.popoverPresentationController {
                    popoverController.sourceView = source
                    popoverController.sourceRect = source.bounds
                }
                
            }
        }
        #endif
        self.view.tintColor = tintColor
    }
    
    //MARK: - presentAlert
    fileprivate func presentAlert(from viewController:UIViewController, completion: (() -> Swift.Void)? = nil){
        DispatchQueue.main.async {
            viewController.present(self, animated: true, completion: completion)
        }
    }
    //MARK: - otherAlertAction
    fileprivate func otherAlertAction(others:[AlertActionModel],handler:@escaping UIAlertActionHandler){
        for (index,obj) in others.enumerated() {
            addAction(action:obj, handler: { (action:UIAlertAction) in
                handler(self,action,self.firstOtherButtonIndex+index)
            })
            
        }
        
    }
    //MARK: - cancelAlertAction
    fileprivate func cancelAlertAction(cancel:AlertActionModel,handler:@escaping UIAlertActionHandler){
        
        addAction(action:cancel, handler: { (action:UIAlertAction) in
            handler(self,action,self.cancelButtonIndex)
        })
        
    }
    //MARK: - destructiveAlertAction
    fileprivate  func destructiveAlertAction(destructive:AlertActionModel,handler:@escaping UIAlertActionHandler){
        addAction(action: destructive, handler: { (action:UIAlertAction) in
            handler(self,action,self.destructiveButtonIndex)
        })
        
    }
    //MARK: - OtherTextField
    fileprivate  func addOtherTextField(placeholders: [AlertFields]?){
        if (placeholders != nil) {
            for (index,element) in placeholders!.enumerated() {
                self.addTextField { textField in
                    textField.tag = self.addTextFieldIndex+index
                    textField.placeholder = NSLocalizedString(element.placeholder, comment: "")
                    textField.borderStyle = element.borderStyle
                    textField.isSecureTextEntry = element.isSecureTextEntry
                }
            }
        }
        
        
    }
    
    
    
    //MARK: - Add an action to Alert
    
    /*
     *   - Parameters:
     *   - title: action title
     *   - style: action style (default is UIAlertActionStyle.default)
     *   - isEnabled: isEnabled status for action (default is true)
     *   - handler: optional action handler to be called when button is tapped (default is nil)
     */
    fileprivate func addAction(action model:AlertActionModel, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: model.actionTitle.title, style: model.style, handler: handler)
        action.isEnabled = isEnabled
        
        // button image
        if let image = model.actionIcon?.icon {
            action.setValue(image, forKey: ActionCustomKey.imageKey)
            
        }
        
        // button title color
        if let color = model.actionTitle.color {
            //titleTextColor
            action.setValue(color, forKey: ActionCustomKey.titleTextColorKey)
        }
        if let alignment = model.alignmentMode {
             action.setValue(alignment, forKey: ActionCustomKey.titleTextAlignmentKey)
        }
    
        addAction(action)
    }
    
    /* Set alert's title, font and color
     *
     * - Parameters:
     *   - title: alert title
     *  - font: alert title font
     *   - color: alert title color
     */
    fileprivate  func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    fileprivate func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: ActionCustomKey.attributedTitleKey)
        
    }
    
    /* Set alert's message, font and color
     *
     *   - Parameters:
     *   - message: alert message
     *   - font: alert message font
     *   - color: alert message color
     */
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    fileprivate func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: ActionCustomKey.attributedMessageKey)
        
    }
    
    /* Set alert's content viewController
     *
     *   - Parameters:
     *   - vc: ViewController
     *   - height: height of content viewController
     */
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: ActionCustomKey.contentViewControllerKey)
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    fileprivate func addAlertAction(actions:Any,otherTextFields placeholders:[AlertFields]? = nil,alertActionHandler:  @escaping UIAlertActionHandler) -> UIAlertController{
        
        if let list  = actions as? [AlertActionModel] {
            var others:[AlertActionModel] = [AlertActionModel]()
            for obj in list{
                if obj.style == .destructive{
                    self.destructiveAlertAction(destructive: obj, handler: alertActionHandler)
                }else if obj.style == .cancel{
                    self.cancelAlertAction(cancel: obj, handler: alertActionHandler)
                }else{
                    others.append(obj)
                }
            }
            
            if others.count>0{
                self.otherAlertAction(others: others, handler: alertActionHandler)
            }
        }else if  let obj = actions as? AlertActionModel{
            if obj.style == .destructive{
                self.destructiveAlertAction(destructive: obj, handler: alertActionHandler)
            }else if obj.style == .default{
                self.otherAlertAction(others: [obj], handler: alertActionHandler)
            }else{
                self.cancelAlertAction(cancel: obj, handler: alertActionHandler)
            }
        }
        
        if (placeholders != nil) {
            self.addOtherTextField(placeholders: placeholders)
        }
        
        return self
    }
    
    //MARK: - Class Functions
    
    class func setupAlertControl(obj:AlertControllerModel, preferredStyle:UIAlertController.Style = .alert, source: UIView? = nil) -> UIAlertController{
        let controller = UIAlertController(model: obj, preferredStyle: preferredStyle, source: source)
//        if let subview = (controller.view.subviews.first?.subviews.first?.subviews.first!){
//            subview.backgroundColor = .bgColor
//        }
        
        return controller
    }
    class func showAlert(from viewController:UIViewController ,controlModel:AlertControllerModel, actions:Any,otherTextFields placeholders:[AlertFields]? = nil, source: UIView? = nil, alertActionHandler:@escaping UIAlertActionHandler)-> UIAlertController{
        
        let alert = self.setupAlertControl(obj: controlModel, preferredStyle: .alert, source: source).addAlertAction(actions: actions, otherTextFields: placeholders, alertActionHandler: alertActionHandler)
        alert.presentAlert(from: viewController) {}
        return alert
        
    }
    class func showActionSheet(from viewController:UIViewController!,controlModel:AlertControllerModel, actions:Any, source: UIView? = nil,alertActionHandler:@escaping UIAlertActionHandler) -> UIAlertController{
        
        let alert = self.setupAlertControl(obj: controlModel, preferredStyle: .actionSheet, source: source).addAlertAction(actions: actions,alertActionHandler: alertActionHandler)
        alert.presentAlert(from: viewController) {}
        return alert
    }
    
}
