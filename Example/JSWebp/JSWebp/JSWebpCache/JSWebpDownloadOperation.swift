//
//  JSWebpDownloadOperation.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

class JSWebpDownloadOperation: Operation {
    
    /// 下载回调
    var progressClosure: JSWebpDownloadProgressClosure?
    var completedClosure: JSWebpDownloadCompletedClosure?
    var cancelClosure: JSWebpDownloadCancelClosure?
    
    /// 网络请求
    var session: URLSession?
    var dataTask: URLSessionTask?
    var request: URLRequest?
    
    /// 数据
    var imageData: Data?
    /// 资源总大小
    var expectedSize: Int64?
    /// 任务是否执行
    var _executing: Bool = false
    /// 任务是否完成
    var _finished: Bool = false
    /// Init
    init(request: URLRequest, progress:@escaping JSWebpDownloadProgressClosure, completed:@escaping JSWebpDownloadCompletedClosure, cancel:@escaping JSWebpDownloadCancelClosure) {
        super.init()
        self.request = request
        self.progressClosure = progress
        self.completedClosure = completed
        self.cancelClosure = cancel
    }
    
    override func start() {
        
        willChangeValue(forKey: "isExecuting")
        _executing = true
        didChangeValue(forKey: "isExecuting")
        if self.isCancelled {
            self.done()
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        if let request = self.request {
            self.dataTask = self.session?.dataTask(with: request)
        }
        self.dataTask?.resume()
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
        self.done()
        objc_sync_exit(self)
    }
    
    func done() {
        
        super.cancel()
        if _executing {
            willChangeValue(forKey: "isFinished")
            willChangeValue(forKey: "isExecuting")
            _finished = true
            _executing = false
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
            self.reset()
        }
    }
    
    /// 重置
    func reset() {
        if (self.dataTask != nil) {
            self.dataTask?.cancel()
        }
        if (self.session != nil) {
            self.session?.invalidateAndCancel()
            self.session = nil
        }
    }
}

extension JSWebpDownloadOperation: URLSessionDataDelegate, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let httpResponse = dataTask.response as? HTTPURLResponse else {
            return
        }
        let code = httpResponse.statusCode
        if code == 200 {
            completionHandler(.allow)
            self.imageData = Data()
            expectedSize = httpResponse.expectedContentLength
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
     
        if self.completedClosure != nil {
            if error != nil {
                let err = error! as NSError
                if err.code == NSURLErrorCancelled {
                    self.cancelClosure?()
                } else {
                    self.completedClosure?(nil, error, false)
                }
            } else {
                if let img = self.imageData {
                    self.completedClosure?(img, nil, true)
                }
            }
        }
        self.done()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.imageData?.append(data)
        if self.progressClosure != nil {
            progressClosure?(Int64(imageData?.count ?? 0), self.expectedSize ?? 0)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        
        let cacheResponse = proposedResponse
        if(request?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData) {
            completionHandler(nil)
            return
        }
        completionHandler(cacheResponse)
    }
}
