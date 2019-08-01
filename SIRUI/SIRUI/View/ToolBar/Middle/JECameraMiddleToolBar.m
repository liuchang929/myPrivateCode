//
//  JECameraMiddleToolBar.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraMiddleToolBar.h"

#define ICON_SIDE 40

@interface JECameraMiddleToolBar ()

@end

@implementation JECameraMiddleToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    //不跟踪
    self.trackStay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ICON_SIDE, ICON_SIDE)];
        [_trackStay setImage:[UIImage imageNamed:@"icon_track_stay"] forState:UIControlStateNormal];
        [_trackStay addTarget:self action:@selector(takeTrack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_trackStay];
    
    //跟踪选项 view
    self.trackView = [[UIView alloc] initWithFrame:CGRectMake(ICON_SIDE, 0, 2 * ICON_SIDE, ICON_SIDE)];
        _trackView.hidden = YES;
        _trackView.backgroundColor = [UIColor clearColor];
    
    //人脸跟踪按钮
    self.faceTrackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ICON_SIDE, ICON_SIDE)];
        [_faceTrackBtn setImage:[UIImage imageNamed:@"icon_track_face_off"] forState:UIControlStateNormal];
        _faceTrackBtn.tag = 283;
        [_faceTrackBtn addTarget:self action:@selector(trackBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_trackView addSubview:_faceTrackBtn];
    
    //物体跟踪按钮
    self.objectTrackBtn = [[UIButton alloc] initWithFrame:CGRectMake(ICON_SIDE, 0, ICON_SIDE, ICON_SIDE)];
        [_objectTrackBtn setImage:[UIImage imageNamed:@"icon_track_thing_off"] forState:UIControlStateNormal];
        _objectTrackBtn.tag = 284;
        [_objectTrackBtn addTarget:self action:@selector(trackBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_trackView addSubview:_objectTrackBtn];
    
    [self addSubview:_trackView];
    
    //蓝牙标志按钮
    self.bluetoothSign = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - ICON_SIDE, 0, ICON_SIDE, ICON_SIDE)];
        [_bluetoothSign setImage:[UIImage imageNamed:@"icon_blue_sign"] forState:UIControlStateNormal];
        [_bluetoothSign setImage:[UIImage imageNamed:@"icon_blue_sign_select"] forState:UIControlStateSelected];
        _bluetoothSign.alpha = 0.9;
        _bluetoothSign.tag = 285;
//        [_bluetoothSign addTarget:self action:@selector(bluetoothSignAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bluetoothSign];
}

- (void)takeTrack {
    if (_trackStay.isSelected) {
        _trackStay.selected = NO;
        [self.delegate cleanTrackState];
    }
    else {
        _trackView.hidden = !_trackView.isHidden;
    }
}

- (void)trackBtnAction:(UIButton *)sender {
    [self.delegate takeTrackMode:sender];
}

//- (void)bluetoothSignAction {
//    if (_bluetoothSign.isSelected) {
//        SHOW_HUD_DELAY(NSLocalizedString(@"Bluetooth connected", nil), [UIApplication sharedApplication].keyWindow, 0.5);
//    }
//    else {
//        SHOW_HUD_DELAY(NSLocalizedString(@"There is no bluetooth nearby", nil), [UIApplication sharedApplication].keyWindow, 0.5);
//    }
//}

@end
