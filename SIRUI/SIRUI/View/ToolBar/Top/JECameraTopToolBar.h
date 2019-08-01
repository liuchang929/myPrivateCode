//
//  JECameraTopToolBar.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/2.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRGradientbackground.h"

NS_ASSUME_NONNULL_BEGIN

//连接设备模式
typedef enum cameraConnectMode {
    connectNothing = 0,
    connectXP3,
    connectCamera,
}CameraConnectMode;

@protocol JECameraTopToolBarDelegate <NSObject>

- (void)topToolBarButton:(UIButton *)button;

@end

@interface JECameraTopToolBar : UIView

@property (nonatomic, weak) id<JECameraTopToolBarDelegate> delegate;

@property (nonatomic, assign) CameraConnectMode cameraMode;
@property (nonatomic, strong) SRGradientbackground *toolBar;

@property (nonatomic, strong) UIButton *filterToolButton;       //滤镜
@property (nonatomic, strong) UIButton *beautyToolButton;       //美颜
@property (nonatomic, strong) UIButton *deviceSetToolButton;    //稳定器设置
@property (nonatomic, strong) UIButton *cameraSetToolButton;    //相机设置

- (instancetype)initWithFrame:(CGRect)frame CameraMode:(CameraConnectMode)cameraMode;   //初始化

@end

NS_ASSUME_NONNULL_END
