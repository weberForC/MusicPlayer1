//
//  SecondViewController.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/31.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "SecondViewController.h"
#import "UIColor+Tools.h"
#import "Masonry.h"
#import "AVPlayToolViewController.h"
#import "AnimationTool.h"

#define FIT_W [UIScreen mainScreen].bounds.size.width / 375
#define FIT_H [UIScreen mainScreen].bounds.size.height / 667
#define AVPLAYTOOL [AVPlayToolViewController sharedPlayerTool]
#define ANIMATION [[AnimationTool alloc] init]
@interface SecondViewController ()

@property (nonatomic,strong) UIImageView *musicImageView;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UILabel *beginTimeLabel;
@property (nonatomic,strong) UILabel *endTimeLabel;
@property (nonatomic,strong) UISlider *progressSlider;
@property (nonatomic,assign) __block BOOL isSliderTouch;
@property (nonatomic,strong) UILabel *musicNameLabel;
@property (nonatomic,strong) UILabel *subNameLabel;

@end

@implementation SecondViewController

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
    if (AVPLAYTOOL.isPlaying) {
        musicImage.hidden = NO;
    }else{
        musicImage.hidden = YES;
    }
    [AVPLAYTOOL removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    [self createUI];
}

- (void)createUI{
    __weak typeof(self) weakSelf = self;
    CGFloat imageViewWidth = 375 *FIT_W * .7;
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"床边故事.jpg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = imageViewWidth /2;
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view.mas_centerY).offset(-80*FIT_H);
        make.centerX.equalTo(weakSelf.view);
        make.width.height.equalTo(@(imageViewWidth));
    }];
    self.musicImageView = imageView;
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"icon_stop"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(imageView);
    }];
    self.playButton = playButton;
    
    self.musicNameLabel = [[UILabel alloc]init];
    _musicNameLabel.text = @"";
    _musicNameLabel.font = [UIFont systemFontOfSize:17.f];
    _musicNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.musicNameLabel];
    [_musicNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(imageView.mas_bottom).offset(30);
    }];
    
    UILabel *sizeLabel = [[UILabel alloc]init];
    sizeLabel.text = @"";
    sizeLabel.font = [UIFont systemFontOfSize:15.f];
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    sizeLabel.textColor = [UIColor grayColor];
    [self.view addSubview:sizeLabel];
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.musicNameLabel.mas_bottom).offset(10);
    }];
    self.subNameLabel = sizeLabel;
    
    UISlider *slider = [[UISlider alloc]init];
    slider.minimumTrackTintColor = [UIColor colorWithHexString:@"37ccff"];
    slider.maximumTrackTintColor = [UIColor colorWithHexString:@"484848"];
    [slider setThumbImage:[UIImage imageNamed:@"icon_sliderButton"] forState:UIControlStateNormal];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view.mas_bottom).offset(- 60 *FIT_H);
        make.width.equalTo(@(imageViewWidth));
        make.centerX.equalTo(weakSelf.view);
    }];
    self.progressSlider = slider;
    
    UILabel *leftTimeLabel = [[UILabel alloc]init];
    leftTimeLabel.text = @"00:00";
    leftTimeLabel.textColor = [UIColor grayColor];
    leftTimeLabel.font = [UIFont systemFontOfSize:12.f];
    [self.view addSubview:leftTimeLabel];
    [leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(slider.mas_left).offset(-8);
        make.centerY.equalTo(slider);
    }];
    self.beginTimeLabel = leftTimeLabel;
    
    UILabel *rightTimeLabel = [[UILabel alloc]init];
    rightTimeLabel.text = @"00:00";
    rightTimeLabel.textColor = [UIColor grayColor];
    rightTimeLabel.font = [UIFont systemFontOfSize:12.f];
    [self.view addSubview:rightTimeLabel];
    [rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(slider.mas_right).offset(8);
        make.centerY.equalTo(slider);
    }];
    self.endTimeLabel = rightTimeLabel;
    
    [self settingPlayer];
}

- (void)settingPlayer
{
    //监听播放器的播放标志 用于线控控制 （个人感觉放在AppDelegate或许更好点，全局播报）
    [AVPLAYTOOL addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    
    if (AVPLAYTOOL.isPlaying && AVPLAYTOOL.index == self.index) {
        [ANIMATION startAnimateWithLayer:self.musicImageView.layer]; //动画开始
    }else{
        AVPLAYTOOL.playArr = self.singArr;
        AVPLAYTOOL.index = self.index;
        [AVPLAYTOOL playerInit];
    }
    AVPLAYTOOL.returnTitle = ^(NSDictionary *dic) {
        self.musicNameLabel.text = [NSString stringWithFormat:@"%@",dic[@"title"]];
        self.subNameLabel.text = [NSString stringWithFormat:@"%@",dic[@"nickName"]];
    };
    AVPLAYTOOL.returnTotal = ^(NSString *totalTime) {
        self.endTimeLabel.text = totalTime;
    };
    AVPLAYTOOL.returnCurrent = ^(NSString *currentTime) {
        self.beginTimeLabel.text = currentTime;
    };
    AVPLAYTOOL.returnProgress = ^(CGFloat progress) {
        self.progressSlider.value = progress;
    };
    AVPLAYTOOL.returnBank = ^(BOOL isBank) {
        //是否进入后台
        if (isBank) {
            if (AVPLAYTOOL.isPlaying) {
                [ANIMATION pauseLayer:self.musicImageView.layer];
            }
            NSLog(@"嘿嘿😜");
        }else{
            if (AVPLAYTOOL.isPlaying) {
                [ANIMATION resumeLayer:self.musicImageView.layer];
            }
            NSLog(@"哈哈😜");
        }
    };
    AVPLAYTOOL.didPlay = ^(BOOL isPlaying) {
        if (isPlaying) {
            [ANIMATION startAnimateWithLayer:self.musicImageView.layer]; //动画开始
        }else{
            [ANIMATION stopLayer:self.musicImageView.layer];
        }
    };

    self.musicNameLabel.text = [NSString stringWithFormat:@"%@",_singArr[_index][@"title"]];
    self.subNameLabel.text = [NSString stringWithFormat:@"%@",_singArr[_index][@"nickname"]];
    
}

#pragma mark - 进度条状态改变
- (void)sliderTouchDown:(UISlider *)slider{
    _isSliderTouch = YES;
}

- (void)sliderValueChange:(UISlider *)slider{
    
    float total = CMTimeGetSeconds(AVPLAYTOOL.player.currentItem.duration);
    [AVPLAYTOOL.player seekToTime:CMTimeMakeWithSeconds(slider.value * total, AVPLAYTOOL.player.currentItem.currentTime.timescale)];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2* NSEC_PER_SEC)); dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        //不延迟执行会造成slider瞬间回弹
        _isSliderTouch = NO;
    });
    
}

#pragma mark - Action
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [AVPLAYTOOL pause];
        [ANIMATION pauseLayer:self.musicImageView.layer];
    }else{
        [AVPLAYTOOL play];
        [ANIMATION resumeLayer:self.musicImageView.layer];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPlaying"]) {
        NSLog(@"change = %@",change);
        if ([change[@"new"] intValue] == 0) {
            self.playButton.selected = YES;
        }else{
            self.playButton.selected = NO;
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
