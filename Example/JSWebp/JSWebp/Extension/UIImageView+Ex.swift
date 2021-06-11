//
//  UIImageView+Ex.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

typealias JSWebpImageProgressClosure = (_ persent: Float) -> Void
typealias JSWebpImageCompletedClosure = (_ image: UIImage?, _ error: Error?) -> Void
typealias JSWebpImageCancelClosure = () -> Void

extension UIImageView {
    
    static var operationKey = "operationKey"
    var operation: JSWebpCombineOperation? {
        get{
            return objc_getAssociatedObject(self, &UIImageView.operationKey) as? JSWebpCombineOperation
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.operationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Image
    func setImageWithURL(_ url:URL, completed: JSWebpImageCompletedClosure?) {
        self.setImageWithURL(url, progress: nil, completed: completed, cancel: nil)
    }
    
    func setImageWithURL(_ url:URL, progress: JSWebpImageProgressClosure?, completed: JSWebpImageCompletedClosure?) {
        self.setImageWithURL(url, progress: progress, completed: completed, cancel: nil)
    }
    
    func setImageWithURL(_ url:URL, progress: JSWebpImageProgressClosure?, completed: JSWebpImageCompletedClosure?, cancel: JSWebpImageCancelClosure?) {
        
        self.cancelOperation()
        self.operation = JSWebpDownloader.shared.dowload(url, progress: { (receive, expected) in
            DispatchQueue.main.async {
                progress?(Float(receive/expected))
            }
        }, completed: { (data, error, finish) in
            
            var image: UIImage?
            if finish && data != nil {
                image = UIImage(data: data!)
            }
            DispatchQueue.main.async {
                completed?(image, error)
            }
        }, cancel: {
            cancel?()
        })
    }
    
    /// Webp
    func setWebpImageWithURL(_ url: URL, completed: JSWebpImageCompletedClosure?) {
        self.setWebpImageWithURL(url, progress: nil, completed: completed, cancel: nil)
    }
    
    func setWebpImageWithURL(_ url: URL, progress: JSWebpImageProgressClosure?, completed: JSWebpImageCompletedClosure?) {
        self.setWebpImageWithURL(url, progress: progress, completed: completed, cancel: nil)
    }
    
    func setWebpImageWithURL(_ url: URL, progress: JSWebpImageProgressClosure?, completed: JSWebpImageCompletedClosure?, cancel: JSWebpImageCancelClosure?) {
        
        self.cancelOperation()
        self.operation = JSWebpDownloader.shared.dowload(url, progress: { (receive, expected) in
            DispatchQueue.main.async {
                progress?(Float(receive/expected))
            }
        }, completed: { (data, error, finish) in
            
            var image: JSWebpImage?
            if finish && data != nil {
                image = JSWebpImage(data: data!)
            }
            DispatchQueue.main.async {
                completed?(image, error)
            }
        }, cancel: {
            cancel?()
        })
    }
    
    func cancelOperation() {
        if self.operation != nil {
            self.operation?.cancel()
        }
    }
}
