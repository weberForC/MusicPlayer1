//
//  AVPlayToolViewController.h
//  MusicPlayer
//
//  Created by juanMac on 2018/1/30.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YinPinXiangXiBody.h"

@interface AVPlayToolViewController : UIViewController

@property (nonatomic , strong) AVPlayer *player;
@property (nonatomic , strong) AVPlayerItem *playItem;
@property (nonatomic , strong) YinPinXiangXiBody *body;     //给AirPlay传递信息

@property (nonatomic , strong) NSArray *playArr;
@property (nonatomic , assign) NSInteger index;
@property (nonatomic , assign) BOOL isPlaying;
@property (nonatomic , assign) BOOL isSliding;
@property (nonatomic , assign) CGFloat total;

@property (nonatomic , copy) void(^returnTotal)(NSString *totalTime);       //总时间
@property (nonatomic , copy) void(^returnCurrent)(NSString *currentTime);   //当前时间
@property (nonatomic , copy) void(^returnProgress)(CGFloat progress);       //进度条
@property (nonatomic , copy) void(^returnTitle)(NSDictionary *dic);          //标题副标题
@property (nonatomic , copy) void(^returnBank)(BOOL isBank);               //程序是否进入后台
@property (nonatomic , copy) void(^didPlay)(BOOL isPlaying);                 //开始播放

+ (AVPlayToolViewController *)sharedPlayerTool;
- (void)addObserverEnterBackgroundAndForeground;
- (void)playerInit;
- (void)nextOne; //下一首
- (void)lastOne; //上一首
- (void)play;
- (void)pause;   //暂停
- (void)stop;    //停止


@end
