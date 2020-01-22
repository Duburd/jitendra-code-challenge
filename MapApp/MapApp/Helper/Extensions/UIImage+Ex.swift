//
//  UIImage+Ex.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
public extension UIImage {
    
    // MARK: Resizing
    /// Resizes `UIImage` image to an image with new size.
    ///
    /// - Parameter size: The target size in point.
    /// - Returns: An image with new size.
    /// - Note: This method only works for CG-based image. The current image scale is kept.
    ///         For any non-CG-based image, `UIImage` itself is returned.
    func resize(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            
            newSize =  .init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = .init(width: size.width * widthRatio, height: size.height * widthRatio)
            
            
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect:CGRect = .init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    
    // MARK: Tint
    /// Creates an image from `UIImage` image with a color tint.
    ///
    /// - Parameter color: The color should be used to tint `UIImage`
    /// - Returns: An image with a color tint applied.
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
        
        
    }
    
    
}
