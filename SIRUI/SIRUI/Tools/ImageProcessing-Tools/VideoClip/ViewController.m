//
//  ViewController.m
//  ICGVideoTrimmer
//
//  Created by HuongDo on 1/15/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ViewController.h"
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "CLFilterViewController.h"
@interface ViewController () <UINavigationControllerDelegate,ICGVideoTrimmerDelegate>
@property (nonatomic,strong)  UIButton *playBtn;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (strong, nonatomic) NSString *tempVideoPath;

@property (weak, nonatomic)   IBOutlet UIButton *trimButton;
@property (weak, nonatomic)   IBOutlet UIView *videoPlayer;
@property (weak, nonatomic)   IBOutlet UIView *videoLayer;

@property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;

@end

@implementation ViewController

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self addBackButton];
    
    [self addNextButton];
    
    self.videoLayer.backgroundColor = [UIColor blackColor];
    
    self.navView.backgroundColor = [UIColor blackColor];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self addNavViewTitle:JELocalizedString(@"Video Clip",nil)];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.backBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextBtn setTitle:JELocalizedString(@"Next",nil) forState:UIControlStateNormal];
    
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.nextBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    NSDate *date = [NSDate date];
    
    NSString *string = [NSString stringWithFormat:@"%ld.mov",(unsigned long)(date.timeIntervalSince1970 * 1000)];
    
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:string];
    
    self.asset = [AVAsset assetWithURL:self.videoUrlYFX];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-50-110);
    [self.videoLayer.layer addSublayer:self.playerLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [self.videoLayer addGestureRecognizer:tap];
    self.videoPlaybackPosition = 0;
    [self tapOnVideoLayer:tap];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-150, kScreenWidth + 50, kScreenHeight)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    self.trimmerView = [[ICGVideoTrimmerView alloc]initWithFrame:CGRectMake(0, kScreenHeight-100, kScreenWidth, 100) asset:self.asset];
    CMTime  time = [self.asset duration];
    self.trimmerView.maxLength = time.value/time.timescale + 1;
    // set properties for trimmer view
    [self.trimmerView setThemeColor1:[UIColor lightGrayColor]];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setTrackerColor:[UIColor cyanColor]];
    [self.trimmerView setDelegate:self];
    // important: reset subviews
    [self.trimmerView resetSubviews];
    [self.trimButton setHidden:YES];
    [self.view addSubview:self.trimmerView];
    
    /*
    self.trimmerView.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.trimmerView.frame), CGRectGetHeight(self.trimmerView.frame));
    self.trimmerView.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.trimmerView.scrollView.frame), CGRectGetHeight(self.trimmerView.scrollView.frame));
    CGFloat ratio = self.trimmerView.showsRulerView ? 0.7 : 1.0;
    self.trimmerView.frameView.frame = CGRectMake(self.trimmerView.thumbWidth, 0, CGRectGetWidth(self.trimmerView.contentView.frame)-2*self.trimmerView.thumbWidth, CGRectGetHeight(self.trimmerView.contentView.frame)*ratio);
    */
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    int heightSpace = 20;
//    if (ITS_X_SERIES) {
//        heightSpace = 40;
//    }
//    self.navView.frame = CGRectMake(0, heightSpace, SCREEN_WIDTH, 50);
    self.nextBtn.frame = CGRectMake(kScreenWidth - 60, 0, 50, 50);
    self.navTitle.frame = CGRectMake(50, 0, (kScreenWidth - 100), 50);
    self.playBtn.frame = CGRectMake((kScreenWidth-75)/2,(kScreenHeight-175)/2, 75, 75);
    self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-50-110);
    self.trimmerView.frame = CGRectMake(0, kScreenHeight-100, kScreenWidth, 100);
    CMTime  time = [self.asset duration];
    self.trimmerView.maxLength = time.value/time.timescale + 1;
    // set properties for trimmer view
    [self.trimmerView setThemeColor1:[UIColor lightGrayColor]];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setTrackerColor:[UIColor cyanColor]];
    [self.trimmerView setDelegate:self];
    // important: reset subviews
    [self.trimmerView resetSubviews];
    [self.trimButton setHidden:YES];
   /*
    self.trimmerView.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.trimmerView.frame), CGRectGetHeight(self.trimmerView.frame));
    self.trimmerView.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.trimmerView.scrollView.frame), CGRectGetHeight(self.trimmerView.scrollView.frame));
    CGFloat ratio = self.trimmerView.showsRulerView ? 0.7 : 1.0;
    self.trimmerView.frameView.frame = CGRectMake(self.trimmerView.thumbWidth, 0, CGRectGetWidth(self.trimmerView.contentView.frame)-2*self.trimmerView.thumbWidth, CGRectGetHeight(self.trimmerView.contentView.frame)*ratio);
    */
}
- (void)backBtnClick{
    
    [self.player pause];
    
     self.playBtn.hidden = NO;
    
    [self stopPlaybackTimeChecker];
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying) {
        [self.player pause];
        self.playBtn.hidden = NO;
        [self stopPlaybackTimeChecker];
    }else {
        [self.player play];
        self.playBtn.hidden = YES;
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:NO];
}
- (UIButton *)playBtn{
    
    if (!_playBtn) {
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _playBtn.frame = CGRectMake((kScreenWidth-75)/2,(kScreenHeight-175)/2, 75, 75);
        
        [_playBtn addTarget:self action:@selector(tapOnVideoLayer:) forControlEvents:UIControlEventTouchUpInside];
        
        [_playBtn setBackgroundImage:KImageName(@"Video playback") forState:UIControlStateNormal];
        
        [self.videoLayer addSubview:_playBtn];
    }
    return _playBtn;
}
- (void)saveVideo{
    
    if (self.stopTime <= 0 || self.startTime <= 0) {
        SHOW_HUD_DELAY(JELocalizedString(@"Video is too short for editing", nil), self.view, 1.5);
        return ;
    }

    [self deleteTempFile];

    [self.player pause];
    
    self.playBtn.hidden = NO;
        
    [self stopPlaybackTimeChecker];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        //导出视频
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:{
                    
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    
                    break;
                }
                case AVAssetExportSessionStatusCancelled:{
                    
                    NSLog(@"Export canceled");
                    
                    break;
                }
                default:{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSURL *movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
                        
                        CLFilterViewController *vc = [[CLFilterViewController alloc]init];

                        vc.videoUrl = movieUrl;

                        switch (self.saveVideoStyle) {
                            case Normal:
                                 vc.saveVideoStyleCL = NormalCL;
                                break;
                            case Delayed:
                                vc.saveVideoStyleCL = DelayedCL;
                                break;
                            case Slow:
                                vc.saveVideoStyleCL = SlowCL;
                                break;
                            default:
                                break;
                        }
                        vc.firstImage = self.firstImage;
                        
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    break;
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ICGVideoTrimmerDelegate
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime {
    
    if (startTime <= 0 || endTime <= 0) {
        SHOW_HUD_DELAY(JELocalizedString(@"Video is too short for editing", nil), self.view, 0.5);
        [self.trimmerView removeFromSuperview];
        self.trimmerView = nil;
        return;
    }
    
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    
    self.stopTime = endTime;

}
#pragma mark - Actions

- (void)deleteTempFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL exist = [fm fileExistsAtPath:url.path];
    
    NSError *err;
    
    if (exist) {
        
        [fm removeItemAtURL:url error:&err];
        
        NSLog(@"file deleted");
        
        if (err) {
            
            NSLog(@"file remove error, %@", err.localizedDescription);
        }
    } else {
        
        NSLog(@"no file by that name");
    }
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}
- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        
       [self.playbackTimeCheckerTimer invalidate];
        
        self.playbackTimeCheckerTimer = nil;
    }
}
#pragma mark - PlaybackTimeCheckerTimer
- (void)onPlaybackTimeCheckerTimer
{
    self.videoPlaybackPosition = CMTimeGetSeconds([self.player currentTime]);
    
    [self.trimmerView seekToTime:CMTimeGetSeconds([self.player currentTime])];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [self.trimmerView seekToTime:self.startTime];
        
        [self.player pause];
        self.isPlaying = NO;
        self.playBtn.hidden = NO;
    }
}
- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - 强制竖屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
