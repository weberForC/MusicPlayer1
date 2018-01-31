//
//  AVAudioSession+WBSession.m
//  streamer
//
//  Created by juanMac on 2018/1/4.
//  Copyright © 2018年 fangliguo. All rights reserved.
//

#import "AVAudioSession+WBSession.h"

@implementation AVAudioSession (WBSession)

- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError * _Nullable __autoreleasing *)outError
{
    return YES;
}

@end
