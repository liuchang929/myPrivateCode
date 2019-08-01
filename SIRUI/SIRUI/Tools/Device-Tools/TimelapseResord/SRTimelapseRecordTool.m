//
//  SRTimelapseRecordTool.m
//  SiRuiIOT
//
//  Created by SIRUI on 2017/8/31.
//

#import "SRTimelapseRecordTool.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/Photos.h>
#import "JECameraManager.h"

@interface SRTimelapseRecordTool()
{
    AVAssetWriter  *videoWriter;
    AVAssetWriterInput *writerInput;
    AVAssetWriterInputPixelBufferAdaptor *adaptor;
    NSInteger _durtion;
    BOOL timelapseCapture;
    BOOL shouldBeStop;
    NSString *filePath;
    NSString *filePreviewName;
}

@property (nonatomic, assign) NSInteger pictureCount;

@end

@implementation SRTimelapseRecordTool

- (instancetype)initWithModel:(SRCamerModel *)model size:(CGSize)size
{
    self = [super init];
    if (self) {
        _camModel = model;
        _size     = size;
        
        [self commonInit];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"timelapse dealloc");
}

-(void)commonInit
{
    NSDictionary *videoCompressionProps;
    NSDictionary *videoSettings;
    
//    NSLog(@"camModel.videoResolution : %u", _camModel.videoResolution);
    
//    switch ((videoResulution)[[[NSUserDefaults standardUserDefaults]objectForKey:THREE_AXI_VIDEO_RESOLUTION] intValue]) {
//        case SRVideo4k:
//            videoCompressionProps = @{
//                                      AVVideoAverageBitRateKey:@(50*1024.0*1024),
//                                      AVVideoH264EntropyModeKey:AVVideoH264EntropyModeCABAC,
//                                      AVVideoMaxKeyFrameIntervalKey:@(30),
//                                      AVVideoAllowFrameReorderingKey:@NO,
//                                      AVVideoExpectedSourceFrameRateKey:@30,
//                                      };
//            break;
//        case SRVideo720P:
//            videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithDouble:8*1024.0*1024], AVVideoAverageBitRateKey,
//                                     AVVideoH264EntropyModeCABAC,AVVideoH264EntropyModeKey,
//                                     nil ];
//            break;
//        case SRVideo1080P:
//            videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithDouble:18*1024.0*1024], AVVideoAverageBitRateKey,
//                                     AVVideoH264EntropyModeCABAC,AVVideoH264EntropyModeKey,
//                                     nil];
//            break;
//        default:
//            videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithDouble:8*1024.0*1024], AVVideoAverageBitRateKey,
//                                     AVVideoH264EntropyModeCABAC,AVVideoH264EntropyModeKey,
//                                     nil ];
//            break;
//    }
    
    videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                     AVVideoCodecH264,AVVideoCodecKey,
                     videoCompressionProps, AVVideoCompressionPropertiesKey,
                     AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                     [NSNumber numberWithInteger:_size.width],AVVideoWidthKey,
                     [NSNumber numberWithInteger:_size.height],AVVideoHeightKey,
                     nil];
    
    
    
    writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    writerInput.expectsMediaDataInRealTime = YES;
   
    NSError *err;
    
    NSString *dateString = [JECameraManager shareCAMSingleton].getNowDate;
    
    filePath = [[[[[JECameraManager shareCAMSingleton] getSandBoxPath] objectAtIndex:0] stringByAppendingPathComponent:sVideoSandbox] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", dateString]];
    filePreviewName = dateString;
    
    NSLog(@"filePath = %@", filePath);
    
    
    videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:filePath] fileType:AVFileTypeQuickTimeMovie error:&err];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:_size.width], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:_size.height], kCVPixelBufferHeightKey,
                                                           nil];
    
    //转换方向
    UIDeviceOrientation orientation = [MotionOrientation sharedInstance].deviceOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
            break;
        case UIDeviceOrientationFaceDown:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIDeviceOrientationLandscapeLeft:
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        default:
            break;
    }
    writerInput.transform = transform;
    
    adaptor =  [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
     if([videoWriter canAddInput:writerInput]){
        [videoWriter addInput:writerInput];
        [videoWriter setMetadata:[self generateTimelapseMetadata]];
    }else{
        assert(0);
    }
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
}

- (NSArray *)generateTimelapseMetadata {
    AVMutableMetadataItem* deviceMetaItem = [AVMutableMetadataItem metadataItem];
    deviceMetaItem.key = @"com.apple.quicktime.model";
    deviceMetaItem.value = @"SR Smart Holder";
    deviceMetaItem.keySpace = AVMetadataKeySpaceQuickTimeMetadata;
    
    return @[deviceMetaItem];
}

- (void)takeVideowithDuration:(NSInteger) durationTime andInterval:(double) intervalTime{
    _durtion = durationTime;
//    NSInteger takePhotoTimes = durationTime / intervalTime;
    dispatch_queue_t video_queue = dispatch_queue_create("timelapse_queue", DISPATCH_QUEUE_SERIAL);
    
//    @weakify(self)
    dispatch_async(video_queue, ^{
//        @strongify(self)
        
        while (YES) {
            if(shouldBeStop)
                break;
            
            [self timelapseTakePicture: NO];
            [NSThread sleepForTimeInterval:intervalTime];
        }
        
    });
    
    //    //slow motion
    //    self.cameraModel.videoState = DJIIPhone_VideoRecordState_ING;
    //    dispatch_queue_t slow_mode_queue = dispatch_queue_create("slow_mode", DISPATCH_QUEUE_CONCURRENT);
    //    weakSelf(target);
    //    for (int i = 0; i < durationTime * 20; i++) {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 1 * NSEC_PER_SEC / 20)), slow_mode_queue, ^{
    //            [target timelapseTakePicture:NO];
    //            if (i == durationTime * 20 - 1) {
    //                [target timelapseTakePicture:YES];
    //            }
    //        });
    //    }
}

- (void)timelapseTakePicture:(BOOL) needStop {
    
//    [self.camModel.cameraVC.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *image, NSError *error){
//        @autoreleasepool {
//            [self generateTimelapseWithImage:image];
//            if (needStop) {
//                [self stopMakeTimelapseVideo];
//            }
//        }
//    }];
    
//    @weakify(self)
    @autoreleasepool {
//        @strongify(self)
        
        UIImage *image;
        runSynchronouslyOnVideoProcessingQueue(^{
            [self.filter useNextFrameForImageCapture];
        });
        image = [self.filter imageFromCurrentFramebuffer];
        [self generateTimelapseWithImage:image];
        
        if (needStop) {
            shouldBeStop = YES;
            [self stopMakeTimelapseVideo];
        }
    }
}

- (void)stopMakeTimelapseVideo {
    if (videoWriter.status != AVAssetWriterStatusWriting) {
        return;
    }
    
    [writerInput markAsFinished];
    
//    @weakify(self)
    [videoWriter finishWritingWithCompletionHandler:^{
//        @strongify(self)
        NSLog(@"Finished writing...checking completion status...");
        if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted){
            NSLog(@"Video writing succeeded.");

            [self saveVideo:[NSURL fileURLWithPath:filePath]];
            
        } else{
            NSLog(@"Video writing failed: %@", videoWriter.error);
        }
    }];
}

//延时摄影保存完毕
-(void)saveVideo:(NSURL *)path
{
    [self.delegate timelapseCaptureFinish];

//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
//        switch (status) {
//            case PHAuthorizationStatusAuthorized:
//            {
//                [[PHPhotoLibrary sharedPhotoLibrary]saveVideoWithUrl:path ToAlbum:kDVideoAlbumName completion:^(NSURL *videoUrl) {
//                    if (videoUrl) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//
//                            [self.delegate timelapseSaveFinish:nil];
//                        });
//                    }
//                } failure:^(NSError *error) {
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        [self.delegate timelapseSaveFinish:[NSError errorWithDomain:@"sirui" code:-1 userInfo:@{}]];
//
//                    });
//                }];
//            }
//                break;
//
//            default:
//                break;
//        }
//
//    }];
    
    //保存到沙盒里
    NSData *movieData = [NSData dataWithContentsOfURL:path];
    if ([movieData writeToFile:filePath atomically:YES]) {
        if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:path size:[self getUserSaveVideoResolution]] toSandboxWithFileName:filePreviewName]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SHOW_HUD_DELAY(NSLocalizedString(@"Saved", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            });
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
        });
    }
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

//获取用户当前选择的分辨率尺寸
- (CGSize)getUserSaveVideoResolution {
    NSInteger videoResolutionInteger = USER_GET_SaveVideoResolution_Integer;
    switch (videoResolutionInteger) {
        case 0:
            return CGSizeMake(480, 640);
            break;
            
        case 1:
            return CGSizeMake(720, 1280);
            break;
            
        case 2:
            return CGSizeMake(1080, 1920);
            break;
            
        case 3:
            //            return CGSizeMake(2160, 3840);
            return CGSizeMake(1080, 1920);      //当前发现录像时丢帧，初步断定是分辨率太高的原因？所以暂时不支持 4k 录制
            break;
            
        default:
            return CGSizeMake(0, 0);
            break;
    }
}

- (void)generateTimelapseWithImage:(UIImage *)image {
    CVPixelBufferRef buffer = NULL;
    if (writerInput.readyForMoreMediaData) {
        NSLog(@"enter writeinput");
        CMTime presentTime = CMTimeMake(self.pictureCount++, (int)_durtion);
        buffer = [SRTimelapseRecordTool pixelBufferFromCGImage:[image CGImage] size:_size];
        NSLog(@"present time: %@", [NSValue valueWithCMTime:presentTime]);
        if (![adaptor appendPixelBuffer:buffer withPresentationTime:presentTime]) {
            NSError *err = [videoWriter error];
            NSLog(@"append pixel buffer failed %@", err);
        }
        CVPixelBufferRelease(buffer);
    }
}

-(void)appendWithImage:(UIImage *)image
{
    CVPixelBufferRef buffer = NULL;
    CMTime presentTime = CMTimeMake(_pictureCount,(int)_durtion);
    
}

+(CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef) image
                                      size:(CGSize) videoSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, videoSize.width,
                                          videoSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, videoSize.width,
                                                 videoSize.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
