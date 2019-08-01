//
//  BaseTabBarController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/3/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "BaseTabBarController.h"

//#define TABBAR_BACKGROUND_COLOR [UIColor colorWithRed:0.09 green:0.1 blue:0.2 alpha:1]      //navigationBar 背景颜色
//#define TABBAR_TINT_COLOR       [UIColor colorWithRed:0.99 green:0.84 blue:0.31 alpha:1]    //navigationTint 字体颜色

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[UITabBar appearance] setFrame:CGRectMake(0, (HEIGHT - SAFE_AREA_TOP_HEIGHT), WIDTH, SAFE_AREA_TOP_HEIGHT)];
    [[UITabBar appearance] setBarTintColor:MAIN_TABBAR_COLOR];
    [[UITabBar appearance] setTintColor:MAIN_TEXT_COLOR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
