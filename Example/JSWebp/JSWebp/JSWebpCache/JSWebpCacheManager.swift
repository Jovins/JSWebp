//
//  JSWebpCacheManager.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

/// 清除缓存回调
typealias JSWebpCacheClearCompletedClosure = (_ cacheSize: String) -> Void

/// 缓存查询回调
typealias JSWebpCacheQueryCompletedClosure = (_ data: Any?, _ hasCache: Bool) -> Void

/// 下载进度
typealias JSWebpDownloadProgressClosure = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void

/// 下载完成
typealias JSWebpDownloadCompletedClosure = (_ data: Data?, _ error: Error?, _ finished: Bool) -> Void

/// 下载取消
typealias JSWebpDownloadCancelClosure = () -> Void

class JSWebpCacheManager: NSObject {
    
    var cache: NSCache<NSString, AnyObject>?
    var fileManager: FileManager = FileManager.default
    var diskCacheURL: URL?
    var ioQueue: DispatchQueue?
    static let shared = JSWebpCacheManager()
    override init() {
        super.init()
        self.cache = NSCache()
        self.cache?.name = "webpCache"
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths.last
        let diskPath = path ?? "" + "/webpCache"
        
        var isDirectory: ObjCBool = false
        let isExisted = fileManager.fileExists(atPath: diskPath, isDirectory: &isDirectory)
        if(!isDirectory.boolValue || !isExisted) {
            do {
                try fileManager.createDirectory(atPath: diskPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create disk cache file error:" + error.localizedDescription)
            }
        }
        self.diskCacheURL = URL(fileURLWithPath: diskPath)
        self.ioQueue = DispatchQueue(label: "com.jovins.webpcache")
    }
    
    // MARK: - Query Data
    /// 查询缓存数据
    func queryDataFromMemory(_ key: String, cacheQueryCompletedClosure: JSWebpCacheQueryCompletedClosure) -> Operation {
        return self.queryDataFromMemory(key, cacheQueryCompletedClosure: cacheQueryCompletedClosure, exten: nil)
    }
    
    func queryDataFromMemory(_ key: String, cacheQueryCompletedClosure: JSWebpCacheQueryCompletedClosure, exten: String?) -> Operation {
     
        let operation = Operation()
        self.ioQueue?.sync {
            if(operation.isCancelled) {
                return
            }
            if let data = self.getDataFromMemoryCache(key) {
                
                cacheQueryCompletedClosure(data, true)
            } else if let data = self.getDataFromDiskCache(key, exten: exten) {
                
                self.storeDataToMemoryCache(data, key: key)
                cacheQueryCompletedClosure(data, true)
            } else {
                cacheQueryCompletedClosure(nil, false)
            }
        }
        return operation
    }
    
    /// 查询磁盘数据
    func queryDataFromDiskMemory(_ key: String, cacheQueryCompletedClosure: JSWebpCacheQueryCompletedClosure) -> Operation {
        return self.queryDataFromDiskMemory(key, cacheQueryCompletedClosure: cacheQueryCompletedClosure, exten: nil)
    }
    
    /// 查询磁盘数据指定文件类型
    func queryDataFromDiskMemory(_ key: String, cacheQueryCompletedClosure: JSWebpCacheQueryCompletedClosure, exten: String?) -> Operation {

        let operation = Operation()
        self.ioQueue?.sync {
            if operation.isCancelled {
                return
            }
            let path = self.diskCachePathForKey(key, exten: exten) ?? ""
            if self.fileManager.fileExists(atPath: path) {
                cacheQueryCompletedClosure(path, true)
            } else {
                cacheQueryCompletedClosure(path, false)
            }
        }
        return operation
    }
    
    // MARK: - Get Data From Memory
    /// 查询内存中数据
    func getDataFromMemoryCache(_ key: String) -> Data? {
        return self.cache?.object(forKey: key as NSString) as? Data
    }
    
    /// 查询磁盘中数据
    func getDataFromDiskCache(_ key: String) -> Data? {
        
        self.getDataFromDiskCache(key, exten: nil)
    }
    
    func getDataFromDiskCache(_ key: String, exten: String?) -> Data? {
        
        if let cachePath = self.diskCachePathForKey(key, exten: exten) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: cachePath))
                return data
            } catch {}
        }
        return nil
    }
    
    // MARK: - Store Data
    /// 存储数据
    func storeDataToCache(_ data: Data?, key: String) {
        self.ioQueue?.async {
            self.storeDataToMemoryCache(data, key: key)
            self.storeDataToDiskCache(data, key: key)
        }
    }
    
    /// 存储数据到内存
    func storeDataToMemoryCache(_ data: Data?, key: String) {
        self.cache?.setObject(data as AnyObject, forKey: key as NSString)
    }
    
    /// 存储数据到磁盘
    func storeDataToDiskCache(_ data: Data?, key: String) {
        self.storeDataToDiskCache(data, key: key, exten: nil)
    }
    /// 存储数据到磁盘
    func storeDataToDiskCache(_ data: Data?, key: String, exten: String?) {
        
        if let diskPath = self.diskCachePathForKey(key, exten: exten) {
            self.fileManager.createFile(atPath: diskPath, contents: data, attributes: nil)
        }
    }
    
    // MARK: - Deal Methods
    /// 获取磁盘路径
    func diskCachePathForKey(_ key: String) -> String? {
        return self.diskCachePathForKey(key, exten: nil)
    }
    
    /// 获取磁盘路径
    func diskCachePathForKey(_ key: String, exten: String?) -> String? {
        let filename = self.md5(key)
        var cachePath = self.diskCacheURL?.appendingPathComponent(filename).path
        if exten != nil && cachePath != nil {
            cachePath = cachePath! + "." + exten!
        }
        return cachePath
    }
    
    /// 清除内存和磁盘缓存
    func clearCache(_ cacheClearComletedClosure: @escaping JSWebpCacheClearCompletedClosure) {
        self.ioQueue?.async {
            self.clearMemoryCache()
            let cacheSize = self.clearDiskCache()
            DispatchQueue.main.async {
                cacheClearComletedClosure(cacheSize)
            }
        }
    }
    
    /// 清除内存存
    func clearMemoryCache() {
        self.cache?.removeAllObjects()
    }
    
    /// 清除磁盘缓存
    func clearDiskCache() -> String {
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: (self.diskCacheURL?.path)!)
            var folderSize:Float = 0
            for fileName in contents {
                let filePath = (self.diskCacheURL?.path)! + "/" + fileName
                let fileDict = try fileManager.attributesOfItem(atPath: filePath)
                folderSize += fileDict[FileAttributeKey.size] as! Float
                try fileManager.removeItem(atPath: filePath)
            }
            return String.format(decimal: folderSize/1024.0/1024.0) ?? "0"
        } catch {
            print("clearDiskCache error:"+error.localizedDescription)
        }
        return "0"
    }
    
    // MARK: - MD5
    func md5(_ key: String) -> String {
        
        guard let cstr = key.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else {
            return ""
        }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cstr, CC_LONG(strlen(cstr)), buffer)
        var md5String = ""
        for idx in 0...15 {
            let obcStrl = String.init(format: "%02x", buffer[idx])
            md5String.append(obcStrl)
        }
        free(buffer)
        return md5String
    }
}
