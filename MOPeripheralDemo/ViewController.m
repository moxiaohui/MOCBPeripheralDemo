//
//  ViewController.m
//  MOPeripheralDemo
//
//  Created by moxiaoyan on 2019/1/22.
//  Copyright © 2019 moxiaoyan. All rights reserved.
//

#import "ViewController.h"
#import "MOPerManager.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  CGFloat width = self.view.frame.size.width / 3;
  UIButton *startAd = [UIButton buttonWithType:UIButtonTypeCustom];
  [startAd setTitle:@"开始广播" forState:UIControlStateNormal];
  [startAd setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  startAd.frame = CGRectMake(0, 0, 100, 50);
  startAd.center = CGPointMake(width, 100);
  [startAd addTarget:self action:@selector(startAd) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:startAd];

  UIButton *stopAd = [UIButton buttonWithType:UIButtonTypeCustom];
  [stopAd setTitle:@"停止广播" forState:UIControlStateNormal];
  [stopAd setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  stopAd.frame = CGRectMake(0, 0, 100, 50);
  stopAd.center = CGPointMake(width*2, 100);
  [stopAd addTarget:self action:@selector(stopAd) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:stopAd];
}

- (void)startAd {
  [[MOPerManager shareInstance] startAdvertising];
}

- (void)stopAd {
  [[MOPerManager shareInstance] stopAdvertising];
}

@end
