//
//  JECameraMiddleToolBar.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JECameraMiddleToolBarDelegate <NSObject>

- (void)cleanTrackState;
- (void)takeTrackMode:(UIButton *)sender;

@end

@interface JECameraMiddleToolBar : UIView

@property (nonatomic, weak) id<JECameraMiddleToolBarDelegate> delegate;

@property (nonatomic, strong) UIButton *trackStay;      //不跟踪按钮
@property (nonatomic, strong) UIView   *trackView;      //跟踪 view
@property (nonatomic, strong) UIButton *bluetoothSign;  //蓝牙状态标志
@property (nonatomic, strong) UIButton *faceTrackBtn;   //人脸跟踪
@property (nonatomic, strong) UIButton *objectTrackBtn; //对象跟踪

- (void)takeTrack;
- (void)trackBtnAction:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
