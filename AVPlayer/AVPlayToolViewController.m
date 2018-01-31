//
//  AVPlayToolViewController.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/30.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "AVPlayToolViewController.h"
#import "AppDelegate.h"

@interface AVPlayToolViewController ()

@property (nonatomic , strong) NSString *playbackTime;
@property (nonatomic , strong) NSString *totalTime;
@property (nonatomic , assign) BOOL isBank;  //是否进入后台
@property (nonatomic ,strong)  id timeObser;

@end

@implementation AVPlayToolViewController

+ (AVPlayToolViewController *)sharedPlayerTool
{
    static AVPlayToolViewController *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[AVPlayToolViewController alloc] init];
    });
    return player;
}

- (void)playerInit
{
    if (!_player) {
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",_playArr[_index][@"playUrl32"]]];
        self.playItem = [[AVPlayerItem alloc]initWithURL:fileURL];
        self.player = [[AVPlayer alloc]initWithPlayerItem:self.playItem];
        [self addObserverEnterBackgroundAndForeground];
        //后台播放
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }else{
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",_playArr[_index][@"playUrl32"]]];
        self.playItem = [[AVPlayerItem alloc]initWithURL:fileURL];
        [self.player replaceCurrentItemWithPlayerItem:self.playItem];
    }
    self.body = [[YinPinXiangXiBody alloc] init];
    self.body.title = self.playArr[_index][@"title"];
    self.body.columnName = self.playArr[_index][@"nickname"];
    self.body.cover = self.playArr[_index][@"coverMiddle"];
    // 将音频信息添加到Playing Center 锁屏显示播放信息 控制播放暂停
    [self configNowPlayingCenter:self.body];
    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)manageInformation
{
    CMTime duration = self.player.currentItem.asset.duration;
    NSTimeInterval total = CMTimeGetSeconds(duration);
    self.totalTime = [self timeIntervalToMMSSFormat:total];
    if (self.returnTotal) {
        self.returnTotal(self.totalTime);
    }
    __weak typeof(self) weakSelf = self;
    _timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        //更新时间和进度条
        float current = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        float total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        weakSelf.playbackTime = [weakSelf timeIntervalToMMSSFormat:CMTimeGetSeconds(time)];
        weakSelf.totalTime = [weakSelf timeIntervalToMMSSFormat:total];
        if (weakSelf.returnTotal) {
            weakSelf.returnTotal(weakSelf.totalTime);
        }
        if (weakSelf.returnCurrent) {
            weakSelf.returnCurrent(weakSelf.playbackTime);
        }
        if (!weakSelf.isSliding) {
            //拖动slider的时候不更新进度条
            //            weakSelf.progressSlider.value = current / weakSelf.total;
            CGFloat progress = current / total;
            if (weakSelf.returnProgress) {
                weakSelf.returnProgress(progress);
            }
        }
        if (weakSelf.isBank) {
            /// 更新airPlay后台和锁屏播放进度====================
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo]];
            [dict setObject:@(current) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            //音乐的总时间
            [dict setObject:@(total) forKey:MPMediaItemPropertyPlaybackDuration];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nextOne) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.playItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"biaozhi = %d",self.isPlaying);
            [self.player play];
            self.isPlaying = YES;
            [self manageInformation];
            if (self.didPlay) {
                self.didPlay(YES);
            }
            [self returnTitleAndSubTitle];
        }else if (status == AVPlayerItemStatusFailed){
            if (self.didPlay) {
                self.didPlay(NO);
            }
            NSLog(@"AVPlayerItemStatusFailed");
        }else{
            NSLog(@"AVPlayerItemStatusUnknow");
        }
    }
}

- (void)nextOne
{
    [self removeObservers];
    self.isPlaying = NO;
    if (self.index == self.playArr.count - 1) {
        self.index = 0;
    }else{
        self.index += 1;
    }
    [self playerInit];
    [self returnTitleAndSubTitle];
}
- (void)lastOne
{
    [self removeObservers];
    self.isPlaying = NO;
    if (self.index == 0) {
        self.index = self.playArr.count - 1;
    }else{
        self.index -= 1;
    }
    [self playerInit];
    [self returnTitleAndSubTitle];
}
- (void)play
{
    [self.player play];
    self.isPlaying = YES;
}
- (void)pause
{
    [self.player pause];
    self.isPlaying = NO;
}
- (void)stop
{
    self.playItem = nil;
    self.player = nil;
    self.isPlaying = NO;
}

#pragma mark - 时间转化
- (NSString *)timeIntervalToMMSSFormat:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (void)removeObservers
{
    [self.player removeTimeObserver:_timeObser];
    [self.playItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)returnTitleAndSubTitle
{
    NSString *title = [NSString stringWithFormat:@"%@",self.playArr[_index][@"title"]];
    NSString *nickName = [NSString stringWithFormat:@"%@",self.playArr[_index][@"nickname"]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:title,@"title",nickName,@"nickName", nil];
    if (self.returnTitle) {
        self.returnTitle(dic);
    }
}

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

#pragma mark - 程序进入后台和前台
- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    self.isBank = YES;
    if (self.returnBank) {
        self.returnBank(YES);
    }
}
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    self.isBank = NO;
    dispatch_time_t delayTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000*USEC_PER_SEC));
    dispatch_after(delayTime1, dispatch_get_main_queue(), ^{
        if (self.returnBank) {
            self.returnBank(NO);
        }
    });
}

#pragma mark - 更新AirPlay的数据
- (void)upDateAirPlayTime
{
    /// 更新airPlay后台和锁屏播放进度====================
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo]];
    [dict setObject:self.playbackTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    //音乐的总时间
    [dict setObject:self.totalTime forKey:MPMediaItemPropertyPlaybackDuration];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
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
