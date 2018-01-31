//
//  FirstViewController.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/29.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "FirstViewController.h"
#import "Masonry.h"
#import <FSAudioStream.h>
#import "PlayerToolViewController.h"
#import <UIImageView+WebCache.h>
#import "AnimationTool.h"
#import "AppDelegate.h"

#define SHARETOOL [PlayerToolViewController sharePlayerTool]
#define ANIMATION [[AnimationTool alloc] init]
@interface FirstViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *columnLabel;
@property (nonatomic, strong) UIImageView *revolveImage;
@property (nonatomic, strong) UILabel *nowTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIProgressView *playerProgress;
@property (nonatomic, strong) UISlider *sliderProgress;
// 进度条滑动过程中 防止因播放器计时器更新进度条的进度导致滑动小球乱动
@property (nonatomic, assign) BOOL sliding;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, assign) BOOL play;
@property (nonatomic, assign) CGFloat playheadTime;
@property (nonatomic, strong) UIButton *lastButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) NSString *currentUrl;

@property (nonatomic , assign) NSInteger executeNumber;

@end

@implementation FirstViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIApplication *app = [UIApplication sharedApplication];
    UIImageView *musicImage = [app.keyWindow viewWithTag:101];
    musicImage.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIApplication *app = [UIApplication sharedApplication];
    UIImageView *musicImage = [app.keyWindow viewWithTag:101];
    if (SHARETOOL.isPlaying) {
        musicImage.hidden = NO;
    }else{
        musicImage.hidden = YES;
    }
    [SHARETOOL removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.00];
    [self createView];
}

- (void)createView{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_titleLabel];
    }
    
    if (!_columnLabel) {
        _columnLabel = [[UILabel alloc] init];
        _columnLabel.font = [UIFont systemFontOfSize:12];
        _columnLabel.textAlignment = NSTextAlignmentCenter;
        _columnLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_columnLabel];
    }
    
    if (!_revolveImage) {
        _revolveImage = [[UIImageView alloc] init];
        [_revolveImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
        _revolveImage.contentMode =  UIViewContentModeScaleAspectFill;
        _revolveImage.clipsToBounds  = YES;
        _revolveImage.layer.cornerRadius = 117.5;
        _revolveImage.layer.masksToBounds = YES;
        [_revolveImage sd_setImageWithURL:[NSURL URLWithString:self.singArr[_index][@"coverMiddle"]]];
        [self.view addSubview:_revolveImage];
    }
#pragma mark 创建播放器
    if (!_nowTimeLabel) {
        _nowTimeLabel = [[UILabel alloc] init];
        _nowTimeLabel.text = @"00:00";
        _nowTimeLabel.textColor = [UIColor whiteColor];
        _nowTimeLabel.textAlignment = NSTextAlignmentCenter;
        _nowTimeLabel.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:_nowTimeLabel];
    }
    if (!_playerProgress) {
        _playerProgress = [[UIProgressView alloc] init];
        //更改进度条高度
        _playerProgress.transform = CGAffineTransformMakeScale(1.0f,1.0f);
        _playerProgress.tintColor = [UIColor blackColor];
        [self.view addSubview:_playerProgress];
    }
    if (!_sliderProgress) {
        _sliderProgress = [[UISlider alloc] init];
        _sliderProgress.value = 0.f;
        _sliderProgress.continuous = YES;
        _sliderProgress.tintColor = [UIColor orangeColor];
        _sliderProgress.maximumTrackTintColor = [UIColor clearColor];
        [self.view addSubview:_sliderProgress];
        [_sliderProgress setThumbImage:[UIImage imageNamed:@"sliderBall"] forState:UIControlStateNormal];
        [_sliderProgress addTarget:self action:@selector(durationSliderTouch:) forControlEvents:UIControlEventValueChanged];
        [_sliderProgress addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:11];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_totalTimeLabel];
    }
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ self.view addSubview:_playButton];
        [_playButton setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_lastButton) {
        _lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_lastButton];
        [_lastButton addTarget:self action:@selector(lastButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_lastButton setImage:[UIImage imageNamed:@"上一曲"] forState:UIControlStateNormal];
    }
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_nextButton];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setImage:[UIImage imageNamed:@"上一曲"] forState:UIControlStateNormal];
        CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI*1.0);
        _nextButton.transform = transform;
    }
    [self viewsLocation];
}
#pragma mark 视图位置
- (void)viewsLocation{
    __weak typeof(self)weakself = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakself.view.mas_centerX);
        make.top.mas_equalTo (5);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(20);
    }];
    [self.columnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakself.view.mas_centerX);
        make.top.mas_equalTo(weakself.titleLabel.mas_bottom).offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(15);
    }];
    [self.revolveImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakself.view.mas_centerX);
        make.top.mas_equalTo(weakself.columnLabel.mas_bottom).offset(30);
        make.width.height.mas_equalTo(235);
    }];
    [self.nowTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).offset(-80);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(10);
    }];
    [self.playerProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.nowTimeLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(weakself.nowTimeLabel.mas_centerY);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 130);
        make.height.mas_equalTo(2);
    }];
    [self.sliderProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.nowTimeLabel.mas_right).offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 130);
        make.top.mas_equalTo(weakself.playerProgress.mas_top).offset(-10);
        make.height.mas_equalTo(20);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.sliderProgress.mas_right).offset(0);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).offset(-80);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(10);
    }];
    [self.lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).offset(-20);
        make.width.height.mas_equalTo(40);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-50);
        make.bottom.mas_equalTo(weakself.view.mas_bottom).offset(-20);
        make.width.height.mas_equalTo(40);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakself.lastButton.mas_centerY);
        make.width.height.mas_equalTo(40);
        make.centerX.mas_equalTo(weakself.view.mas_centerX);
    }];
    
    [self playerInit];
}

#pragma mark 初始化播放器=====================================================
- (void)playerInit{
    
    //监听播放器的播放标志 用于线控控制（个人感觉放在AppDelegate或许更好点，全局播报）
    [SHARETOOL addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    if (SHARETOOL.isPlaying && SHARETOOL.index == self.index) {
    }else{
        SHARETOOL.playArr = self.singArr;
        SHARETOOL.index = self.index;
        [SHARETOOL playerInit];
    }
    SHARETOOL.didPlay = ^(BOOL isPlaying) {
        if (isPlaying) {
            [ANIMATION startAnimateWithLayer:self.revolveImage.layer]; //动画开始
        }else{
            [ANIMATION stopLayer:self.revolveImage.layer];
        }
    };
    SHARETOOL.returnBlock = ^(NSString *totleTime) {
        //总时间
        self.totalTimeLabel.text = totleTime;
    };
    SHARETOOL.returnBlock1 = ^(NSString *currentTime) {
        //当前时间
        self.nowTimeLabel.text = currentTime;
    };
    SHARETOOL.returnBlock2 = ^(CGFloat sliderProgress) {
        //播放进度
        self.sliderProgress.value = sliderProgress;
    };
    SHARETOOL.returnBlock3 = ^(CGFloat playerProgress) {
        //下载进度
        self.playerProgress.progress = playerProgress;
    };
    SHARETOOL.returnBlock4 = ^(BOOL isBank) {
        //是否进入后台
        if (isBank) {
            if (SHARETOOL.isPlaying) {
                [ANIMATION pauseLayer:self.revolveImage.layer];
            }
            NSLog(@"嘿嘿😜");
        }else{
            if (SHARETOOL.isPlaying) {
                [ANIMATION resumeLayer:self.revolveImage.layer];
            }
            NSLog(@"哈哈😜");
        }
    };
    SHARETOOL.returnBlock5 = ^(NSString *title, NSString *nickName) {
        //标题 副标题（换曲的时候赋值）
        _titleLabel.text = [NSString stringWithFormat:@"%@",title];
        _columnLabel.text = [NSString stringWithFormat:@"%@",nickName];
    };
    
    self.play = YES;
    //第一次进入的时候加载
    _titleLabel.text = [NSString stringWithFormat:@"%@",_singArr[_index][@"title"]];
    _columnLabel.text = [NSString stringWithFormat:@"%@",_singArr[_index][@"nickname"]];
    [ANIMATION startAnimateWithLayer:self.revolveImage.layer]; //动画开始
    
}

//滑动
- (void)durationSliderTouch:(UISlider *)slider{
    self.sliding = YES;
    SHARETOOL.isSliding = YES;
}
- (void)reloadprogressValue{
    self.sliding = NO;
    SHARETOOL.isSliding = NO;
}
#pragma mark 拖动进度条到指定位置播放，重新添加播放进度。
- (void)durationSliderTouchEnded:(UISlider *)slider{
    // 添加这个延时是防止滑动小球回弹一下
    [self performSelector:@selector(reloadprogressValue) withObject:self afterDelay:0.5];
    [self slidertoPlay:slider.value];
}
#pragma mark 滑动进度条跳到指定位置，播放状态
- (void)slidertoPlay:(CGFloat)time{
    if (time == 1) {
        [self nextButtonAction];
    }else if (time >= 0) {
        FSStreamPosition pos = {0};
        pos.position = time;
        [SHARETOOL.audioStream seekToPosition:pos];
    }
}

#pragma mark 播放暂停按钮
- (void)playAction{
    //先将未到时间执行前的任务取消
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(theplayAction)object:nil];
    [self performSelector:@selector(theplayAction)withObject:nil afterDelay:0.2f]; // 0.2不可改
}
- (void)theplayAction{
    if (SHARETOOL.isPlaying == YES) {
        [ANIMATION pauseLayer:self.revolveImage.layer];
        [SHARETOOL pause];
        [_playButton setImage:[UIImage imageNamed:@"bofang"] forState:UIControlStateNormal];
    }else{
        [ANIMATION resumeLayer:self.revolveImage.layer];
        [SHARETOOL pause];
        [_playButton setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
    }
}
#pragma mark 上一曲按钮点击方法
- (void)lastButtonAction{
    //先将未到时间执行前的任务取消
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(theLastButtonAction)object:nil];
    [self performSelector:@selector(theLastButtonAction)withObject:nil afterDelay:0.2f]; // 0.2不可改
}
- (void)theLastButtonAction{
    [ANIMATION stopLayer:self.revolveImage.layer];
    [SHARETOOL lastOne];
}
#pragma mark 下一曲按钮点击方法
- (void)nextButtonAction{
    //先将未到时间执行前的任务取消
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(thenextButtonAction)object:nil];
    [self performSelector:@selector(thenextButtonAction)withObject:nil afterDelay:0.2f]; // 0.2不可改
    
}
- (void)thenextButtonAction{
    [ANIMATION stopLayer:self.revolveImage.layer];
    [SHARETOOL nextOne];
}
#pragma mark 解决slider 小范围滑动不能触发的问题
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer locationInView:gestureRecognizer.view].y >= _sliderProgress.frame.origin.y && !_sliderProgress.hidden)
        return NO;
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPlaying"]) {
        if ([change[@"new"] intValue] == 0) {
            [_playButton setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
        }else{
            [_playButton setImage:[UIImage imageNamed:@"bofang"] forState:UIControlStateNormal];
        }
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
