//
//  SRVideoRecordTool.h
//  SiRuiIOT
//
//  Created by SIRUI on 2018/1/9.
//

//AVCaptureVideoDataOutput + AVCaptureMovieFileOutput use is not supported, see:
//https://stackoverflow.com/questions/3968879/simultaneous-avcapturevideodataoutput-and-avcapturemoviefileoutput

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol SRVideoRecordToolDelegate

@end

@interface SRVideoRecordTool : NSObject<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;//设备输入
@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic) CMTime defaultMinFrameDuration;
@property (nonatomic) CMTime defaultMaxFrameDuration;
@property (nonatomic, strong) NSString *moviePath;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) id<SRVideoRecordToolDelegate> delegate;
@property (nonatomic, assign) CGSize videoResolution;
@property (nonatomic, strong) NSString *videoName;

-(void)setupMovieWriter:(AVCaptureSession *)session;
-(void)startRecord;
-(void)stopRecording;

@end
