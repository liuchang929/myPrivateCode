//
//  CLVideoAddFilter.m
//  tiaooo
//
//  Created by ClaudeLi on 15/12/25.
//  Copyright © 2015年 dali. All rights reserved.
//

#import "CLVideoAddFilter.h"
#import "GPUImage.h"
#import "CLFiltersClass.h"

@interface CLVideoAddFilter ()
{
    GPUImageOutput<GPUImageInput> *filterCurrent;
    NSTimer *_timerEffect;
}

@property (retain, nonatomic) GPUImageMovie *movieFile;
@property (retain, nonatomic) GPUImageOutput<GPUImageInput> *filter;
@property (retain, nonatomic) GPUImageMovieWriter *movieWriter;

@end

@implementation CLVideoAddFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timerEffect = nil;
    }
    return self;
}

- (void)addVideoFilter:(NSURL *)videoUrl tempVideoPath:(NSString *)tempVideoPath index:(NSInteger)index isDvideo:(BOOL)isDvideo
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
    
    AVAssetTrack *asetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    NSURL *tempVideo = [NSURL fileURLWithPath:tempVideoPath];

    //1. 传入视频文件
//    _movieFile = [[GPUImageMovie alloc] initWithURL:videoUrl];
    _movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    
    //2. 添加滤镜
    [self initializeVideo:videoUrl index:index];
    
    CGSize videoSize = CGSizeMake(asetTrack.naturalSize.width, asetTrack.naturalSize.height);
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithInteger: videoSize.width], AVVideoWidthKey,
                              [NSNumber numberWithInteger: videoSize.height], AVVideoHeightKey,
                              nil];
    
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:tempVideo size:videoSize fileType:AVFileTypeQuickTimeMovie outputSettings:settings];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:tempVideo size:videoSize];
    
    //横屏添加滤镜后，会有视频方向bug，故修改下方向值 竖屏不用修改方向值
    if(videoSize.width < videoSize.height) {
        [_movieWriter setTransform:CGAffineTransformMake(cos(M_PI * 0.5), -sin(M_PI * 0.5), sin(M_PI * 0.5), cos(M_PI * 0.5), 0, videoSize.width)];
    }
    
    if ((NSNull*)_filter != [NSNull null] && _filter != nil)
    {
        [_filter addTarget:_movieWriter];
    }
    else
    {
        [_movieFile addTarget:_movieWriter];
    }
    
    // 4. Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    
//    if (isDvideo == NO) {
//      _movieFile.audioEncodingTarget = _movieWriter;
//    }
    
    //🎉恭喜你找到了这个bug，这个bug情况大概是这样的 : 这里添加了是否有声音来源的判断，然后选择音频的来源是moviewriter还是nil，
    //采集的时候需要先判断是否有声音来源，然后再加判断 否则会出现错误Assertion failure in -[GPUImageMovieWriter createDataFBO]
        if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
            _movieWriter.shouldPassthroughAudio = YES;
            _movieFile.audioEncodingTarget = _movieWriter;
        } else {//no audio
            _movieWriter.shouldPassthroughAudio = NO;
            _movieFile.audioEncodingTarget = nil;
        }
//    }
    
    //将音频和视频同步
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    // 5.
    [_movieWriter startRecording];
    
    [_movieFile startProcessing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Progress monitor for effect
        _timerEffect = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                        target:self
                                                      selector:@selector(filterRetrievingProgress)
                                                      userInfo:nil
                                                       repeats:YES];
    });
    
    __unsafe_unretained typeof(self) weakSelf = self;
    // 7. Filter effect finished
    [weakSelf.movieWriter setCompletionBlock:^{
        
        if ((NSNull*)_filter != [NSNull null] && _filter != nil)
        {
            [_filter removeTarget:weakSelf.movieWriter];
        }
        else
        {
            [_movieFile removeTarget:weakSelf.movieWriter];
        }
        [_movieWriter finishRecordingWithCompletionHandler:^{
            // 完成后处理进度计时器 关闭、清空
            [_timerEffect invalidate];
            _timerEffect = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didFinishVideoDeal:)]) {
                    [self.delegate didFinishVideoDeal:tempVideo];
                }
            });
        }];
        
    }];
}
- (void) initializeVideo:(NSURL*) inputMovieURL index:(NSInteger)index
{
    // 1.
//    _movieFile = [[GPUImageMovie alloc] initWithURL:inputMovieURL];
    _movieFile.runBenchmark = NO;
    _movieFile.playAtActualSpeed = NO;
    
    // 2. Add filter effect
    _filter = nil;
    _filter = [CLFiltersClass addVideoFilter:_movieFile index:index];
}
/* 滤镜处理进度 */
- (void)filterRetrievingProgress
{
    if ([self.delegate respondsToSelector:@selector(filterDealProgress:)]) {
        [self.delegate filterDealProgress:_movieFile.progress];
    }
}
#pragma mark - Actions
- (void)deleteTempFile:(NSString *)tempVideoPath
{
    NSURL *url = [NSURL fileURLWithPath:tempVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

@end
