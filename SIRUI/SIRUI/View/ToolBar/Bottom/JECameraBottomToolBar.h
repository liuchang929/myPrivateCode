//
//  JECameraBottomToolBar.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/2.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRGradientbackground.h"
#import "JECameraBottomMenu.h"

NS_ASSUME_NONNULL_BEGIN

//连接设备模式
typedef enum bottomConnectMode {
    bConnectNothing = 0,
    bConnectXP3,
    bConnectCamera,
}BottomConnectMode;

@protocol JECameraBottomToolBarDelegate <NSObject>

- (void)bottomToolBarButtonAction:(NSInteger)buttonTag;

@end

@interface JECameraBottomToolBar : UIView

@property (nonatomic, assign) BottomConnectMode cameraMode;

@property (nonatomic, weak) id<JECameraBottomToolBarDelegate> delegate;

@property (nonatomic, strong) SRGradientbackground  *toolBar;
@property (nonatomic, strong) JECameraBottomMenu    *bottomMenu;            //底部 toolbar 上的菜单
@property (nonatomic, strong) UIButton      *cameraButton;          //快门键
@property (nonatomic, strong) UIButton      *subBottomButton;       //底部菜单键
@property (nonatomic, strong) UIImageView   *shootSwitchButton;     //拍摄模式切换按钮
@property (nonatomic, strong) UIImageView   *shootSwitchTone;       //圆点
@property (nonatomic, strong) UIImageView   *shootSwitchPhoto;      //拍照模式
@property (nonatomic, strong) UIImageView   *shootSwitchVideo;      //录像模式
@property (nonatomic, strong) UIButton      *lensSwitchButton;      //切换镜头键
@property (nonatomic, strong) UIButton      *albumButton;           //相册键

- (instancetype)initWithFrame:(CGRect)frame CameraMode:(BottomConnectMode)cameraMode;   //初始化

@end

NS_ASSUME_NONNULL_END
