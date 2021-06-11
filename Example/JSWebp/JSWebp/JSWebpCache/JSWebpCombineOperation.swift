//
//  JSWebpCombineOperation.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class JSWebpCombineOperation: NSObject {
    
    /// 下载取消
    var cacelClosure: JSWebpDownloadCancelClosure?
    /// 查询缓存任务
    var cacheOperation: Operation?
    /// 下载任务
    var downloadOperation: JSWebpDownloadOperation?
    /// 取消查询缓存和下载资源任务
    func cancel() {
        if self.cacheOperation != nil {
            self.cacheOperation?.cancel()
            self.cacheOperation = nil
        }
        if self.downloadOperation != nil {
            self.downloadOperation?.cancel()
            self.downloadOperation = nil
        }
        if self.cacelClosure != nil {
            self.cacelClosure?()
            self.cacelClosure = nil
        }
    }
}
