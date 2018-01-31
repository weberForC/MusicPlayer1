//
//  AnimationTool.h
//  MusicPlayer
//
//  Created by juanMac on 2018/1/30.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimationTool : NSObject

- (void)startAnimateWithLayer:(CALayer *)layer;
- (void)pauseLayer:(CALayer*)layer;
- (void)resumeLayer:(CALayer*)layer;
- (void)stopLayer:(CALayer *)layer;

@end
