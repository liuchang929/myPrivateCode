//
//  BaseViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/3/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    [self contentView];
    [self topView];
    [self bottomView];
    [self windowView];
}

#pragma mark - LazyLoad
- (UIView *)windowView {
    if (!_windowView) {
        self.windowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [self.view addSubview:self.windowView];
    }
    return _windowView;
}

- (UIView *)topView {
    if (!_topView) {
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, SAFE_AREA_TOP_HEIGHT)];
        self.topView.backgroundColor = MAIN_BACKGROUND_COLOR;
        [self.view addSubview:self.topView];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, (HEIGHT - SAFE_AREA_TOP_HEIGHT), WIDTH, SAFE_AREA_TOP_HEIGHT)];
        self.bottomView.backgroundColor = MAIN_BACKGROUND_COLOR;
        [self.view addSubview:self.bottomView];
    }
    return _bottomView;
}

- (UIView *)contentView {
    if (!_contentView) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SAFE_AREA_TOP_HEIGHT, WIDTH, (HEIGHT - 2 * SAFE_AREA_TOP_HEIGHT))];
        self.contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
        [self.view addSubview:self.contentView];
    }
    return _contentView;
}

#pragma mark - Tools
//强制竖屏
- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
