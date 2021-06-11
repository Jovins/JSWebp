//
//  JSWebpDownloader.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

class JSWebpDownloader: NSObject {
    
    var downloadQueue: OperationQueue?
    static let shared = JSWebpDownloader()
    
    override init() {
        super.init()
        self.downloadQueue = OperationQueue()
        self.downloadQueue?.name = "com.jovins.webpdownload"
        self.downloadQueue?.maxConcurrentOperationCount = 8
    }
    
    /// 下载
    func dowload(_ url: URL, progress:@escaping JSWebpDownloadProgressClosure, completed:@escaping JSWebpDownloadCompletedClosure, cancel:@escaping JSWebpDownloadCancelClosure) -> JSWebpCombineOperation {
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpShouldUsePipelining = true
        let key = url.absoluteString
        let operation = JSWebpCombineOperation()
        operation.cacheOperation = JSWebpCacheManager.shared.queryDataFromMemory(key, cacheQueryCompletedClosure: { [weak self] (data, isCache) in
            guard let `self` = self else { return }
            if isCache {
                completed(data as? Data, nil, true)
            } else {
                
                let downloadOperation = JSWebpDownloadOperation(request: request, progress: progress) { (data, error, finish) in
                    
                    if finish && error == nil {
                        JSWebpCacheManager.shared.storeDataToCache(data, key: key)
                        completed(data, nil, true)
                    } else {
                        completed(data, error, false)
                    }
                } cancel: {
                    cancel()
                }
                operation.downloadOperation = downloadOperation
                self.downloadQueue?.addOperation(downloadOperation)
            }
        })
        
        return operation
    }
}
