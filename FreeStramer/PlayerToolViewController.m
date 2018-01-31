//
//  PlayerToolViewController.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/29.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "PlayerToolViewController.h"

static PlayerToolViewController *player;
@interface PlayerToolViewController ()

@property (nonatomic, assign) CGFloat playbackTime;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) NSTimer *playerTimer;
@property (nonatomic, assign) BOOL isBank;  //是否进入后台

@end

@implementation PlayerToolViewController

#pragma mark - 程序进入后台和前台
- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    self.isBank = YES;
    if (self.returnBlock4) {
        self.returnBlock4(YES);
    }
}
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    self.isBank = NO;
    dispatch_time_t delayTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000*USEC_PER_SEC));
    dispatch_after(delayTime1, dispatch_get_main_queue(), ^{
        if (self.returnBlock4) {
            self.returnBlock4(NO);
        }
    });
}


//Now Playing Center可以在锁屏界面展示音乐的信息，也达到增强用户体验的作用。
#pragma mark 传递信息到锁屏状态下此方法在播放歌曲与切换歌曲时调用即可
- (void)configNowPlayingCenter:(YinPinXiangXiBody *)body {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    //音乐的标题
    [info setObject:body.title forKey:MPMediaItemPropertyTitle];
    //音乐的艺术家
    [info setObject:body.columnName forKey:MPMediaItemPropertyArtist];
    //音乐的封面
    UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:body.cover]]];
    
    MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
    [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    //完成设置
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
    // NSLog(@"----%lld--------%f------",self.player.currentTime.value,self.totalTime);
}
#pragma mark - 更新AirPlay的数据
- (void)upDateAirPlayTime
{
    /// 更新airPlay后台和锁屏播放进度====================
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo]];
    [dict setObject:@(self.playbackTime)forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    //音乐的总时间
    [dict setObject:@(self.totalTime)forKey:MPMediaItemPropertyPlaybackDuration];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

+ (PlayerToolViewController *)sharePlayerTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[PlayerToolViewController alloc] init];
    });
    return player;
}

- (void)playerInit
{
    if (!_audioStream) {
        _audioStream=[[FSAudioStream alloc]init];
        // 设置声音
        [_audioStream setVolume:1];
        [self addObserverEnterBackgroundAndForeground];
    }
    
    [_audioStream playFromURL:[NSURL URLWithString:self.playArr[_index][@"playUrl32"]]];
    __weak typeof(self) weakSelf = self;
    _audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
        //        NSLog(@"播放出现问题%@",description);
        if (error == kFsAudioStreamErrorNone) {
            NSLog(@"播放出现问题");
        }else if (error == kFsAudioStreamErrorNetwork){
            NSLog(@"请检查网络连接");
        }
        if ([description isEqualToString:@"The stream startup watchdog activated: stream didn't start to play in 30 seconds"]) {
            NSLog(@"播放出现问题");
        }
        if (weakSelf.didPlay) {
            weakSelf.didPlay(NO);
        }
    };
    _audioStream.onCompletion=^(){
        //播放结束 下一首
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * USEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf nextOne];
        });
    };
    self.isPlaying = YES;
    if (self.didPlay) {
        self.didPlay(YES);
    }
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playProgressAction) userInfo:nil repeats:YES];
    self.body = [[YinPinXiangXiBody alloc] init];
    self.body.title = self.playArr[_index][@"title"];
    self.body.columnName = self.playArr[_index][@"nickname"];
    self.body.cover = self.playArr[_index][@"coverMiddle"];
    // 将音频信息添加到Playing Center 锁屏显示播放信息 控制播放暂停
    [self configNowPlayingCenter:self.body];
    
}
//注册通知 进入后台和唤醒
- (void)addObserverEnterBackgroundAndForeground
{
    //注册通知 进入后台和唤醒
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)lastOne
{
    [self.playerTimer invalidate];
    [self stop];
    self.isPlaying = NO;
    if (self.index == 0) {
        self.index = self.playArr.count - 1;
    }else{
        self.index -= 1;
    }
    [self playerInit];
    [self returnTitleAndSubTitle];
}
- (void)nextOne
{
    [self.playerTimer invalidate];
    [self stop];
    self.isPlaying = NO;
    if (self.index == self.playArr.count - 1) {
        self.index = 0;
    }else{
        self.index += 1;
    }
    [self playerInit];
    [self returnTitleAndSubTitle];
}
- (void)pause
{
    if (self.isPlaying) {
        [self.playerTimer setFireDate:[NSDate distantFuture]];
    }else{
        [self.playerTimer setFireDate:[NSDate distantPast]];
    }
    [self.audioStream pause];
    self.isPlaying = !self.isPlaying;
}
- (void)stop
{
    [_audioStream stop];
}

- (void)playProgressAction
{
    FSStreamPosition cur = self.audioStream.currentTimePlayed;
    self.playbackTime =cur.playbackTimeInSeconds/1;  //当前时间 单位秒
    double minutesElapsed = floor(fmod(self.playbackTime/60.0,60.0)); //分
    double secondsElapsed = floor(fmod(self.playbackTime,60.0));     //秒
    NSString *current = [NSString stringWithFormat:@"%02.0f:%02.0f",minutesElapsed, secondsElapsed];
    if (self.returnBlock1) {
        self.returnBlock1(current);
    }
    if (self.isSliding == YES) {
        //slider滑动 这里不作处理 因为定时器一秒执行一次
    }else{
        if (self.returnBlock2) {
            self.returnBlock2(cur.position);
        }
    }
    // 总时长
    self.totalTime = self.playbackTime/cur.position;
    if ([[NSString stringWithFormat:@"%f",self.totalTime] isEqualToString:@"nan"]) {
        if (self.returnBlock) {
            self.returnBlock(@"00:00");
        }
    }else{
        double minutesElapsed1 = floor(fmod(self.totalTime/ 60.0,60.0));
        double secondsElapsed1 = floor(fmod(self.totalTime,60.0));
        NSString *totle = [NSString stringWithFormat:@"%02.0f:%02.0f",minutesElapsed1, secondsElapsed1];
        if (self.returnBlock) {
            self.returnBlock(totle);
        }
    }
    //缓存进度
    float  prebuffer = (float)self.audioStream.prebufferedByteCount;
    float contentlength = (float)self.audioStream.contentLength;
    if (contentlength>0) {
        if (self.returnBlock3) {
            self.returnBlock3(prebuffer /contentlength);
        }
    }
    //更新AirPlay的时间
    if (self.isBank) {
        [self upDateAirPlayTime];
    }
    
}

- (void)returnTitleAndSubTitle
{
    NSString *title = [NSString stringWithFormat:@"%@",self.playArr[_index][@"title"]];
    NSString *nickName = [NSString stringWithFormat:@"%@",self.playArr[_index][@"nickname"]];
    if (self.returnBlock5) {
        self.returnBlock5(title, nickName);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
