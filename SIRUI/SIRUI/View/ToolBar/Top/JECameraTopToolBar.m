//
//  JECameraTopToolBar.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/2.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraTopToolBar.h"

//图标尺寸
#define ICON_SIDE 60
//工具栏高度
#define BAR_HEIGHT  75

@interface JECameraTopToolBar ()

//icon
@property (nonatomic, strong) UIButton *homeToolButton;         //回到首页
@end

@implementation JECameraTopToolBar

- (instancetype)initWithFrame:(CGRect)frame CameraMode:(CameraConnectMode)cameraMode {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIFrame:frame CameraMode:cameraMode];
    }
    return self;
}

#pragma mark - UI
- (void)setupUIFrame:(CGRect)frame CameraMode:(CameraConnectMode)mode {
    //图标图片名字

    NSArray *iconImageNameArray = @[@"icon_home", @"icon_filter", @"icon_beauty", @"icon_cameraSetting", @"icon_deviceSetting"];
    NSArray *iconImageSelectArray = @[@"icon_home", @"icon_filter_select", @"icon_beauty_select",@"icon_cameraSetting_select", @"icon_deviceSetting_select"];
    
    CGFloat topSpace  = 10.0;               //图标距离顶上的距离
    CGFloat barWidth  = frame.size.width;   //工具栏宽
    CGFloat barHeight = BAR_HEIGHT;         //工具栏高
    CGFloat iconSpace = (barWidth - ICON_SIDE * iconImageNameArray.count)/(iconImageNameArray.count + 1);       //图标之间的间距
    
    if (ITS_X_SERIES) {
        topSpace = 30.0;
    }
    
    //TopToolBar 背景
    self.toolBar = [[SRGradientbackground alloc] initWithFrame:CGRectMake(0, 0, barWidth, barHeight) andTop:YES];
    
    //返回首页按钮
    self.homeToolButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace, topSpace, ICON_SIDE, ICON_SIDE)];
    _homeToolButton.tag = 123;
    [_homeToolButton addTarget:self action:@selector(topToolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_homeToolButton setImage:[UIImage imageNamed:iconImageNameArray[0]] forState:UIControlStateNormal];
    _homeToolButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_homeToolButton];
    
    //相机设置按钮
    self.cameraSetToolButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 4 + ICON_SIDE * 3, topSpace, ICON_SIDE, ICON_SIDE)];
    _cameraSetToolButton.tag = 126;
    [_cameraSetToolButton addTarget:self action:@selector(topToolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSetToolButton setImage:[UIImage imageNamed:iconImageNameArray[3]]   forState:UIControlStateNormal];
    [_cameraSetToolButton setImage:[UIImage imageNamed:iconImageSelectArray[3]] forState:UIControlStateSelected];
    _cameraSetToolButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_cameraSetToolButton];
    
    //稳定器设置按钮
    self.deviceSetToolButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 5 + ICON_SIDE * 4, topSpace, ICON_SIDE, ICON_SIDE)];
    _deviceSetToolButton.tag = 127;
    [_deviceSetToolButton addTarget:self action:@selector(topToolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_deviceSetToolButton setImage:[UIImage imageNamed:iconImageNameArray[4]]   forState:UIControlStateNormal];
    [_deviceSetToolButton setImage:[UIImage imageNamed:iconImageSelectArray[4]] forState:UIControlStateSelected];
    _deviceSetToolButton.imageView.contentMode = UIViewContentModeScaleToFill;
    [_toolBar addSubview:_deviceSetToolButton];
    
    if (mode == connectXP3) {
        //滤镜按钮
        self.filterToolButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 2 + ICON_SIDE, topSpace, ICON_SIDE, ICON_SIDE)];
        _filterToolButton.tag = 124;
        [_filterToolButton addTarget:self action:@selector(topToolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_filterToolButton setImage:[UIImage imageNamed:iconImageNameArray[1]]   forState:UIControlStateNormal];
        [_filterToolButton setImage:[UIImage imageNamed:iconImageSelectArray[1]] forState:UIControlStateSelected];
        _filterToolButton.imageView.contentMode = UIViewContentModeScaleToFill;
        [_toolBar addSubview:_filterToolButton];
        
        //美颜按钮
        self.beautyToolButton = [[UIButton alloc] initWithFrame:CGRectMake(iconSpace * 3 + ICON_SIDE * 2, topSpace, ICON_SIDE, ICON_SIDE)];
        _beautyToolButton.tag = 125;
        [_beautyToolButton addTarget:self action:@selector(topToolButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_beautyToolButton setImage:[UIImage imageNamed:iconImageNameArray[2]]   forState:UIControlStateNormal];
        [_beautyToolButton setImage:[UIImage imageNamed:iconImageSelectArray[2]] forState:UIControlStateSelected];
        _beautyToolButton.imageView.contentMode = UIViewContentModeScaleToFill;
        [_toolBar addSubview:_beautyToolButton];
    }
    
    [self addSubview:_toolBar];
}

#pragma mark - Action
- (void)topToolButtonAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolBarButton:)]) {
        [self.delegate topToolBarButton:button];
    }
}

@end
