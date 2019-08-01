//
//  JESmartCameraModel.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/1.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JESmartCameraModel.h"
#import "JESmartCameraViewController.h"

@interface JESmartCameraModel ()

@property (nonatomic, weak) JESmartCameraViewController *cameraVC;

@end

@implementation JESmartCameraModel

+ (JESmartCameraModel *)defaultModel {
    JESmartCameraModel *model = [JESmartCameraModel new];
    
//    model.flashMode = flashModeAuto;
    model.camPosition = AVCaptureDevicePositionBack;
    
    return model;
}

//分辨率
- (void)setPhotoPreset:(NSString *)photoPreset {
    if (photoPreset == nil) {
        _photoPreset = photoPreset;
    }
    if (_cameraVC.stillCamera == nil) {
        return; //没有相机
    }
    if ([self setCameraPreset:photoPreset]) {
        _photoPreset = photoPreset;
        
    }
}

- (BOOL)setCameraPreset:(NSString *)cameraPreset {
    NSError *error;
    
    //锁定相机
    [_cameraVC.stillCamera.inputCamera lockForConfiguration:&error];
    
    if (!error) {
        BOOL ret = NO;
        
        if ([_cameraVC.stillCamera.captureSession canSetSessionPreset:cameraPreset]) {
            [_cameraVC.stillCamera.captureSession setSessionPreset:cameraPreset];
            ret = YES;
        }
        
        [_cameraVC.stillCamera.inputCamera unlockForConfiguration];
        
        return ret;
    }
    
    return NO;
}

- (void)interPointOfFocusAndExplosure:(CGPoint)interPoint {
    NSError *error;
    
    [_cameraVC.stillCamera.inputCamera lockForConfiguration:&error];    //锁定以进行配置
    
    if (!error) {
        //对焦
        if (_cameraVC.stillCamera.inputCamera.isFocusPointOfInterestSupported) {
            _cameraVC.stillCamera.inputCamera.focusPointOfInterest = interPoint;
            _cameraVC.stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
        }
        //曝光
        if (_cameraVC.stillCamera.inputCamera.isExposurePointOfInterestSupported) {
            _cameraVC.stillCamera.inputCamera.exposurePointOfInterest = interPoint;
            _cameraVC.stillCamera.inputCamera.exposureMode = AVCaptureExposureModeAutoExpose;
        }
        
        [_cameraVC.stillCamera.inputCamera unlockForConfiguration]; //解锁
    }
}

@end
