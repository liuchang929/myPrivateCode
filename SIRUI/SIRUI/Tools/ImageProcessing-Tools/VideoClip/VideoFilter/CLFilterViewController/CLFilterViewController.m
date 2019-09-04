//
//  CLFilterViewController.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLFilterViewController.h"
#import "CLFilterScrollView.h"
#import "CLCustomView.h"
#import "CLFiltersClass.h"
#import "CLVideoAddFilter.h"
#import "CLMBProgress.h"
#import "ViewController.h"
//#import "AddVideoMusicViewController.h"
#import "UITextView+WZB.h"
#import "YFXCustomFlowTextField.h"
#import "NSString+date.h"
@interface CLFilterViewController ()<CLFilterScroViewDelegate, CLCustomViewDelegate,CLVideoAddFilterDelegate>{
    
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filters;
    AVPlayer *videoPlayer;
    AVPlayerItem *item;
    CLCustomView *customView; //各控件所在的载体View
}

@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) NSMutableArray *filterArray;//滤镜图片数组
@property (nonatomic, strong) NSArray *titleArray;//滤镜名数组
@property (nonatomic, weak)id playbackTimeObserver;//播放进度观察者
@property (nonatomic, strong) CLMBProgress *clProgress;//显示处理进度
@property (nonatomic, assign) NSInteger index;//选择第几个滤镜参数，默认 = 0 无滤镜
//@property (nonatomic, strong) YFXCustomFlowTextField *textView;

@end

@implementation CLFilterViewController

-(void)textFieldDidChange:(UITextField *)sender{
   
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]};
    
    CGSize titleSize = [sender.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 32.0f) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    /*
    self.textView.size = titleSize;
    
    if (self.textView.size.width<0||self.textView.size.width==0) {
        
        _textView.frame = CGRectMake(0,0, kScreenWidth-100, 40);
        
        [_textView sizeToFit];
        
        _textView.center = self.view.center;
    }
     */
}

/*
- (UITextField *)textView{
    if (!_textView) {
        _textView = [[YFXCustomFlowTextField alloc]initWithFrame:CGRectMake(0,0, kScreenWidth-100, 40)];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.placeholder = JELocalizedString(@"随意拖动,输入文字...",nil);
        _textView.font = [UIFont systemFontOfSize:18.0f];
        [_textView sizeToFit];
         _textView.center = self.view.center;
         _textView.textColor = [UIColor whiteColor];
        [_textView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_textView setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    return _textView;
}
 */
 
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.titleArray = @[JELocalizedString(@"Origin",nil),JELocalizedString(@"Janpanese&Korean",nil), JELocalizedString(@"Modern",nil), JELocalizedString(@"Funk",nil),JELocalizedString(@"Eastern",nil), JELocalizedString(@"Black&White",nil), JELocalizedString(@"Western",nil), JELocalizedString(@"Old School",nil),JELocalizedString(@"Glow",nil),JELocalizedString(@"Sharp",nil),JELocalizedString(@"Gaussian Blur",nil),JELocalizedString(@"Distorting Mirror",nil),JELocalizedString(@"Fisheye",nil),JELocalizedString(@"Sketch",nil)];
    
    self.filterArray = [NSMutableArray array];
        
    for (int i = 0; i <self.titleArray.count; i++) {
        [self.filterArray addObject:[CLFiltersClass imageAddFilter:self.firstImage index:i]];
    
    }
    self.index = 0;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int heightSpace = 20;
    if (ITS_X_SERIES) {
        heightSpace = 40;
    }
    
    customView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.clProgress.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    self.clProgress.center = self.view.center;
    self.filterView.frame = self.view.bounds;
    customView.nextButton.frame =  CGRectMake(kScreenWidth - 60, heightSpace, 50, 50);
    customView.filterButton.frame = CGRectMake(50, heightSpace, (kScreenWidth - 100), 50);
    customView.backgroundView.frame = CGRectMake(0, 0, kScreenWidth, 132.0f);
    customView.filterScrollView.frame = CGRectMake(0, customView.backgroundView.frame.size.height - FilterScrollHight, customView.backgroundView.frame.size.width, FilterScrollHight);
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self creatFilterView];
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self videoStop];
    
    [self removeNotification];
    
    [movieFile cancelProcessing];
}

- (void)creatFilterView{
    
    AVAsset *aset = [AVAsset assetWithURL:self.videoUrl];
    
    AVAssetTrack *videoAssetTrack = [[aset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSLog(@"%f", videoAssetTrack.naturalSize.width);
    NSLog(@"%f", videoAssetTrack.naturalSize.height);
    
    self.filterView = [[GPUImageView alloc]init];
    self.filterView.frame = self.view.bounds;
    item = [AVPlayerItem playerItemWithAsset:aset];
    videoPlayer = [AVPlayer playerWithPlayerItem:item];
    [videoPlayer replaceCurrentItemWithPlayerItem:item];
    //监听status属性
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
    playerLayer.frame = CGRectMake(0, kNavgationHeight, kScreenWidth, kScreenHeight);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [videoPlayer play];
   
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:item];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    
    GPUImageFilter *filt = [[GPUImageFilter alloc]init];
    filters = filt;
    [movieFile addTarget:filters];
    
     self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    [self.view bringSubviewToFront:self.filterView];
//    [self.filterView setTransform:transform];
    
    //横屏视频播放会有方向bug，竖屏无，故横屏旋转90°
//    NSLog(@"degress : %lu", [self degressFromVideoFileWithURL:self.videoUrl]);
    if([self degressFromVideoFileWithURL:self.videoUrl] == 1) {
        [self.filterView setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    }
    [filters addTarget:self.filterView];
    [movieFile startProcessing];
    
    [self videoPlay];
    [self addNotification];
    [self creatViews];
}

- (void)creatViews{
    
    int heightSpace = 20;
    if (ITS_X_SERIES) {
        heightSpace = 40;
    }
    
    customView = [[CLCustomView alloc] initWithFrame:CGRectMake(0, 0 ,kScreenWidth, kScreenHeight)];
    customView.nextButton.frame =  CGRectMake(kScreenWidth - 60, heightSpace, 50, 50);
    customView.filterButton.frame = CGRectMake(50, heightSpace, (kScreenWidth - 100), 50);
    customView.backgroundView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 132.0f);
    customView.filterScrollView.frame = CGRectMake(0, customView.backgroundView.frame.size.height - FilterScrollHight,customView.backgroundView.frame.size.width, FilterScrollHight);
    //添加文字
    [customView.filterScrollView setFilterImages:self.filterArray titleArray:self.titleArray index:self.index];
    customView.filterScrollView.tbDelegate = self;
    customView.delegate = self;
    [self.view addSubview:customView];
//    [self.view addSubview:self.textView];
    
    // 点下一步视频处理进度
    self.clProgress = [[CLMBProgress alloc]initWithFrame:CGRectMake(0, 0, kScreenHeight, kScreenWidth)];
//    [self.clProgress setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    self.clProgress.center = self.view.center;
    [self.view addSubview:self.clProgress];
    self.clProgress.hidden = YES;
    
    // 进入时加载滤镜，index为滤镜下标
    [self seletcScrollIndex:self.index];
    
    [self filterButtonAction];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapsAction)];
    [self.view addGestureRecognizer:tap];
    
    NSLog(@"saveVideoStyleCL : %u", _saveVideoStyleCL);
}
#pragma mark - CLCustomView 代理
- (void)clickedButtonChooseType:(ChooseButtonType)chooseType{
    
    if (chooseType == BackGoOutButton) {
        
        [self dissMissButton];
        
    }else if (chooseType == NextGoInButton){
        
        [self nextButtonAction];
       
    }else if (chooseType == FilterShowButton){
        
        [self filterButtonAction];
    }
}
#pragma mark - video 播放状态play/stop
- (void)videoPlay{
    isPlay = YES;
    [videoPlayer play];
}

- (void)videoStop{
    isPlay = NO;
    [videoPlayer pause];
}

#pragma mark - buttonAction
- (void)filterButtonAction{
    
    [self filterViewHiddenNO];
}

// 显示customView
- (void)filterViewHiddenNO{
 
    customView.backgroundView.hidden = NO;
    isShowFilter = 1 - isShowFilter;
}

// 点击暂停开始 手势
- (void)tapsAction{
    
//    [self.textView resignFirstResponder];
    
    if (isPlay) {
            
        [self videoStop];
            
    }else{
            
        [self videoPlay];
    }
}

// 返回事件
- (void)dissMissButton{
    // 清空临时文件
    deleteTempDirectory();
  
    [self videoStop];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 下一步
- (void)nextButtonAction{

        [self videoStop];
        
        [self filterViewHiddenNO];
        
        self.clProgress.progressHUD.labelText = JELocalizedString(@"Video Processing...",nil);
        
        self.clProgress.hidden = NO;
    
        CLVideoAddFilter *addFilter = [[CLVideoAddFilter alloc]init];
            
        addFilter.delegate = self;
    
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
//            if (self.saveVideoStyleCL==NormalCL||self.saveVideoStyleCL==SlowCL) {
                [addFilter addVideoFilter:self.videoUrl tempVideoPath:[NSString vidoTempPath] index:self.index isDvideo:NO];
//            }
//            if (self.saveVideoStyleCL==DelayedCL) {
//                [addFilter addVideoFilter:self.videoUrl tempVideoPath:[NSString vidoTempPath] index:self.index isDvideo:YES];
//            }
       });
}
#pragma mark - 通知/KVO
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void)removeNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    
    NSLog(@"视频播放完成.");
    
    item = [notification object];
    
    [item seekToTime:kCMTimeZero];
    
    [self videoPlay];
}
#pragma mark - 自定义ScrollView——协议
- (void)seletcScrollIndex:(NSInteger)index{
    
    self.index = index;
    // 实时切换滤镜
    [CLFiltersClass addFilterLayer:movieFile filters:filters filterView:self.filterView index:index];
    
    [self videoPlay];
}
#pragma mark - CLVideoAddFilter 协议回调
// 滤镜处理进度
- (void)filterDealProgress:(CGFloat)progress{
   
    
}
// 视频完成处理
- (void)didFinishVideoDeal:(NSURL *)videoUrl{
    
    //保存视频
    NSLog(@"保存视频");
    NSData *movieData = [NSData dataWithContentsOfURL:videoUrl];
    
    NSString *videoPreString = [JECameraManager shareCAMSingleton].getNowDate;
    NSString *videoNewPath = [[JECameraManager shareCAMSingleton] getVideoPathWithName:[NSString stringWithFormat:@"%@.mov", videoPreString]];
    unlink([videoNewPath UTF8String]);
    
    //视频会出现向左旋转 90 度的 bug，所以保存时进行向右旋转 90 度处理
    /*
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    UIImageOrientation videoAssetOrientation = UIImageOrientationUp;
    BOOL isVideoAssetPortrait = NO;
    CGAffineTransform videoTransform = assetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation =  UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation = UIImageOrientationDown;
    }
     */
//    NSLog(@"", );
    
    if ([movieData writeToFile:videoNewPath atomically:YES]) {
        if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:videoUrl size:[self getUserSaveVideoResolution]] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", videoPreString]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.clProgress.hidden = YES;
                SHOW_HUD_DELAY(JELocalizedString(@"Saved", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.clProgress.hidden = YES;
                SHOW_HUD_DELAY(JELocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            });
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.clProgress.hidden = YES;
            SHOW_HUD_DELAY(JELocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
        });
    }
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    /*
    if([UserInfoCenter manager].NickName||[UserInfoCenter manager].PhoneNumber){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.clProgress.hidden =  YES;
            
            
            AddVideoMusicViewController *vc = [[AddVideoMusicViewController alloc]init];
            
            vc.videoUrl = videoUrl;
            
            switch (self.saveVideoStyleCL) {
                case NormalCL:
                    vc.saveVideoStyleBGM = NormalBGM;
                    break;
                case DelayedCL:
                    vc.saveVideoStyleBGM = DelayedBGM;
                    break;
                case SlowCL:
                    vc.saveVideoStyleBGM = SlowBGM;
                    break;
                default:
                    break;
            }
            [self.navigationController pushViewController:vc animated:YES];
            
        });
        
    }else{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self addWatermark:videoUrl];
            
        });
        
    }
     */
}
// 操作中断
- (void)operationFailure:(NSString *)failure{
    
    self.clProgress.hidden = YES;
}

/*
//添加水印
- (void)addWatermark:(NSURL *)videoUrl{
    
    AVAsset *videoAsset = [AVAsset assetWithURL:videoUrl];
    
    //AVMutableComposition是个容器，可以在里面添加和移除视频轨和音频轨
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    //媒体轨道，有音频轨和视频轨，可以插入各种素材
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //把视频数据插入到可变媒体轨道中，时间就是整个视频播放时间
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,  videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //这是媒体轨道中的一个视频，可以进行视频缩放和旋转等操作
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    //视频轨道，包含了所有的视频素材
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    //视频资源轨道，包含了视频创建时间，总时长，音量等等信息
    AVAssetTrack *assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    if (self.saveVideoStyleCL==NormalCL||self.saveVideoStyleCL==SlowCL){
        // 声音采集
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
        CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);;
        // 音频通道
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 音频采集通道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        // 加入合成轨道之中
        [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    }
    mainInstruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = assetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;   //3
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;   //2
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;     //0
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;    //1
    }
    NSLog(@"videoAssetOrientation_ = %ld", (long)videoAssetOrientation_);
    NSLog(@"degress : %lu",(unsigned long)[self degressFromVideoFileWithURL:self.videoUrl]);
    
    //横屏时需要调整屏幕方向
    if ([self degressFromVideoFileWithURL:self.videoUrl] == 1) {
        [videoLayerInstruction setTransform:assetTrack.preferredTransform atTime:kCMTimeZero];
    }
    
    [videoLayerInstruction setOpacity:0.0 atTime: videoAsset.duration];
    
    AVMutableVideoComposition *mainCompositionInstrument = [AVMutableVideoComposition videoComposition];
    CGSize naturalSize;
    if ([self degressFromVideoFileWithURL:self.videoUrl] == 1 && videoAssetOrientation_ == 2) {
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
    [self applyVideoEffectsToComposition:mainCompositionInstrument size:naturalSize];
    //输出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    NSURL *videoURL = [NSURL fileURLWithPath:myPathDocs];
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    //视频文件输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = videoURL;
    
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    exporter.shouldOptimizeForNetworkUse = YES;
    
    exporter.videoComposition = mainCompositionInstrument;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
//
//            self.clProgress.hidden =  YES;
//
//            AddVideoMusicViewController *vc = [[AddVideoMusicViewController alloc]init];
//
//            vc.videoUrl = exporter.outputURL;
//
//            switch (self.saveVideoStyleCL) {
//                case NormalCL:
//                    vc.saveVideoStyleBGM = NormalBGM;
//                    break;
//                case DelayedCL:
//                    vc.saveVideoStyleBGM = DelayedBGM;
//                    break;
//                case SlowCL:
//                    vc.saveVideoStyleBGM = SlowBGM;
//                    break;
//                default:
//                    break;
//            }
//
//            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
}
 */


/*
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 1 - Set up the text layer
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFrame:CGRectMake(size.width-225, 0, 100, 100)];
    [subtitle1Text setContents:(id)([UIImage imageNamed:@"水印图片"].CGImage)];
    CATextLayer *subtitle1Text1 = [[CATextLayer alloc] init];
    if ([self.textView.text length]!=0) {
        [subtitle1Text1 setFrame:CGRectMake(self.textView.origin.x*size.width/kScreenWidth, size.height-50-self.textView.origin.y*size.height/kScreenHeight, size.width, 50)];
      //[subtitle1Text1 setAlignmentMode:kCAAlignmentNatural];//自然(默认)
        subtitle1Text1.alignmentMode =kCAAlignmentJustified;//自适应
        UIFont *font = [UIFont systemFontOfSize:32.0f];
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef =CGFontCreateWithFontName(fontName);
        subtitle1Text1.font = fontRef;
        subtitle1Text1.fontSize = font.pointSize;
        subtitle1Text1.wrapped = YES;
        subtitle1Text1.contentsScale = [UIScreen mainScreen].scale;
        [subtitle1Text1 setString:self.textView.text];
    }
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    [overlayLayer addSublayer:subtitle1Text1];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}
 */

#pragma mark - 获取屏幕方向
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
//            degress = 90;
            degress = 0;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
//            degress = 270;
            degress = 1;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
//            degress = 0;
            degress = 3;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
//            degress = 180;
            degress = 2;
        }
    }
    
    return degress;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSLog(@"image : %@", [UIImage imageWithCGImage:img]);
//    {
        return [UIImage imageWithCGImage:img];
//    }
//    return nil;
}

//获取用户当前选择的分辨率尺寸
- (CGSize)getUserSaveVideoResolution {
    NSInteger videoResolutionInteger = USER_GET_SaveVideoResolution_Integer;
    switch (videoResolutionInteger) {
        case 0:
            //            if (_mainRotate == 0) {
            return CGSizeMake(480, 640);
            //            }
            //            else return CGSizeMake(640, 480);
            break;
            
        case 1:
            //            if (_mainRotate == 0) {
            return CGSizeMake(720, 1280);
            //            }
            //            else return CGSizeMake(1280, 720);
            break;
            
        case 2:
            //            if (_mainRotate == 0) {
            return CGSizeMake(1080, 1920);
            //            }
            //            else return CGSizeMake(1920, 1080);
            break;
            
        case 3:
            //            return CGSizeMake(2160, 3840);
            //            if (_mainRotate == 0) {
            return CGSizeMake(1080, 1920);      //当前发现录像时丢帧，初步断定是分辨率太高的原因？所以暂时不支持 4k 录制
            //            }
            //            else return CGSizeMake(1920, 1080);
            break;
            
        default:
            return CGSizeMake(0, 0);
            break;
    }
}


@end
