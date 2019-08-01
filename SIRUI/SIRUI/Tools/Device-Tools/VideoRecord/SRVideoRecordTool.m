//
//  SRVideoRecordTool.m
//  SiRuiIOT
//
//  Created by SIRUI on 2018/1/9.
//

#import "SRVideoRecordTool.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject

@implementation SRVideoRecordTool

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

- (AVCaptureDeviceInput *)captureDeviceInput{
    
    if (!_captureDeviceInput) {
        
        AVCaptureDevice *captureDevice =[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
        
        _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:nil];
        
        // 保存默认的AVCaptureDeviceFormat
        _defaultFormat = captureDevice.activeFormat;
        _defaultMinFrameDuration = captureDevice.activeVideoMinFrameDuration;
        _defaultMaxFrameDuration = captureDevice.activeVideoMaxFrameDuration;
        
    }
    return _captureDeviceInput;
}

-(void)setupMovieWriter:(AVCaptureSession *)session
{
    self.session = session;
    
    [self.session stopRunning];
    CGFloat desiredFPS = 240.0;
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format: %@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    [self.session startRunning];
    
}

-(void)dealloc
{
    NSLog(@"dealloc");
}

-(void)startRecord
{
    self.movieFileOutput  = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:self.movieFileOutput];
    AVCaptureConnection *videoConnection = nil;
    for ( AVCaptureConnection *connection in [self.movieFileOutput connections]){
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
            }
        }
    }
    if([videoConnection isVideoOrientationSupported])
    {
        [videoConnection setVideoOrientation:(AVCaptureVideoOrientation)[MotionOrientation sharedInstance].deviceOrientation];
        NSLog(@"videoConnection : %@", videoConnection);
    }
    if (![self.movieFileOutput isRecording]) {
        
        unlink([_moviePath UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:_moviePath];
        [self.movieFileOutput startRecordingToOutputFileURL:movieURL recordingDelegate:self];   //收集视频帧
    }
}

-(void)stopRecording
{
    [self.movieFileOutput stopRecording];
    [self.session beginConfiguration];
    [self.session removeOutput:self.movieFileOutput];
    [self.session commitConfiguration];
    
    self.movieFileOutput = nil;
    
    [self cameraBackgroundDidClickCloseSlow];
}

//慢动作关闭
- (void)cameraBackgroundDidClickCloseSlow {
    
    [self.session stopRunning];
    CGFloat desiredFPS = 60.0;
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    NSLog(@"%@",self.captureDeviceInput.device);
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format: %@", selectedFormat);
            videoDevice.activeFormat = _defaultFormat;
            videoDevice.activeVideoMinFrameDuration = _defaultMinFrameDuration;
            videoDevice.activeVideoMaxFrameDuration = _defaultMaxFrameDuration;
            [videoDevice unlockForConfiguration];
        }
    }
    [self.session startRunning];
}

- (NSString *)movieName {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return [timeSp stringByAppendingString:@".MOV"];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported]){
        [captureConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    
    NSDictionary *settings;
    
    if (captureConnection.videoOrientation == AVCaptureVideoOrientationPortrait) {
        
        settings = [NSDictionary dictionaryWithObjectsAndKeys:
                    AVVideoCodecH264, AVVideoCodecKey,
                    [NSNumber numberWithInteger: 720], AVVideoWidthKey,
                    [NSNumber numberWithInteger: 1280], AVVideoHeightKey,
                    nil];
    }
    else if (captureConnection.videoOrientation == AVCaptureVideoOrientationLandscapeRight||captureConnection.videoOrientation == AVCaptureVideoOrientationLandscapeLeft){
        
        settings = [NSDictionary dictionaryWithObjectsAndKeys:
                    AVVideoCodecH264, AVVideoCodecKey,
                    [NSNumber numberWithInteger: 1280], AVVideoWidthKey,
                    [NSNumber numberWithInteger: 720], AVVideoHeightKey,
                    nil];
    }
    NSLog(@"慢动作开始录制");
    
    [self.movieFileOutput setOutputSettings:nil forConnection:captureConnection];
}

//XP3慢动作录制完成代理方法
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported]){
        [captureConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    NSLog(@"慢动作录制完成");
    
    NSURL *movieURL = [NSURL fileURLWithPath:_moviePath];
    
    if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:movieURL size:_videoResolution] toSandboxWithFileName:_videoName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SHOW_HUD_DELAY(NSLocalizedString(@"Saved", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SHOW_HUD_DELAY(NSLocalizedString(@"Failed", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
        });
    }
    /*
    NSString *videoPreviewString = [JECameraManager shareCAMSingleton].getNowDate;
    NSString *videoPath = [[JECameraManager shareCAMSingleton] getVideoPathWithName:[NSString stringWithFormat:@"%@.mov", videoPreviewString]];
    
    NSURL *movieURL = [NSURL fileURLWithPath:_moviePath];
    NSData *movieData = [NSData dataWithContentsOfURL:movieURL];
    NSLog(@"movieURL = %@", movieURL);
    
    NSURL *newMovieURL = [NSURL fileURLWithPath:videoPath];

    AVAsset *videoAsset = [AVAsset assetWithURL:movieURL];
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,  videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    mainInstruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = assetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videoLayerInstruction setTransform:assetTrack.preferredTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacity:0.0 atTime: videoAsset.duration];
    
    AVMutableVideoComposition *mainCompositionInstrument = [AVMutableVideoComposition videoComposition];
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
    } else {
        naturalSize = assetTrack.naturalSize;
    }
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInstrument.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInstrument.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInstrument.frameDuration = CMTimeMake(1, 30);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition
                                                                      presetName:AVAssetExportPreset1280x720];
    exporter.outputURL = newMovieURL;
    exporter.videoComposition = mainCompositionInstrument;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status==3) {
            NSData *newMovieData = [NSData dataWithContentsOfURL:exporter.outputURL];
            if ([newMovieData writeToFile:videoPath atomically:YES]) {
                if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:newMovieURL size:_videoResolution] toSandboxWithFileName:videoPreviewString]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SHOW_HUD_DELAY(NSLocalizedString(@"Saved", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SHOW_HUD_DELAY(NSLocalizedString(@"Failed", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SHOW_HUD_DELAY(NSLocalizedString(@"Failed", nil), [UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                });
            }
        }
    }];
     */
}

//获取图片第一帧
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size {
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}


@end
