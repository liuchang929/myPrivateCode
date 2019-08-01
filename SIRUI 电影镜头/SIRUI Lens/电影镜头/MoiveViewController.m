//
//  MoiveViewController.m
//  电影镜头
//
//  Created by xml on 2019/2/20.
//  Copyright © 2019年 xml. All rights reserved.
//

#import "MoiveViewController.h"
#import "WCLRecordVideo/WCLRecordEngine/WCLRecordEngine.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Masonry.h"
#import "UIColor+Hex.h"
#import "SRDeviceUtils.h"
#import "SRShootSwicher.h"


#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface MoiveViewController ()<WCLRecordEngineDelegate,SRShootSwicherPotocol>
{
    SRShootSwicher *_shootSwitchView;
}

@property (strong, nonatomic) UIButton * recordBt;
@property (strong, nonatomic) UIButton *flashLightBT;
@property (strong, nonatomic) WCLRecordEngine * recordEngine;
@property (strong, nonatomic) UIImageView * videoImage;

@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UILabel *timelabel;
@property (nonatomic, strong) UIView *redPoint;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat recordTime;
@end

@implementation MoiveViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    _recordEngine = nil;
}

#pragma mark - set、get方法
- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
        _recordEngine.captureMode = captureModeVideo;
    }
    return _recordEngine;
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        //[self.recordEngine previewLayer].frame = self.view.bounds;
        self.view.backgroundColor = [UIColor blackColor];
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES]; 
    [self setView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];//屏幕旋转的检测
    
    //点击屏幕对焦的手势
    UITapGestureRecognizer *foucusTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(foucus:)];
    [self.view addGestureRecognizer:foucusTap];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    self.recordBt.selected = NO;
    [self.recordBt setBackgroundImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
    if(_recordEngine.captureMode == captureModePicture)
    {
        [self.recordBt setBackgroundImage:[UIImage imageNamed:@"picture"] forState:UIControlStateNormal];
    }
    
    self.timeView.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
    self.timelabel.text = @"00:00:00";
    _recordTime = 0.0;
    
    [self.recordEngine stopCaptureHandler:nil];
    printf("触发home按下\n");
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    printf("重新进来后响应\n");
}

/**屏幕旋转的通知回调*/
- (void)orientChange:(NSNotification *)noti {
    //    NSDictionary* ntfDict = [noti userInfo];
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    [self uploadTimeView:orient];
    /*
    switch (orient) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeRight:
            break;
        default:
            break;
    }
     */
}

-(void)uploadTimeView:(UIDeviceOrientation)deviceOrientation{
    if(deviceOrientation == UIDeviceOrientationPortrait)
    {
        CGAffineTransform at =CGAffineTransformMakeRotation(0);
        [self.timeView setTransform:at];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 38));
            make.centerX.equalTo(self.view.mas_centerX);
            
            if([SRDeviceUtils isNotchScreen])
            {
                make.top.equalTo(self.view).with.offset(38);
            }
            else{
                make.top.equalTo(self.view).with.offset(18);
            }
            
        }];
        
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        CGAffineTransform at =CGAffineTransformMakeRotation(M_PI/2);
        [self.timeView setTransform:at];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 38));
            make.left.equalTo(self.view.mas_left).offset(10.0);
            make.right.equalTo(self.view.mas_left).offset(110.0);
            make.centerY.mas_equalTo(self.view.mas_centerY);

        }];
        
    }
    else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        CGAffineTransform at =CGAffineTransformMakeRotation(M_PI);
        [self.timeView setTransform:at];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            /*
            make.size.mas_equalTo(CGSizeMake(100, 38));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-98);
            */
            make.size.mas_equalTo(CGSizeMake(100, 38));
            make.centerX.equalTo(self.view.mas_centerX);
            
            if([SRDeviceUtils isNotchScreen])
            {
                make.top.equalTo(self.view).with.offset(38);
            }
            else{
                make.top.equalTo(self.view).with.offset(18);
            }
        }];
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        CGAffineTransform at =CGAffineTransformMakeRotation(-M_PI/2);
        [self.timeView setTransform:at];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 38));
            make.left.equalTo(self.view.mas_right).offset(-110.0);
            make.right.equalTo(self.view.mas_right).offset(-10.0);
            make.centerY.mas_equalTo(self.view.mas_centerY);
            
        }];
    }
    [self.view layoutIfNeeded];
}


-(void)setView{
    UIButton * button = [[UIButton alloc] init];
    UIImage *img = [UIImage imageNamed:@"videoRecord"];
    [button setBackgroundImage:img forState:UIControlStateNormal];
    [button addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    self.recordBt = button;
    [self.view addSubview:self.recordBt];
    
    [self.recordBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(80));
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view).with.offset(-10);
    }];
    
    self.videoImage = [[UIImageView alloc] init];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(showVideo)];
    [self.videoImage setUserInteractionEnabled:YES];
    [self.videoImage addGestureRecognizer:singleTap];
    [self.view addSubview:_videoImage];
    
    [self.videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(50));
        make.right.equalTo(self.view).with.offset(-10);
        make.centerY.equalTo(self.recordBt.mas_centerY);
    }];
    
    _flashLightBT = [[UIButton alloc] init];
    [_flashLightBT setBackgroundImage:[UIImage imageNamed:@"flashlightOff"] forState:UIControlStateNormal];
    [_flashLightBT setBackgroundImage:[UIImage imageNamed:@"flashlightOn"] forState:UIControlStateSelected];
    [_flashLightBT addTarget:self action:@selector(flashLightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashLightBT];
    
    [_flashLightBT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(49));
        make.height.equalTo(@(34));
        make.right.equalTo(self.view).with.offset(0);
        make.top.equalTo(self.view).with.offset(10);
    }];
    
    UIButton * backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"panoBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(30));
        make.height.equalTo(@(25));
        make.left.equalTo(self.view).with.offset(10);
        make.top.equalTo(self.view).with.offset(10);
    }];
    
    self.timeView = [[UIView alloc] init];
    self.timeView.hidden = YES;
    self.timeView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.5];
    self.timeView.layer.cornerRadius = 4;
    self.timeView.layer.masksToBounds = YES;
    [self.view addSubview:self.timeView];
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 38));
        make.centerX.equalTo(self.view.mas_centerX);
        
        if([SRDeviceUtils isNotchScreen])
        {
            make.top.equalTo(self.view).with.offset(38);
        }
        else{
            make.top.equalTo(self.view).with.offset(18);
        }
    
    }];
    
    self.timelabel =[[UILabel alloc] init];
    self.timelabel.font = [UIFont systemFontOfSize:13];
    self.timelabel.textColor = [UIColor whiteColor];
    self.timelabel.backgroundColor = [UIColor clearColor];
    self.timelabel.text = @"00:00:00";
    [self.timeView addSubview:self.timelabel];
    [self.timelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.width.equalTo(@(40));
        make.centerX.equalTo(self.timeView.mas_centerX);
        make.top.bottom.equalTo(self.timeView).with.offset(0);
    }];
    
    UIView *redPoint = [[UIView alloc] init];
    redPoint.frame = CGRectMake(0, 0, 6, 6);
    redPoint.layer.cornerRadius = 3;
    redPoint.layer.masksToBounds = YES;
    redPoint.center = CGPointMake(25, 17);
    redPoint.backgroundColor = [UIColor redColor];
    self.redPoint = redPoint;
    [self.timeView addSubview:self.redPoint];
    [self.redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(6));
        make.centerY.equalTo(self.timeView.mas_centerY);
        make.left.equalTo(self.timeView.mas_left).with.offset(10);
    }];
    
    _shootSwitchView = [[SRShootSwicher alloc] init];
    _shootSwitchView.delegate = self;
    [self.view addSubview:_shootSwitchView];
    [_shootSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.centerY.equalTo(self.recordBt.mas_centerY);
        make.left.equalTo(self.view.mas_left).with.offset(10);
    }];
    
    _shootSwitchView.hidden = YES;
}

-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//切换视频拍照
-(void)switchVideo:(BOOL)video{
    if(video)
    {
        self.recordEngine.captureMode = captureModeVideo;
        [self.recordBt setBackgroundImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
    }
    else{
        self.recordEngine.captureMode = captureModePicture;
        [self.recordBt setBackgroundImage:[UIImage imageNamed:@"picture"] forState:UIControlStateNormal];
    }
}


#pragma mark - 开始和暂停录制事件
- (void)recordAction:(UIButton *)sender {

    if(self.recordEngine.captureMode == captureModeVideo)
    {
        self.recordBt.selected = !self.recordBt.selected;
        _shootSwitchView.userInteractionEnabled = NO; //拍摄过程中禁止更换模式
        
        if (self.recordBt.selected) {
            
            self.timeView.hidden = NO;
            [self.recordEngine getCaptureVideoOrientation];
            
            //延时执行是为了解决视频刚开始发黑的问题
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.recordEngine startCapture];
                
                [self.recordBt setBackgroundImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateNormal];
                
                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTimeLabel) userInfo:nil repeats:YES];
                
            });
        }else {
            
            _shootSwitchView.userInteractionEnabled = YES;
            
            [self.recordBt setBackgroundImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
            
            self.timeView.hidden = YES;
            
            __weak typeof(self) weakSelf = self;
            
            [self.timer invalidate];
            self.timer = nil;
            self.timelabel.text = @"00:00:00";
            _recordTime = 0.0;
            
            [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
                weakSelf.videoImage.image = movieImage;
            }];
        }
    }
    else{
        
        [self.recordEngine getCaptureVideoOrientation];
        
        //延时执行是为了解决视频刚开始发黑的问题
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.recordEngine startCapture];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.timeView.hidden = YES;
                
                [self.timer invalidate];
                self.timer = nil;
                self.timelabel.text = @"00:00:00";
                _recordTime = 0.0;
                
                __weak typeof(self) weakSelf = self;
                AudioServicesPlaySystemSound(1108);
                [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
                    UIImageWriteToSavedPhotosAlbum(movieImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }];
            
            });
        });
        
    }
    
}

-(void)showVideo{
    NSURL * url = [NSURL fileURLWithPath:self.recordEngine.videoPath];
    
    AVPlayerViewController * playVC = [[AVPlayerViewController alloc] init];
    playVC.player = [AVPlayer playerWithURL:url];
    [self presentViewController:playVC animated:YES completion:nil];
}

#pragma mark -- <保存到相册>
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
}


- (void)refreshTimeLabel
{
    self.redPoint.hidden = !self.redPoint.hidden;
    _recordTime += 1.0;
    int minutes = floor(_recordTime/60);
    int seconds = trunc(_recordTime - minutes * 60);
    int hours = floor(_recordTime / (60 * 60));
    self.timelabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
}

- (NSString *)imageToString:(UIImage *)image {
    //     NSData *imageData = UIImageJPEGRepresentation(image,1.0f);
    NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil]];
    NSString *image64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithFormat:@"data:image/jpeg;base64,%@",image64];
}

//开关闪光灯
- (void)flashLightAction:(id)sender {
    self.flashLightBT.selected = !self.flashLightBT.selected;
    if (self.flashLightBT.selected == YES) {
        [self.recordEngine openFlashLight];
    }else {
        [self.recordEngine closeFlashLight];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - close rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//手动对焦
-(void)foucus:(UITapGestureRecognizer *)sender
{
    if(sender.state==UIGestureRecognizerStateRecognized)
    {
        CGPoint point = [sender locationInView:self.view];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
        CGPoint pointOfInterest = CGPointZero;
        CGSize frameSize = self.view.bounds.size;
        pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            
            NSError *error;
            if ([device lockForConfiguration:&error])
            {
                
                if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
                {
                    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
                }
                
                if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                {
                    [device setFocusMode:AVCaptureFocusModeAutoFocus];
                    [device setFocusPointOfInterest:pointOfInterest];
                }
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                
                [device unlockForConfiguration];
            }
        }
        
    }
}

@end
