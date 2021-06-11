//
//  JSWebpImageOperation.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// 解码完成回调
typealias WebpCompletedClosure = (_ frame: JSWebpFrame?) -> Void

class JSWebpImageOperation: Operation {
    
    var completedClosure: WebpCompletedClosure?
    var image: JSWebpImage?
    // 记录任务是否执行
    var _executing: Bool = false
    // 记录任务是否完成
    var _finished: Bool = false
    
    init(_ image: JSWebpImage, completed: @escaping WebpCompletedClosure) {
        
        super.init()
        self.image = image
        self.completedClosure = completed
    }
    
    override func start() {
        willChangeValue(forKey: "isExecuting")
        _executing = true
        didChangeValue(forKey: "isExecuting")
        if self.isCancelled {
            done()
            return
        }
        if let img = self.image {
            let frame = img.decodeCurrentFrame()
            // 上一步为耗时操作，判断任务执行前是否取消任务
            if self.isCancelled {
                done()
                return
            }
            completedClosure?(frame)
            done()
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func cancel() {
        objc_sync_enter(self)
        done()
        objc_sync_exit(self)
    }
    
    func done() {
        
        super.cancel()
        if(_executing) {
            willChangeValue(forKey: "isFinished")
            willChangeValue(forKey: "isExecuting")
            _finished = true
            _executing = false
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
        }
    }
}
