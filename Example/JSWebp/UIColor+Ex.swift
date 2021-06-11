//
//  UIColor+Ex.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(_ r256: CGFloat, _ g256: CGFloat, _ b256: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r256 / 255.0, green: g256 / 255.0, blue: b256 / 255.0, alpha: alpha)
    }
    
    static func random() -> UIColor {
        
        return UIColor(CGFloat(arc4random() % 255), CGFloat(arc4random() % 255), CGFloat(arc4random() % 255))
    }
}
