//
//  AppDelegate.m
//  MusicPlayer
//
//  Created by administrator on 2017/9/22.
//  Copyright © 2017年 JohnLai. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "AnimationTool.h"
#import "PlayerToolViewController.h"
#import "AVPlayToolViewController.h"

#define SCR_W [UIScreen mainScreen].bounds.size.width
#define SCR_H [UIScreen mainScreen].bounds.size.height
#define SHARETOOL [PlayerToolViewController sharePlayerTool]
#define AVPLAYTOOL [AVPlayToolViewController sharedPlayerTool]
#define ANIMATION [[AnimationTool alloc] init]
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = navi;
    
    //播放音乐标志
    self.musicImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_music_bg@2x"]];
    self.musicImage.frame = CGRectMake(SCR_W-70, SCR_H-80, 50, 50);
    [self.window addSubview:self.musicImage];
    self.musicImage.userInteractionEnabled = YES;
    self.musicImage.hidden = YES;
    self.musicImage.tag = 101;
    [ANIMATION startAnimateWithLayer:self.musicImage.layer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicImageClickedAction)];
    [self.musicImage addGestureRecognizer:tap];
    
    return YES;
}

- (void)musicImageClickedAction
{
    //FreeStreamer播放
//    FirstViewController *firstVC = [[FirstViewController alloc] init];
//    UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
//    firstVC.singArr = SHARETOOL.playArr;
//    firstVC.index = SHARETOOL.index;
//    [navi pushViewController:firstVC animated:YES];
    
    
    //AVPlayer播放
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    UINavigationController *navi1 = (UINavigationController *)self.window.rootViewController;
    secondVC.singArr = AVPLAYTOOL.playArr;
    secondVC.index = AVPLAYTOOL.index;
    [navi1 pushViewController:secondVC animated:YES];
    
}

#pragma mark 重写父类方法，接受外部事件的处理 为添加到音频中心后台播放做准备
//注释掉的是使用FreeStreamer播放时候用的  未注释的是使用AVPlayer播放使用的
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type ==UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {//得到事件类型
            case UIEventSubtypeRemoteControlTogglePlayPause://暂停 ios6
                //线控播放/暂停
//                [SHARETOOL pause];
                if (AVPLAYTOOL.isPlaying) {
                    [AVPLAYTOOL pause];
                }else{
                    [AVPLAYTOOL play];
                }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                //上一首
//                [SHARETOOL lastOne];
                [AVPLAYTOOL lastOne];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                //下一首
//                [SHARETOOL nextOne];
                [AVPLAYTOOL nextOne];
                break;
            case UIEventSubtypeRemoteControlPlay://播放
                //AirPlay播放
//                [SHARETOOL pause];
                [AVPLAYTOOL play];
                break;
            case UIEventSubtypeRemoteControlPause://暂停 ios7
                //AirPlay暂停
//                [SHARETOOL pause];
                [AVPLAYTOOL pause];
                break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
