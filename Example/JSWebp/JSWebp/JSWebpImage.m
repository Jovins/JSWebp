//
//  JSWebpImage.m
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "JSWebpImage.h"

@implementation JSWebpFrame

@end

@implementation JSWebpImage

- (instancetype)initWithData:(NSData *)data {
    
    self = [super init];
    _imageData = data;
    _currentDisplayIndex = 0;
    _currentDecodeIndex = 0;
    _frameCount = 1;
    _frames = [NSMutableArray array];
    [self decodeWebpFrames: _imageData];
    return self;
}

// MARK: - Lazy
- (JSWebpFrame *)currentDisplayFrame {
    
    if (_frames.count > 0) {
        _currentDisplayIndex = _currentDisplayIndex % _frames.count;
        return _frames[_currentDisplayIndex];
    }
    return nil;
}

- (UIImage *)currentDisplayImage {
    
    if (_frames.count > 0) {
        _currentDisplayIndex = _currentDisplayIndex % _frames.count;
        return _frames[_currentDisplayIndex].image;
    }
    return nil;
}

// MARK: - Methods
- (JSWebpFrame *)decodeCurrentFrame {
    
    if (_frames.count > 0) {
        @synchronized (self) {
            _currentDecodeIndex = _currentDecodeIndex % _frames.count;
            _currentDisplayFrame = _frames[_currentDecodeIndex];
            _currentDisplayFrame.image = [self decodeWebpImageAtIndex: _currentDecodeIndex++];
            return  _currentDisplayFrame;
        }
    }
    return nil;
}

- (void)incrementCurrentDisplayIndex {
    
    _currentDisplayIndex ++;
}

- (BOOL)isDecodedFinished {
    
    for(NSInteger i=_frames.count-1; i>=0; i--) {
        
        if(!_frames[i].image) {
            return NO;
        }
    }
    return YES;
}

- (NSArray <UIImage *> *)images {
    
    NSMutableArray *imgs = [NSMutableArray array];
    for(JSWebpFrame *frame in _frames) {
        [imgs addObject: frame.image];
    }
    return  imgs;
}

- (CGFloat)currentDisplayFrameDuration {
    
    if (_frames.count >0) {
        NSInteger index = _currentDisplayIndex % _frames.count;
        return _frames[index].duration;
    }
    return 0;
}

- (void)decodeWebpFrames: (NSData *)imageData {
    
    WebPData data;
    WebPDataInit(&data);
    data.bytes = (const uint8_t *)[imageData bytes];
    data.size = [imageData length];
    
    WebPDemuxer *demuxer = WebPDemux(&data);
    uint32_t flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
    
    if (flags & ANIMATION_FLAG) {
        
        WebPIterator iter;
        if (WebPDemuxGetFrame(demuxer, 1, &iter)) {
            
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
            do {
                JSWebpFrame *webPFrame = [JSWebpFrame new];
                webPFrame.duration = iter.duration / 1000.0f;
                webPFrame.webPData = iter.fragment;
                webPFrame.width = iter.width;
                webPFrame.height = iter.height;
                webPFrame.hasAlpha = iter.has_alpha;
                [_frames addObject:webPFrame];
                
            } while (WebPDemuxNextFrame(&iter));
            _frameCount = _frames.count;
            
            CGColorSpaceRelease(colorSpaceRef);
            WebPDemuxReleaseIterator(&iter);
        }
    }
    WebPDemuxDelete(demuxer);
}

static void freeWebpFrameImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

- (UIImage *)decodeWebpImageAtIndex: (NSInteger)index {
    
    JSWebpFrame *webpFrame = _frames[index];
    WebPData frame = webpFrame.webPData;
    WebPDecoderConfig config;
    WebPInitDecoderConfig(&config);
    config.input.height = webpFrame.height;
    config.input.width = webpFrame.width;
    config.input.has_alpha = webpFrame.hasAlpha;
    config.input.has_animation = 1;
    config.options.no_fancy_upsampling = 1;
    config.options.bypass_filtering = 1;
    config.options.use_threads = 1;
    config.output.colorspace = MODE_RGBA;
    config.output.width = webpFrame.width;
    config.output.height = webpFrame.height;
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    
    VP8StatusCode status = WebPDecode(frame.bytes, frame.size, &config);
    if (status != VP8_STATUS_OK) {
        CGColorSpaceRelease(colorRef);
        return nil;
    }
    int imageWidth, imageHeight;
    uint8_t *data = WebPDecodeRGBA(frame.bytes, frame.size, &imageWidth, &imageHeight);
    if (data == NULL) {
        CGColorSpaceRelease(colorRef);
        return nil;
    }
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, imageWidth * imageHeight * 4, freeWebpFrameImageData);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, 4 * imageWidth, colorRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorRef);
    WebPFreeDecBuffer(&config.output);
    return image;
}

@end
