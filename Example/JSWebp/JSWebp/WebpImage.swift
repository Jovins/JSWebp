//
//  JSWebpImage.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage {

    public convenience init(imageLiteralResourceName name: String) {
        self.init(imageLiteralResourceName: name)
    }
}

struct JS1WebpFrame {
    
    var image: UIImage?
    var duration: CGFloat = 0.0
    var webpData: WebPData?
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var hasAlpha: CGFloat = 0.0
}

class JS1WebpImage: UIImage {
    
    // MARK: - Property
    var imageData: Data = Data()
    var curDisplayIndex: Int = 0
    var curDecodeIndex: Int = 0
    var frameCount: Int = -1
    var frames: [JS1WebpFrame] = []
    
    override init?(data: Data) {
        super.init()
        self.imageData = data
        self.curDisplayIndex = 0
        self.curDecodeIndex = 0
        self.frameCount = -1
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lazy
    lazy var curDisplayFrame: JS1WebpFrame? = {
        if self.frames.count > 0 {
            
            self.curDisplayIndex = self.curDisplayIndex % self.frames.count
            return self.frames[self.curDisplayIndex]
        }
        return nil
    }()
    lazy var curDisplayImage: UIImage? = {
        
        if self.frames.count > 0 {
            
            self.curDisplayIndex = self.curDisplayIndex % self.frames.count
            return self.frames[self.curDisplayIndex].image
        }
        return nil
    }()
    
    // MARK: - Methods
    func incrementCurDisplayIndex() {
        
        self.curDisplayIndex += 1
    }
    
    func isAllFrameDecoded() -> Bool {
        for frame in self.frames.reversed() {
            if frame.image != nil {
                return false
            }
        }
        return true
    }
    
    func images() -> [UIImage] {
        var imgs: [UIImage] = []
        for frame in self.frames {
            if let img = frame.image {
                imgs.append(img)
            }
        }
        return imgs
    }
    
    func curDisplayFrameDuration() -> CGFloat {
        if self.frames.count > 0 {
            let index = self.curDisplayIndex % self.frames.count
            return self.frames[index].duration
        }
        return 0
    }
    
    func decodeCurFrame() -> JS1WebpFrame? {
        
        if self.frames.count > 0 {
            
            objc_sync_enter(self)
            self.curDecodeIndex = self.curDecodeIndex % self.frames.count
            self.curDisplayFrame = self.frames[self.curDecodeIndex]
            self.curDisplayFrame?.image = self
            objc_sync_exit(self)
            
            return self.curDisplayFrame
        }
        return nil
    }
    
    private func decodeWebPFramesInfo(_ imageData: NSData) {
        var data: WebPData = WebPData()
        WebPDataInit(&data)

    }
    
}
