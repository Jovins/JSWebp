//
//  JSWebpImageView.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/11.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class JSWebpImageView: UIImageView {
    
    // 更新画面计时器
    var displayLink: CADisplayLink?
    // 解码队列
    var queue: OperationQueue = OperationQueue()
    var firstQueue: OperationQueue = OperationQueue()
    var time: TimeInterval = 0
    var operationCount: Int = 0
    private var _image: JSWebpImage?
    override var image: UIImage? {
        set {
            super.image = newValue
            _image = newValue as? JSWebpImage
            displayLink?.isPaused = true
            JSWebpQueueManager.shared.cancelQueue(queue)
            firstQueue.cancelAllOperations()
            time = 0
            operationCount = 0
            displayLink?.isPaused = false
            
            decodeWebpFrame()
        }
        get {
            return _image
        }
    }
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        self.initJSWebpImageView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initJSWebpImageView()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.image = image
        self.initJSWebpImageView()
    }
    
    private func initJSWebpImageView() {
        
        self.backgroundColor = .clear
        self.displayLink = CADisplayLink(target: self, selector: #selector(startAnimation(_:)))
        self.displayLink?.add(to: RunLoop.current, forMode: .commonModes)
        self.displayLink?.isPaused = true
        self.queue.maxConcurrentOperationCount = 1
        self.queue.qualityOfService = .utility
        self.firstQueue.maxConcurrentOperationCount = 1
        self.firstQueue.qualityOfService = .userInteractive
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    // 解码Webp动图
    func decodeWebpFrame() {
        
        let operation = JSWebpImageOperation(self.image as? JSWebpImage ?? JSWebpImage()) { [weak self] (frame) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.layer.contents = frame?.image.cgImage ?? nil
            }
        }
        
        self.operationCount += 1
        self.firstQueue.addOperation(operation)
        while self.operationCount < (self.image as? JSWebpImage)?.frameCount ?? 0 {
            
            let operation = JSWebpImageOperation(self.image as? JSWebpImage ?? JSWebpImage()) { [weak self] (frame) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.layer.setNeedsDisplay()
                }
            }
            self.operationCount += 1
            self.queue.addOperation(operation)
        }
        JSWebpQueueManager.shared.addQueue(self.queue)
    }
    
    @objc
    func startAnimation(_ link: CADisplayLink) {
        
        guard let img = self.image as? JSWebpImage else { return }
        if img.isDecodedFinished() {
            self.layer.setNeedsDisplay()
        }
    }
    
    override func display(_ layer: CALayer) {
        
        guard let img = self.image as? JSWebpImage else { return }
        if time == 0 {
            self.layer.contents = img.currentDisplayFrame.image.cgImage
            img.incrementCurrentDisplayIndex()
        }
        time += self.displayLink?.duration ?? 0 / 2
        if time >= Double(img.currentDisplayFrameDuration()) {
            time = 0
        }
    }
    
}
