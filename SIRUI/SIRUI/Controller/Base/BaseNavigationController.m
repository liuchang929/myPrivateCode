//
//  BaseNavigationController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/3/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:MAIN_TEXT_COLOR,NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:16],NSFontAttributeName, nil]]; //Nav文字属性
    [[UINavigationBar appearance] setBarTintColor:MAIN_TABBAR_COLOR];//NavigationBar背景颜色
}

- (BOOL)shouldAutorotate
{
    return NO;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//返回优先方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
