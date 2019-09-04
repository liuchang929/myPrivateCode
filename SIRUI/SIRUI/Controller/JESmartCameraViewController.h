//
//  JESmartCameraViewController.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/1.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "BaseViewController.h"
#import "GPUImage.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

//控制器模式
typedef enum controllerMode {
    cameraM1,       //手机三轴稳定器
    cameraP1        //单反三轴稳定器
}ControllerMode;

//相机闪光灯模式
typedef enum flashMode {
    flashModeOff = 0,
    flashModeOn,
    flashModeAuto
}FlashMode;

typedef enum shootingMode {
    picSingle,
    picSingleDelay1s,
    picSingleDelay2s,
    picSingleDelay3s,
    picSingleDelay4s,
    picSingleDelay5s,
    picSingleDelay10s,
    picPano90d,
    picPano180d,
    picPano360d,
    picPano3x3,
    picNLSquare,
    picNLRectangle,
    videoNormal,
    videoMovingZoom,
    videoSlowMotion,
    videoLocusTimeLapse,
    videoTimeLapse
}ShootingMode;

@interface JESmartCameraViewController : UIViewController

@property (nonatomic, strong) GPUImageStillCamera *stillCamera;         //相机 manager

@property (nonatomic, assign) FlashMode flashMode;              //相机闪光灯模式
@property (nonatomic, assign) ShootingMode shootingMode;        //相机拍摄模式
@property (nonatomic, assign) ControllerMode controllerMode;    //控制器模式

@property (nonatomic, strong) NSArray   *peripheralName;      //蓝牙扫描设备名


@end

NS_ASSUME_NONNULL_END
