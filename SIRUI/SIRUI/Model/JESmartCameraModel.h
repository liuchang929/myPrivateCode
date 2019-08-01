//
//  JESmartCameraModel.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/1.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

//相机闪光灯模式
//typedef enum flashMode {
//    flashModeOff = 0,
//    flashModeOn,
//    flashModeAuto
//}FlashMode;

@interface JESmartCameraModel : NSObject

//@property (nonatomic, assign) FlashMode flashMode;  //相机闪光灯状态
@property (nonatomic, assign) AVCaptureDevicePosition camPosition;  //相机摄像头前后置

@property (nonatomic, strong) NSString *photoPreset;    //照片分辨率

+ (JESmartCameraModel *)defaultModel;
- (void)interPointOfFocusAndExplosure:(CGPoint)interPoint;      //手动对焦曝光

@end

NS_ASSUME_NONNULL_END
