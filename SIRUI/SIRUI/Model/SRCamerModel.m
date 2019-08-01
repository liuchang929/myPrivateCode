//
//  SRCamerModel.m
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/21.
//

#import "SRCamerModel.h"

@interface SRCamerModel()
{
    AVCaptureDeviceFormat *aFM;
    CMTime                minDuration;
    CMTime                maxDuration;
}

@end

@implementation SRCamerModel

+(SRCamerModel *)defaultModel
{
    SRCamerModel *model = [SRCamerModel new];
    
//    model.captureMode        = PhotoMode;
//    model.photoMode          = SingleMode;
//    model.videoMode          = VideoNormal;
//    model.photoDetailMode    = DetailSingleMode;
//    model.cameraPosition     = AVCaptureDevicePositionBack;
//    model.videoResolution    = SRVideo1080P;
//    model.photoPreset        = AVCaptureSessionPresetPhoto;
//    model.captureOrientation = UIInterfaceOrientationLandscapeRight;
//    model.videoOrientation   = AVCaptureVideoOrientationPortrait;
//    model.flashMode          = AVCaptureFlashModeOff;
    return model;
}
//-(void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
//{
//    _videoOrientation = videoOrientation;
//}

//+(CGSize)movieWritingSize:(videoResulution)resolution
//{
//    switch (resolution) {
//        case SRVideo1080P:
//            return CGSizeMake(1080, 1920);
//
//            break;
//        case SRVideo720P:
//            return CGSizeMake(720, 1280);
//
//            break;
//        case SRVideo4k:
//            return CGSizeMake(2160, 3840);
//
//            break;
//
//        case SRVideo480P:
//            return CGSizeMake(480, 680);
//            break;
//        default:
//            break;
//    }
//
//    return CGSizeMake(720, 1280);
//}

//-(void)setCaptureOrientation:(UIInterfaceOrientation)captureOrientation
//{
////    if(_cameraVC.stillCamera == nil)
////        return;
////
//    _captureOrientation = captureOrientation;
//    _cameraVC.stillCamera.outputImageOrientation = captureOrientation;
//}

//-(void)setCaptureMode:(SRCaptureMode)captureMode
//{
//    if(_cameraVC.stillCamera == nil)
//        return;
//
//    _captureMode = captureMode;
//
//    switch (captureMode) {
//        case PhotoMode:
//        {
//            self.photoPreset = _photoPreset;
//        }
//            break;
//
//        case VideoMode:
//        {
//            self.videoResolution = _videoResolution;
//        }
//            break;
//        default:
//            break;
//    }
//
//}

//-(void)setPhotoPreset:(NSString *)photoPreset
//{
//    if(_photoPreset == nil)
//        _photoPreset = photoPreset;
//
//    if(_cameraVC.stillCamera == nil)
//        return;
//
//    if([self setCameraPreset:photoPreset]){
//        _photoPreset = photoPreset;
//        [_cameraVC configRatioByNotify];
//    }
//}

//-(void)setVideoResolution:(videoResulution)videoResolution
//{
//    if(_cameraVC.stillCamera == nil){
//        return;
//    }
//
//    NSLog(@"videoResulution : %d", videoResolution);
//
//    _videoResolution = videoResolution;
//
//}


//-(void)setVideoMode:(videoMode)videoMode
//{
//    _videoMode = videoMode;
//
//    switch (videoMode) {
//        case VideoNormal:
//            [self normalRate];
//            break;
//        case SlowMotion:
//            self.photoPreset = AVCaptureSessionPresetInputPriority;
//            [self highestRate];
//            break;
//        case Timelapse:
//            [self normalRate];
//            break;
//        default:
//            break;
//    }
//
//}

//-(void)setFlashMode:(AVCaptureFlashMode)flashMode
//{
//    NSError *err;
//
//    [self.cameraVC.stillCamera.captureSession beginConfiguration];
//    [self.cameraVC.stillCamera.inputCamera lockForConfiguration:&err];
//
//    if(!err){
//
//        if([self.cameraVC.stillCamera.inputCamera isFlashModeSupported:flashMode]){
//            [self.cameraVC.stillCamera.inputCamera setFlashMode:flashMode];
//            _flashMode = flashMode;
//
//        }
//
//        [self.cameraVC.stillCamera.inputCamera unlockForConfiguration];
//
//    }
//
//    [self.cameraVC.stillCamera.captureSession commitConfiguration];
//
//}

//-(BOOL)setCameraPreset:(NSString *)preset
//{
//    NSError *err;
//
//    [_cameraVC.stillCamera.inputCamera lockForConfiguration:&err];
//
//    if(!err){
//        BOOL ret = NO;
//
//        if([_cameraVC.stillCamera.captureSession canSetSessionPreset:preset]){
//            [_cameraVC.stillCamera.captureSession setSessionPreset:preset];
//            ret = YES;
//        }
//
//        [_cameraVC.stillCamera.inputCamera unlockForConfiguration];
//
//        return ret;
//    }
//
//    return NO;
//}


-(void)intresPointOfFocusAndExplosure:(CGPoint)interesPoint
{
    NSError *error;
    [_cameraVC.stillCamera.inputCamera lockForConfiguration:&error];
    if(!error){
        if(_cameraVC.stillCamera.inputCamera.isFocusPointOfInterestSupported){
            _cameraVC.stillCamera.inputCamera.focusPointOfInterest = interesPoint;
            _cameraVC.stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
            
        }
        
        if(_cameraVC.stillCamera.inputCamera.isExposurePointOfInterestSupported){
            _cameraVC.stillCamera.inputCamera.exposurePointOfInterest = interesPoint;
            _cameraVC.stillCamera.inputCamera.exposureMode = AVCaptureExposureModeAutoExpose;
            
        }
        
        [_cameraVC.stillCamera.inputCamera unlockForConfiguration];
    }
    
}

//-(void)setCameraVC:(SRBaseCamViewController *)cameraVC
//{
//    _cameraVC = cameraVC;
//    aFM         = _cameraVC.stillCamera.inputCamera.activeFormat;
//    minDuration = _cameraVC.stillCamera.inputCamera.activeVideoMinFrameDuration;
//    maxDuration = _cameraVC.stillCamera.inputCamera.activeVideoMaxFrameDuration;
//}


#pragma mark - funtional

//-(void)normalRate
//{
//    AVCaptureDevice *device = _cameraVC.stillCamera.inputCamera;
//
//    if ( [device lockForConfiguration:NULL] == YES ) {
//
//
//        device.activeVideoMinFrameDuration = minDuration;
//        device.activeVideoMaxFrameDuration = maxDuration;
////        device.activeFormat = aFM;
//
//        [device unlockForConfiguration];
//    }
//
//}

//-(void)highestRate
//{
//
//    AVCaptureDevice *device = _cameraVC.stillCamera.inputCamera;
//
//    AVCaptureDeviceFormat *bestFormat = nil;
//    AVFrameRateRange *bestFrameRateRange = nil;
//    for(AVCaptureDeviceFormat *format in [device formats] ) {
//        for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
//            if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ) {
//                bestFormat = format;
//                bestFrameRateRange = range;
//            }
//        }
//    }
//
//    if ( bestFormat ) {
//        if ( [device lockForConfiguration:NULL] == YES ) {
//            device.activeFormat = bestFormat;
//            device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
//            device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
//            [device unlockForConfiguration];
//        }
//    }
//
//}

@end
