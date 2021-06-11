//
//  JSWebpQueueManager.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class JSWebpQueueManager: NSObject {
    
    let maxCount: Int = 3
    var queueArray: [OperationQueue] = []
    static let shared = JSWebpQueueManager()
    
    override init() {
        super.init()
    }
    
    // add Queue
    func addQueue(_ queue: OperationQueue) {
        
        objc_sync_enter(queueArray)
        if queueArray.contains(queue) {
            // 更新
            let index = queueArray.index(of: queue) ?? 0
            queueArray[index] = queue
        } else {
            // 添加
            queueArray.append(queue)
            queue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
        }
        
        objc_sync_exit(queueArray)
    }
    
    func cancelQueue(_ queue: OperationQueue) {
        objc_sync_enter(queueArray)
        if queueArray.contains(queue) {
            queue.cancelAllOperations()
        }
        objc_sync_exit(queueArray)
    }
    
    func suspendQueue(_ queue: OperationQueue, suspended: Bool) {
        objc_sync_enter(queueArray)
        if queueArray.contains(queue) {
            queue.isSuspended = suspended
        }
        objc_sync_exit(queueArray)
    }
    
    func processQueues() {
        for (index, queue) in queueArray.enumerated() {
            if index < maxCount {
                suspendQueue(queue, suspended: false)
            } else {
                suspendQueue(queue, suspended: true)
            }
        }
    }
    
    // KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "operations" {
            if let queue = object as? OperationQueue {
                if queue.operations.count == 0 {
                    if let index = queueArray.index(of: queue) {
                        queueArray.remove(at: index)
                        processQueues()
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        for queue in queueArray {
            queue.removeObserver(self, forKeyPath: "operations")
        }
    }
}

