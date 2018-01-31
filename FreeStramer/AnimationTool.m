//
//  AnimationTool.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/30.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "AnimationTool.h"

@implementation AnimationTool

//开始动画
- (void)startAnimateWithLayer:(CALayer *)layer{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.speed = 1;
    rotationAnimation.duration = 25;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    rotationAnimation.removedOnCompletion = NO;
    [layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//暂停layer上面的动画
- (void)pauseLayer:(CALayer*)layer{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续layer上面的动画
- (void)resumeLayer:(CALayer*)layer{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

//停止动画
- (void)stopLayer:(CALayer *)layer{
    [layer removeAnimationForKey:@"rotationAnimation"];
}



@end
