//
//  PlayerToolViewController.h
//  MusicPlayer
//
//  Created by juanMac on 2018/1/29.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FSAudioStream.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YinPinXiangXiBody.h"
#import "AVAudioSession+WBSession.h"

@interface PlayerToolViewController : UIViewController

@property (nonatomic , strong) FSAudioStream *audioStream;
@property (nonatomic , strong) NSArray *playArr;          //曲目列表数据
@property (nonatomic , assign) NSInteger index;           //播放第几首
@property (nonatomic , assign) BOOL isPlaying;           //正在播放
@property (nonatomic , assign) BOOL isSliding;           //正在滑动slider
@property (nonatomic , strong) YinPinXiangXiBody *body;     //给AirPlay传递信息
@property (nonatomic , copy) void(^returnBlock)(NSString *totleTime);        //回传时间总长
@property (nonatomic , copy) void(^returnBlock1)(NSString *currentTime);     //回传当前时间
@property (nonatomic , copy) void(^returnBlock2)(CGFloat sliderProgress);    //回传播放进度
@property (nonatomic , copy) void(^returnBlock3)(CGFloat playerProgress);    //回传下载进度
@property (nonatomic , copy) void(^returnBlock4)(BOOL isBank);               //程序是否进入后台
@property (nonatomic , copy) void(^returnBlock5)(NSString *title,NSString *nickName);  //返回标题副标题
@property (nonatomic , copy) void(^didPlay)(BOOL isPlaying);                 //开始播放


+(PlayerToolViewController *)sharePlayerTool;
- (void)addObserverEnterBackgroundAndForeground;
- (void)playerInit;
- (void)nextOne; //下一首
- (void)lastOne; //上一首
- (void)pause;   //继续/暂停
- (void)stop;    //停止

@end
