//
//  JECustomFunctionView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/19.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECustomFunctionView.h"

//顶部视图的高度
#define HEAD_HEIGHT 50
//cell 高度
#define CELL_HEIGHT 45
//cell font
#define CELL_FONT 14

@interface JECustomFunctionView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView                *headView;          //顶部 view
@property (nonatomic, strong) UIView                *backView;          //背景 view
@property (nonatomic, strong) UIVisualEffectView    *effeView;          //模糊 view
@property (nonatomic, strong) UILabel               *headLabel;         //顶部 label
@property (nonatomic, strong) UIPickerView          *functionPicker;    //自定义功能 picker
@property (nonatomic, strong) UIButton              *exitBtn;           //消除 view

@property (nonatomic, strong) NSArray   *functionArray;     //功能列表
@property (nonatomic, strong) NSArray   *functionIconArray; //功能列表图标

@property (nonatomic, assign) int       pickerTimes;        //滚轮的速率优化

@end

@implementation JECustomFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    //背景视图
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _backView.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _effeView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _effeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [_backView addSubview:_effeView];
    [self addSubview:_backView];
    
    //顶部视图
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEAD_HEIGHT)];
    _headView.backgroundColor = [UIColor blackColor];
    _headView.alpha = 0.5;
    _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _headView.frame.size.width, _headView.frame.size.height)];
    _headLabel.text = JELocalizedString(@"Press the Fn button twice to start", nil);
    _headLabel.textColor = [UIColor whiteColor];
    _headLabel.textAlignment = NSTextAlignmentCenter;
    _headLabel.backgroundColor = [UIColor clearColor];
    [_headView addSubview:_headLabel];
    _exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(_headView.frame.size.width - HEAD_HEIGHT, 0, HEAD_HEIGHT, HEAD_HEIGHT)];
    
    [_exitBtn setImage:[UIImage imageNamed:@"icon_closeView"] forState:UIControlStateNormal];
    _exitBtn.backgroundColor = [UIColor clearColor];
    [_exitBtn addTarget:self action:@selector(exitView) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_exitBtn];
    [self addSubview:_headView];
    
    //功能 picker
    self.functionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, HEAD_HEIGHT, self.frame.size.width, self.frame.size.height - HEAD_HEIGHT)];
    _functionPicker.delegate   = self;
    _functionPicker.dataSource = self;
    if (USER_GET_SaveFunctionMode_Integer > 17 || USER_GET_SaveFunctionMode_Integer < 0 ) {
        USER_SET_SaveFunctionMode_Integer(0);
    }
    [_functionPicker selectRow:USER_GET_SaveFunctionMode_Integer inComponent:0 animated:NO];
    _functionPicker.backgroundColor = [UIColor clearColor];
    [self addSubview:_functionPicker];
}

- (void)loadData {
    self.functionArray = @[@"Front/Rear Camera Switch",                      //前后置摄像头切换
                           @"Video/Image Switch",                        //视频或拍照模式切换
                           @"Flash On/Off",                                         //闪光灯开关
                           @"Beauty Mode On/Off",                               //美颜功能开关
                           @"Filters Mode On",                                //启动滤镜功能
                           @"Face Track On/Off",                         //启动或关闭人脸追踪
                           @"Shooting Objects Track On/Off",                    //启动或关闭对象追踪
                           @"90°Pano Shot",                   //启动 90 度全景拍摄
                           @"180°Pano Shot",                  //启动 180 度全景拍摄
                           @"360°Pano Shot",                  //启动 360 度全景拍摄
                           @"Activate Sudoku Mode 1",           //启动九宫格拍摄 - 模式 1
                           @"Activate Sudoku Mode 2",           //启动九宫格拍摄 - 模式 2
                           @"Motion Zoom On",                           //启动移动变焦拍摄
//                           @"Slow Motion Shot",                           //启动慢动作拍摄
                           @"Time Lapse Shot",                                 //启动延时拍摄
                           @"Path Lapse Shot",                           //启动轨迹延时拍摄
                           @"3x3 Ultra Wide Angle Pano Shot"];        //启动 3x3 超广角全景拍摄
    
    self.functionIconArray = @[@"icon_lansSwitch",
                               @"icon_cameraModeChange",
                               @"icon_cameraSetting_flash_auto",
                               @"icon_beauty",
                               @"icon_filter",
                               @"icon_track_face_off",
                               @"icon_track_thing_off",
                               @"icon_sub_pano_90d",
                               @"icon_sub_pano_180d",
                               @"icon_sub_pano_360d",
                               @"icon_sub_NL_square",
                               @"icon_sub_NL_rectangle",
                               @"icon_sub_video_movingZoom",
//                               @"icon_sub_video_slowMotion",
                               @"icon_sub_video_timeLapse",
                               @"icon_sub_video_locusTimeLapse",
                               @"icon_sub_pano_3x3"];
}

#pragma mark - Action
- (void)exitView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(exitCustomFunctionView)]) {
        [self.delegate exitCustomFunctionView];
    }
}

- (void)changePickerViewValue:(BOOL)isUp {
//    //限制响应频率
//    if (_pickerTimes > 1) {
//        _pickerTimes = 0;
//    }
//    else {
//        _pickerTimes = _pickerTimes + 1;
//    }
//    
    if (_pickerTimes == 0) {
        //防止越界
        if (isUp) {
            //增加
            if (USER_GET_SaveFunctionMode_Integer >= 0 && USER_GET_SaveFunctionMode_Integer < 15) {
                USER_SET_SaveFunctionMode_Integer(USER_GET_SaveFunctionMode_Integer + 1);
                [_functionPicker reloadAllComponents];
                [_functionPicker selectRow:USER_GET_SaveFunctionMode_Integer inComponent:0 animated:YES];
            }
            
        }
        else {
            //减少
            if (USER_GET_SaveFunctionMode_Integer > 0 && USER_GET_SaveFunctionMode_Integer <= 15) {
                USER_SET_SaveFunctionMode_Integer(USER_GET_SaveFunctionMode_Integer - 1);
                [_functionPicker reloadAllComponents];
                [_functionPicker selectRow:USER_GET_SaveFunctionMode_Integer inComponent:0 animated:YES];
            }
        }
    }
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _functionArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return CELL_HEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *cellView = view;
    UIButton *cellIcon;
    UILabel *cellLabel;
    
    if (cellView == nil) {
        cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CELL_HEIGHT)];
    }
    
    if (cellIcon == nil) {
        cellIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, CELL_HEIGHT)];
        [cellIcon setImage:[UIImage imageNamed:_functionIconArray[row]] forState:UIControlStateNormal];
        [cellView addSubview:cellIcon];
    }
    
    if (cellLabel == nil) {
        cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CELL_HEIGHT)];
        cellLabel.center = CGPointMake(cellView.center.x + 20, cellView.center.y);
        cellLabel.text = JELocalizedString(_functionArray[row], nil);
        cellLabel.font = [UIFont systemFontOfSize:CELL_FONT];
        [cellLabel setTextAlignment:NSTextAlignmentCenter];
        [cellLabel setBackgroundColor:[UIColor clearColor]];
        [cellView addSubview:cellLabel];
    }
    
    if (row == USER_GET_SaveFunctionMode_Integer) {
        cellLabel.textColor = MAIN_BLUE_COLOR;
    }
    else {
        cellLabel.textColor = [UIColor lightGrayColor];
    }
    
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    USER_SET_SaveFunctionMode_Integer(row);
    [pickerView reloadComponent:component];
}

@end
