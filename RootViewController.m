//
//  RootViewController.m
//  MusicPlayer
//
//  Created by juanMac on 2018/1/29.
//  Copyright © 2018年 JohnLai. All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "FMAFNetWorkingTool.h"
#import "SecondViewController.h"

@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *singTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.dataArray = [NSMutableArray array];
    [self loadData];
    [self createView];
}

- (void)loadData{
    NSString *url = @"http://mobile.ximalaya.com/mobile/v1/album?albumId=3021864&device=iPhone&pageSize=20&source=5&statEvent=pageview%2Falbum%403021864&statModule=听小说_幻想&statPage=categorytag%40听小说_幻想&statPosition=105";
    [FMAFNetWorkingTool getUrl:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] body:nil result:FMJSON headerFile:nil success:^(id result) {
        for (NSDictionary *dic in result[@"data"][@"tracks"][@"list"]) {
            [self.dataArray addObject:dic];
        }
        [self.singTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}
- (void)createView{
    
    self.singTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    [self.view addSubview:self.singTableView];
    self.singTableView.delegate = self;
    self.singTableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuse = @"cellReuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"dataArray = %@",self.dataArray);
    
    //使用FreeStreamer播放
//    FirstViewController *player1 = [[FirstViewController alloc] init];
//    player1.index = indexPath.row;
//    player1.singArr = self.dataArray;
//    [self.navigationController pushViewController:player1 animated:YES];
    
    //使用AVPlayer播放
    SecondViewController *player = [[SecondViewController alloc] init];
    player.index = indexPath.row;
    player.singArr = self.dataArray;
    [self.navigationController pushViewController:player animated:YES];
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
