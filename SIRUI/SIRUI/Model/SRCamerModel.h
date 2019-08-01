//
//  SRCamerModel.h
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
//#import "SRBaseCamViewController.h"
#import "JESmartCameraViewController.h"

//typedef enum SRCaptureMode{
//    PhotoMode,     //拍照
//    VideoMode      //摄影
//}SRCaptureMode;
//
//typedef enum SRPhotoMode{
//    SingleMode,     //单拍
//    ContinuousMode,  //连拍
//    PanoMode,        //全景
//    InvertvalMode,   //延时
//    LongExplosure    //长曝光
//}SRPhotoMode;
//
//typedef enum SRPhotoDetailMode{
//    DetailSingleMode,
//    DetailSingleDelay2,
//    DetailSingleDelay5,
//    DetailSingleDelay10,
//    DetailSingleHDR
//}SRPhotoDetailMode;
//
//typedef enum SRPanoMode{
//    Pano180,
//    Pano360,
//    Pano720,
//    Pano3x3,
//}SRPanoMode;
//
//typedef enum videoMode{
//    VideoNormal,
//    SlowMotion,     //慢动作
//    Timelapse,      //延时
//}videoMode;
//
//
//typedef enum videoResulution{
//    SRVideo480P = 1,
//    SRVideo720P = 2,
//    SRVideo1080P = 3,
//    SRVideo4k = 4,
//}videoResulution;

@interface SRCamerModel : NSObject

//@property(nonatomic, assign) SRCaptureMode             captureMode;
//@property(nonatomic, assign) SRPhotoMode               photoMode;
//@property(nonatomic, assign) videoMode                 videoMode;
//@property(nonatomic, assign) SRPhotoDetailMode         photoDetailMode;
//@property(nonatomic, assign) AVCaptureDevicePosition   cameraPosition;
//@property(nonatomic, assign) videoResulution           videoResolution;
//@property(nonatomic, strong) NSString *                photoPreset;
//@property(nonatomic, assign) UIInterfaceOrientation    captureOrientation;
//@property(nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
//@property(nonatomic, weak)   SRBaseCamViewController   *cameraVC;
@property(nonatomic, weak)  JESmartCameraViewController *cameraVC;
//@property(nonatomic, assign) AVCaptureFlashMode flashMode;

+(SRCamerModel *)defaultModel;
//+(CGSize)movieWritingSize:(videoResulution)resolution;
-(void)intresPointOfFocusAndExplosure:(CGPoint)interesPoint;    //手动对焦和曝光

@end
