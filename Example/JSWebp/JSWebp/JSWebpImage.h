//
//  JSWebpImage.h
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libwebp/decode.h>
#import <libwebp/demux.h>
#import <libwebp/mux_types.h>

@interface JSWebpFrame : NSObject

@property (nonatomic, strong) UIImage       *image;
@property (nonatomic, assign) CGFloat       duration;
@property (nonatomic, assign) WebPData      webPData;
@property (nonatomic, assign) CGFloat       height;
@property (nonatomic, assign) CGFloat       width;
@property (nonatomic, assign) CGFloat       hasAlpha;

@end



@interface JSWebpImage : UIImage

@property (nonatomic, copy)   NSData                        *imageData;
@property (nonatomic, strong) JSWebpFrame                   *currentDisplayFrame;
@property (nonatomic, strong) UIImage                       *currentDisplayImage;
@property (nonatomic, assign) NSInteger                     currentDisplayIndex;
@property (nonatomic, assign) NSInteger                     currentDecodeIndex;
@property (nonatomic, assign) NSInteger                     frameCount;
@property (nonatomic, strong) NSMutableArray<JSWebpFrame *>  *frames;

- (CGFloat)currentDisplayFrameDuration;

- (JSWebpFrame *)decodeCurrentFrame;

- (void)incrementCurrentDisplayIndex;

- (BOOL)isDecodedFinished;

@end
