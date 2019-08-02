//
//  JESmartCameraViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/1.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JESmartCameraViewController.h"
//#import "JESmartCameraModel.h"
#import "JEBluetoothManager.h"
#import "JECameraTopToolBar.h"
#import "JECameraBottomToolBar.h"
#import "JECameraBottomMenu.h"
#import "SR360CamFilterView.h"
#import "DotGPUImageBeautyFilter.h"
#import "JECameraSettingView.h"
#import "JECustomFunctionView.h"
#import "JEVideoLocusTimeLapseView.h"
#import "JEVideoTimeLapseView.h"
#import "JEAlbumViewController.h"
#import "JECameraManager.h"
#import "UIButton+Countdown.h"
#import "JECameraMiddleToolBar.h"
#import "JETrackingView.h"
#import "JEFaceFocusView.h"
#import "DGActivityIndicatorView.h"
#import "SRStitcher.hpp"
#import "UIImage+OpenCV.h"
#import "CVWrapper.h"
#import "TOCropViewController.h"
#import "JESearchDevicesView.h"
#import "JEUpdateFirmwareView.h"
#import "JEWebManager.h"
#import "JEAuxLineView.h"
#import "SRMotionViewController.h"
#import "SRFocusingView.h"
#import "SliderView.h"
#import "UIImage+WaterMark.h"
#import "SRVideoRecordTool.h"
#import "JEGetDeviceVersion.h"

#import "SRTrackingCore.h"
#import "FileUtils.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import <Masonry.h>

size_t warpImageCnt;

#define FILTER_SUB_HEIGHT 100   //滤镜菜单栏高度
#define CUSTOM_ANIMATE_TIME 0.4 //自定义菜单动画时长
#define degreesToRadians(x) (M_PI*(x)/180.0)
#define Rotation_Key @"rotation"

typedef void(^getStillImageBlock)(UIImage *image);

@interface JESmartCameraViewController () <JEBluetoothManagerDelegate, JESearchDevicesViewDelegate, GPUImageVideoCameraDelegate, JECameraTopToolBarDelegate, JECameraMiddleToolBarDelegate, JECameraBottomToolBarDelegate, SR360CamFilterDelegate, JECameraSettingDelegate, JECustomFunctionViewDelegate, TOCropViewControllerDelegate, JEVideoLocusTimeLapseViewDelegate, AVCaptureFileOutputRecordingDelegate, NSURLSessionDataDelegate>
{
    
    dispatch_semaphore_t _seam;     //延时 GCD 信号量
    dispatch_source_t _timer;       //延时计时器
    CVPixelBufferRef _imageBuffer;  //延时获取的帧图片
    /*
     *  线程
     */
    dispatch_queue_t saveImageQueue;        //保存照片的线程
//    dispatch_queue_t trackingQueue;         //跟踪的线程
    
    cv::Rect selectBox;
    SRTrackingCore *SRObjTracker;
    
    float currValue;
    float flags;
    float curr;
    
}

//Component
/*
 *  AVCapture
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *photoOutputOriginal;   //用于保存原图
@property (nonatomic, strong) AVCaptureSession          *session;               //视频会话
@property (nonatomic, strong) AVCaptureDeviceInput      *captureDeviceInput;    //设备输入，用于慢动作画面获取
@property (nonatomic, strong) AVCaptureMovieFileOutput  *movieFileOutput;       //慢动作的视频录制
@property (nonatomic, strong) AVCaptureDeviceFormat     *defaultFormat;
@property (nonatomic) CMTime defaultMinFrameDuration;
@property (nonatomic) CMTime defaultMaxFrameDuration;
@property (nonatomic, strong) AVMutableComposition      *mutableComposition;    //视频合成用的
@property (nonatomic, strong) AVMutableVideoComposition *mutableVideoComposition;   //视频合成用的
@property (nonatomic, strong) SRVideoRecordTool         *videoRecordTool;       //视频工具
/*
 *  GPUImage
 */
@property (nonatomic, strong) GPUImageView              *cameraOutputView;      //预览 view
@property (nonatomic, strong) GPUImageMovieWriter       *movieWriter;           //用于保存视频
@property (nonatomic, strong) GPUImageFilter            *cameraFilter;          //滤镜
@property (nonatomic, strong) GPUImageFilter            *captureFilter;         //捕获滤镜？
//@property (nonatomic, strong) JESmartCameraModel        *cameraModel;           //相机基本模型
@property (nonatomic, strong) JECameraTopToolBar        *topToolBar;            //顶部 toolBar
@property (nonatomic, strong) JECameraMiddleToolBar     *middleToolBar;         //中部 toolbar
@property (nonatomic, strong) JECameraBottomToolBar     *bottomToolBar;         //底部 toolBar
@property (nonatomic, strong) JESearchDevicesView       *searchDevicesView;     //蓝牙搜索列表
@property (nonatomic, strong) UIView                    *topToolBarBlackView;   //菜单黑色背景
@property (nonatomic, strong) UIView                    *filterSubView;         //滤镜菜单
@property (nonatomic, strong) SR360CamFilterView        *filterSubIconView;     //滤镜子菜单
@property (nonatomic, strong) JECameraSettingView       *cameraSettingView;     //相机设置菜单
@property (nonatomic, strong) UIView                    *clearBackView;         //透明 view，用作屏蔽事件
@property (nonatomic, strong) JECustomFunctionView      *customFunctionView;    //自定义功能菜单
@property (nonatomic, strong) JEVideoLocusTimeLapseView *motionLapsePopView;    //轨迹延时
@property (nonatomic, strong) JEVideoTimeLapseView      *timeLapsePopView;      //普通延时
@property (nonatomic, strong) UILabel                   *videoTimeLB;           //录制时间 Label
@property (nonatomic, strong) UIButton                  *countdownBtn;          //倒计时按钮
@property (nonatomic, strong) UIView                    *objectTrackingView;    //对象跟踪框
@property (nonatomic, strong) UIView                    *panoWaitingView;       //全景合成等待界面
@property (nonatomic, strong) UIProgressView            *panoProgressView;      //全景合成进度条
@property (nonatomic, strong) UILabel                   *panoHint;              //全景合成提示
@property (nonatomic, strong) JEUpdateFirmwareView      *updateFirmwareView;    //固件升级界面
@property (nonatomic, strong) JEAuxLineView             *auxLineView;           //辅助线 view
@property (nonatomic, strong) SRFocusingView            *focusingView;          //对焦
@property (nonatomic, strong) SliderView                *zoomSliderView;        //变焦
@property (nonatomic, strong) UIButton                  *stopTimeLapseButton;   //延时摄影暂停按钮
@property (nonatomic, strong) SRMotionViewController    *accelerationVC;        //加速度校准 vc

//Base
@property (nonatomic, strong) GPUImageCropFilter        *normalFilter;          //基础滤镜
@property (nonatomic, strong) DotGPUImageBeautyFilter   *beautyFilter;          //美颜滤镜
@property (nonatomic, strong) AVCaptureMetadataOutput   *metaDataOutput;        //元数据捕获
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;             //捕捉图像的预览
@property (nonatomic, assign) CGAffineTransform         transform;              //屏幕方向
@property (nonatomic, assign) CGFloat                   mainRotate;             //旋转角度  0 == 竖屏
@property (nonatomic, assign) UIImageOrientation        imageOrientation;       //照片的方向
@property (nonatomic, assign) CGFloat                   mainRatioX;             //分辨率和屏幕的比例 X轴 和 Y轴
@property (nonatomic, assign) CGFloat                   mainRatioY;
@property (nonatomic, assign) CGFloat                   mainRatio;
@property (nonatomic, assign) CGFloat                   mainPreset;             //屏幕分辨率
@property (nonatomic, assign) CGFloat                   effectiveScale;         //移动变焦倍数
@property (nonatomic, assign) CGFloat                   mainFrameWidth;         //屏幕宽
@property (nonatomic, assign) CGFloat                   mainFrameHeight;        //屏幕高
@property (nonatomic, assign) CGFloat                   filmFrameWidth;         //电影屏幕宽
@property (nonatomic, assign) CGFloat                   filmFrameHeight;        //电影屏幕高
@property (nonatomic, assign) CGFloat                   filmDistortionRatio;    //电影镜头校正录制完成畸变
@property (nonatomic, assign) CGFloat                   filmRatio;              //展示界面调整

//Data
//@property (nonatomic, assign) BOOL      isSearchingDevice;      //蓝牙搜索设备中
@property (nonatomic, assign) BOOL      isFrontCamera;          //前置
@property (nonatomic, assign) BOOL      isFilterShowing;        //显示滤镜菜单
@property (nonatomic, assign) BOOL      isBeautyOpening;        //美颜
@property (nonatomic, assign) BOOL      isCameraSetting;        //显示相机设置菜单
@property (nonatomic, assign) BOOL      isDeviceSetting;        //显示设备设置菜单
@property (nonatomic, assign) BOOL      islensSwitching;        //正在切换镜头
@property (nonatomic, assign) BOOL      isSubShowing;           //菜单弹出状态
@property (nonatomic, assign) BOOL      isVideo;                //拍摄模式
@property (nonatomic, assign) BOOL      isFilm;                 //电影模式
@property (nonatomic, assign) BOOL      isPanoing;              //全景拍摄状态
@property (nonatomic, assign) BOOL      isFunctionShowing;      //自定义功能菜单
@property (nonatomic, assign) BOOL      isClearViewShowing;     //全屏屏蔽按键事件
@property (nonatomic, assign) BOOL      isMotionLapseShowing;   //移动延时菜单
@property (nonatomic, assign) BOOL      isTimeLapseShowing;     //普通延时菜单
@property (nonatomic, assign) BOOL      videoCapturing;         //视频采集中
@property (nonatomic, assign) BOOL      pictureCapturing;       //图片拍摄中
@property (nonatomic, assign) BOOL      timeLapseCapturing;     //延时视频采集状态
@property (nonatomic, assign) BOOL      isFaceTracking;         //人脸跟踪中
@property (nonatomic, assign) BOOL      isObjectTracking;       //对象跟踪中
@property (nonatomic, assign) BOOL      isObjTrackReady;        //对象跟踪准备好否
@property (nonatomic, assign) BOOL      isObjTrackStart;        //对象跟踪开始
@property (nonatomic, assign) BOOL      isAutoStitchPanoing;    //全景合成中
@property (nonatomic, assign) BOOL      isFirmwareUpdating;     //固件升级中
@property (nonatomic, assign) BOOL      updateFirmwareBag;      //固件升级包发送次序 0 == first，1 == second
@property (nonatomic, assign) int       timeLapseProgress;      //时间帧  60帧一秒
@property (nonatomic, assign) int       blueParameterTimes;     //蓝牙参数发送包数
@property (nonatomic, assign) int       updateFirmwareTimeCount;    //固件升级蓝牙获取不到回执计数
@property (nonatomic, strong) NSMutableArray    *bluetoothDeviceArray;      //蓝牙设备列表
@property (nonatomic, strong) NSArray           *cameraSettingArray;        //相机设置数据
@property (nonatomic, strong) NSArray           *deviceSettingArray;        //设备设置数据
@property (nonatomic, strong) NSMutableArray    *videoResolutionArray;      //相机支持的视频分辨率集合
@property (nonatomic, assign) AVCaptureSessionPreset highestResolution;     //相机支持最高的视频分辨率
@property (nonatomic, strong) NSString          *videoPath;                 //视频路径
@property (nonatomic, strong) NSTimer           *videoTimer;                //视频计时器
@property (nonatomic, assign) NSInteger         videoTimerSecond;           //视频录制时长,单位秒
@property (nonatomic, strong) NSString          *videoPreviewString;        //视频预览图的名字
@property (nonatomic, strong) NSMutableArray    *faceFramesArray;           //人脸数据数组
@property (nonatomic, assign) CGPoint           trackViewLTPoint;           //对象跟踪框左上角坐标
@property (nonatomic, assign) CGPoint           trackViewRDPoint;           //对象跟踪框右下角坐标
@property (nonatomic, assign) CGFloat           cropImageWidth;             //全景图片临时宽
@property (nonatomic, assign) CGFloat           cropImageHeight;            //临时高
@property (nonatomic, strong) NSMutableArray    *panoImagesArray;           //全景照片数组
@property (nonatomic, strong) NSMutableString   *updateFirmwareDataString;  //固件升级数据
@property (nonatomic, assign) NSInteger         updateFirmwareDataLength;   //固件升级数据长度
@property (nonatomic, strong) NSString          *blueParameter1;            //蓝牙参数数据字符串第一段
@property (nonatomic, strong) NSString          *blueParameter2;            //蓝牙参数数据字符串第二段
@property (nonatomic, strong) NSString          *blueParameterString;       //蓝牙参数数据字符串完整版
@property (nonatomic, strong) NSMutableArray    *motionLapsePointArray;     //移动延时关键点照片数据数组
@property (nonatomic, strong) NSArray           *customFunctionArray;       //自定义功能数组
@property (nonatomic, strong) NSString          *deviceNewVersion;          //从服务器获取的新固件版本
@property (nonatomic, strong) NSString          *deviceUpdateString;        //服务器更新的内容
@property (nonatomic, strong) NSURLSession      *askSession;                //网络升级请求
@property (nonatomic, strong) NSTimer           *updateFirmwareTimer;       //固件升级回执计时器

@end

@implementation JESmartCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [JEBluetoothManager shareBLESingleton].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"_controllerMode = %d", _controllerMode);
    
    [self screenRotate:nil];            //屏幕旋转检测
    [self configRatioByNotify];         //屏幕分辨率获取
    [self setVideoStabilizationMode];   //光学防抖
    [_stillCamera startCameraCapture];
    [self setupAuxLineView];    //辅助线
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadData];    //加载数据
    [self setupUI];     //加载视图
    if (_controllerMode != cameraM1) {
        //非手机三轴稳定器调整 ui
        [self adjustUI];
    }
    [self getVideoResolution];      //视频分辨率
    [self checkUserDefaultData];    //本地化数据初始化
    
    //屏幕旋转的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotate:) name:@"MotionOrientationChangedNotification" object:nil];
    
    //智能退出和返回的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResign) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecome) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //触发改变分辨率
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configRatioByNotify) name:Track_Quality_Change object:nil];
    
    //线程的初始化
    saveImageQueue = dispatch_queue_create("com.sirui.saveImageSerial", DISPATCH_QUEUE_SERIAL);
    
    //对象跟踪框的初始化
    self.objectTrackingView = [[UIView alloc] init];
    _objectTrackingView.layer.borderWidth = 1;
    _objectTrackingView.layer.borderColor = MAIN_TEXT_COLOR.CGColor;
    _objectTrackingView.hidden = YES;
    [self.view addSubview:_objectTrackingView];
    
    //基础滤镜初始化
    self.normalFilter = [[GPUImageCropFilter alloc] init];
    [self.stillCamera addTarget:self.normalFilter];
    self.captureFilter = self.cameraFilter;
    
    //等待设备连接稳定再获取消息
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //发送速度太快，蓝牙无法及时回复消息，需要限制发送频率
        //获取固件版本信息
        [[JEBluetoothManager shareBLESingleton] BPGetDeviceVersion];
        NSMutableArray *params = [NSMutableArray array];
        
        if (_controllerMode == cameraM1) {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"ProdID", nil]];
        }
        else if (_controllerMode == cameraP1) {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"ProdID", nil]];
        }
        
        //从服务器获取版本信息
        [JEWebManager loadDataCenter:params methodName:@"SR_GetLastFirmwareInfo" result:^(NSDictionary *resultDic, NSString *error) {
            if (error) {
                
                SHOW_HUD_DELAY(NSLocalizedString(@"Network Error", nil), self.view, 1);
                
                return;
            }
            
            //强制纠正语言
            NSArray *languages = [NSLocale preferredLanguages];
            
            NSString *language = [languages objectAtIndex:0];
            
            NSLog(@"system language = %@", language);
            
            if ([language hasPrefix:@"zh"]) {//检测开头匹配，是否为中文，再决定固件升级内容语言
                self.deviceUpdateString = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"InfoCN"][@"__text"];
            }
            else {
                self.deviceUpdateString = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"InfoEN"][@"__text"];
            }
            
            self.deviceNewVersion = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"return"][@"__text"];
            USER_SET_SaveVersionNewFirmware_NSString(_deviceNewVersion);
    
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //查询充电开关机状态
            [[JEBluetoothManager shareBLESingleton] BPCheckChargingState];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //获取蓝牙数据参数
            [[JEBluetoothManager shareBLESingleton] BPGetBLEParameter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //查询手柄移动方向状态
            [[JEBluetoothManager shareBLESingleton] BPCheckPitchOrientationOpposite];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //获取蓝牙版本信息
            [[JEBluetoothManager shareBLESingleton] BPGetBLEVersion];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    //相机停止捕获
    [_stillCamera stopCameraCapture];
}

#pragma mark - LazyLoading
//蓝牙搜索
- (JESearchDevicesView *)searchDevicesView {
    if (!_searchDevicesView) {
        _searchDevicesView = [[JESearchDevicesView alloc] initWithFrame:CGRectMake(0, 0, 250, self.view.frame.size.width - 50)];
        
        _searchDevicesView.center = self.view.center;
        _searchDevicesView.delegate = self;
        
        [self.view addSubview:_searchDevicesView];
    }
    return _searchDevicesView;
}

//倒计时提示
- (UIButton *)countdownBtn {
    if (!_countdownBtn) {
        _countdownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _countdownBtn.frame = CGRectMake(0, 0, 200, 200);
        
        _countdownBtn.center = self.view.center;
        
        _countdownBtn.userInteractionEnabled = NO;
        
        _countdownBtn.backgroundColor = [UIColor clearColor];
        
        _countdownBtn.alpha = 0.7;
        
        [_countdownBtn setTitleColor:[UIColor whiteColor] forState:0];
        
        _countdownBtn.titleLabel.font = [UIFont systemFontOfSize:150.0f];
        
        [self.view addSubview:_countdownBtn];
        
        [self screenRotate:nil];
    }
    return _countdownBtn;
}

- (AVCaptureDeviceInput *)captureDeviceInput{
    
    if (!_captureDeviceInput) {
        
        AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
        
        _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:nil];
        
        // 保存默认的AVCaptureDeviceFormat
        _defaultFormat = captureDevice.activeFormat;
        _defaultMinFrameDuration = captureDevice.activeVideoMinFrameDuration;
        _defaultMaxFrameDuration = captureDevice.activeVideoMaxFrameDuration;
        
    }
    return _captureDeviceInput;
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

#pragma mark - SET
//前置状态
- (void)setIsFrontCamera:(BOOL)isFrontCamera {
    if (_islensSwitching) {
        return;
    }
    
    if (_isSubShowing == YES) {
        self.isSubShowing = NO;
    }
    
    _islensSwitching = YES;
    if (isFrontCamera) {
        if ([_stillCamera cameraPosition] == AVCaptureDevicePositionBack) {
            [_stillCamera rotateCamera];
        }
    }
    else {
        if ([_stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
            [_stillCamera rotateCamera];
        }
    }
    _islensSwitching = NO;
    
    _isFrontCamera = isFrontCamera;
    
    //清空追踪状态
    if (_middleToolBar.trackStay.isSelected) {
        _middleToolBar.trackStay.selected = NO;
        [self cleanTrackState];
    }
}

//滤镜菜单
- (void)setIsFilterShowing:(BOOL)isFilterShowing {
    if (_isCameraSetting == YES) {
        self.isCameraSetting = NO;
        [_cameraSettingView cleanCameraSettingOption];
    }
    if (_isDeviceSetting == YES) {
        self.isDeviceSetting = NO;
    }
    self.middleToolBar.hidden = isFilterShowing;
    self.filterSubView.hidden = !isFilterShowing;
    _isFilterShowing = isFilterShowing;
    
}

- (UIView *)filterSubView {
    if(_filterSubView == nil){
        
        _filterSubIconView = [[SR360CamFilterView alloc]initWithFrame:CGRectMake(0, _topToolBar.toolBar.frame.size.height, WIDTH, FILTER_SUB_HEIGHT)];
        _filterSubIconView.delegate = self;
        _filterSubView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, _topToolBar.toolBar.frame.size.height + FILTER_SUB_HEIGHT)];
        _filterSubView.hidden = YES;
        _filterSubView.backgroundColor = [UIColor blackColor];
        [_filterSubView addSubview:_filterSubIconView];
        _filterSubView.hidden = YES;
        
        [self.view insertSubview:_filterSubView belowSubview:_topToolBar];
    }
    
    return _filterSubView;
}

//美颜
- (void)setIsBeautyOpening:(BOOL)isBeautyOpening {
    if (_isFilterShowing) {
        self.isFilterShowing = NO;
    }
    if (_topToolBar.filterToolButton.isSelected) {
        [_filterSubIconView collectionView:_filterSubIconView.containView didSelectItemAtIndexPath:0];  //恢复成原图
    }
    
    [_stillCamera pauseCameraCapture];
    [_stillCamera removeAllTargets];
    if (isBeautyOpening) {
        [_stillCamera addTarget:self.beautyFilter];
        [self.beautyFilter addTarget:_cameraOutputView];
        [_stillCamera resumeCameraCapture];
        
        self.captureFilter = _beautyFilter;
    }
    else {
        [_cameraFilter removeAllTargets];
        [_stillCamera addTarget:_cameraFilter];
        [_cameraFilter addTarget:_cameraOutputView];
        [_stillCamera addTarget:self.normalFilter];
        [_stillCamera resumeCameraCapture];
        
        self.captureFilter = _cameraFilter;
    }
    _topToolBar.beautyToolButton.selected = isBeautyOpening;
    _isBeautyOpening = isBeautyOpening;
}
//美颜滤镜
- (DotGPUImageBeautyFilter *)beautyFilter {
    if (_beautyFilter == nil) {
        _beautyFilter = [DotGPUImageBeautyFilter new];
        _beautyFilter.isVertical = YES;
    }
    return _beautyFilter;
}

//相机设置菜单
- (void)setIsCameraSetting:(BOOL)isCameraSetting {
    if (_isFilterShowing == YES) {
        self.isFilterShowing = NO;
    }
    if (_isDeviceSetting == YES) {
        self.isDeviceSetting = NO;
    }
    if (isCameraSetting) {
        [_cameraSettingView cleanCameraSettingOption];
    }
    else {
        
    }
    self.topToolBarBlackView.hidden = !isCameraSetting;
    self.cameraSettingView.hidden   = !isCameraSetting;
    self.middleToolBar.hidden       = isCameraSetting;
    _cameraSettingView.settingMode  = cameraSetting;
    _cameraSettingView.settingArray = self.cameraSettingArray;
    [_cameraSettingView.tableView reloadData];
    _topToolBar.cameraSetToolButton.selected = isCameraSetting;
    _isCameraSetting = isCameraSetting;
}
- (UIView *)topToolBarBlackView {
    if (!_topToolBarBlackView) {
        _topToolBarBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _topToolBar.frame.size.width, _topToolBar.frame.size.height)];
        _topToolBarBlackView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:_topToolBarBlackView belowSubview:_topToolBar];
    }
    return _topToolBarBlackView;
}
- (JECameraSettingView *)cameraSettingView {
    if (!_cameraSettingView) {
        _cameraSettingView = [[JECameraSettingView alloc] initWithFrame:CGRectMake(0, _topToolBar.frame.size.height, _topToolBar.frame.size.width, HEIGHT/2)];
        _cameraSettingView.delegate = self;
        NSLog(@"_videoResolutionArray = %@", _videoResolutionArray);
        _cameraSettingView.videoResolutionArray = self.videoResolutionArray;
        
        if (_mainRotate != 0) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(_mainRotate);
            [_cameraSettingView setTransform:transform];
            [self resetSettingViewFrame];
        }
        [self resetSettingViewUIRotate:_mainRotate];
        
        [self.view insertSubview:_cameraSettingView belowSubview:_topToolBar];
    }
    return _cameraSettingView;
}

//设备设置菜单
- (void)setIsDeviceSetting:(BOOL)isDeviceSetting {
    if (_isFilterShowing == YES) {
        self.isFilterShowing = NO;
    }
    if (_isCameraSetting == YES) {
        self.isCameraSetting = NO;
        [_cameraSettingView cleanCameraSettingOption];      //隐藏二级菜单
    }
    self.topToolBarBlackView.hidden = !isDeviceSetting;
    self.cameraSettingView.hidden   = !isDeviceSetting;
    self.middleToolBar.hidden       = isDeviceSetting;
    _cameraSettingView.settingMode  = deviceSetting;
    _cameraSettingView.settingArray = self.deviceSettingArray;
    [_cameraSettingView.tableView reloadData];
    [_cameraSettingView.fPushSpeedPicker reloadAllComponents];
    [_cameraSettingView.hPushSpeedPicker reloadAllComponents];
    _topToolBar.deviceSetToolButton.selected = isDeviceSetting;
    
    if (isDeviceSetting) {
        [[JEBluetoothManager shareBLESingleton] BPGetDeviceVersion];
        NSMutableArray *params = [NSMutableArray array];
        
        if (_controllerMode == cameraM1) {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"ProdID", nil]];
        }
        else if (_controllerMode == cameraP1) {
            [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"ProdID", nil]];
        }
        
        //从服务器获取版本信息
        [JEWebManager loadDataCenter:params methodName:@"SR_GetLastFirmwareInfo" result:^(NSDictionary *resultDic, NSString *error) {
            if (error) {
                
                SHOW_HUD_DELAY(NSLocalizedString(@"Network Error", nil), self.view, 1);
                
                return;
            }
            
            //强制纠正语言
            NSArray *languages = [NSLocale preferredLanguages];
            
            NSString *language = [languages objectAtIndex:0];
            
            NSLog(@"system language = %@", language);
            
            if ([language hasPrefix:@"zh"]) {//检测开头匹配，是否为中文，再决定固件升级内容语言
                self.deviceUpdateString = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"InfoCN"][@"__text"];
            }
            else {
                self.deviceUpdateString = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"InfoEN"][@"__text"];
            }
            
            self.deviceNewVersion = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareInfoResponse"][@"return"][@"__text"];
            USER_SET_SaveVersionNewFirmware_NSString(_deviceNewVersion);
            
        }];
    }
    
    _isDeviceSetting = isDeviceSetting;
}

//拍摄模式菜单
- (void)setIsSubShowing:(BOOL)isSubShowing {
    _bottomToolBar.bottomMenu.subPictureView.hidden = _isVideo;
    _bottomToolBar.bottomMenu.subVideoView.hidden   = !_isVideo;
    
    if (isSubShowing) {
        [UIView animateWithDuration:2 animations:^{
            [_bottomToolBar.toolBar updateBackground:CGRectMake(0, HEIGHT - WIDTH * 0.6, WIDTH, WIDTH * 0.6)];
        }];
    }
    else {
        [UIView animateWithDuration:2 animations:^{
            [_bottomToolBar.toolBar updateBackground:CGRectMake(0, 0, _bottomToolBar.frame.size.width, 75 + 10.f)];
        }];
        _bottomToolBar.bottomMenu.subPictureView.hidden = YES;
        _bottomToolBar.bottomMenu.subVideoView.hidden = YES;
    }
    _isSubShowing = isSubShowing;
}

//录像状态
- (void)setIsVideo:(BOOL)isVideo {
    if (_isSubShowing == YES) {
        self.isSubShowing = NO; //收回菜单
    }
    if (_isFilterShowing == YES) {
        self.isFilterShowing = NO;
    }
    if (_isCameraSetting == YES) {
        self.isCameraSetting = NO;
        [_cameraSettingView cleanCameraSettingOption];
    }
    if (_isDeviceSetting == YES) {
        self.isDeviceSetting = NO;
    }
    
    if (isVideo) {
        //录制模式
        [_bottomToolBar.cameraButton setImage:[UIImage imageNamed:@"icon_shoot_video"] forState:UIControlStateNormal];
        //更改菜单键图标
        [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subVideoNormal];
    }
    else {
        //拍照模式
        [_bottomToolBar.cameraButton setImage:[UIImage imageNamed:@"icon_shoot_camera"] forState:UIControlStateNormal];
        [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicSingleNormal];
    }
    _isVideo = isVideo;
}

//自定义功能菜单
- (void)setIsFunctionShowing:(BOOL)isFunctionShowing {
    if (_isCameraSetting == YES) {
        self.isCameraSetting = NO;
        [_cameraSettingView cleanCameraSettingOption];
    }
    if (_isDeviceSetting == YES) {
        self.isDeviceSetting = NO;
    }
    if (_isFilterShowing == YES) {
        self.isFilterShowing = NO;
    }
    if (_isSubShowing == YES) {
        self.isSubShowing = NO;
    }
    
    self.isClearViewShowing = isFunctionShowing;
    if (isFunctionShowing) {
        self.customFunctionView.hidden = !isFunctionShowing;
        [UIView animateWithDuration:CUSTOM_ANIMATE_TIME animations:^{
            _customFunctionView.center = self.view.center;
        }];
    }
    else {
        [UIView animateWithDuration:CUSTOM_ANIMATE_TIME animations:^{
            _customFunctionView.center = CGPointMake(-self.view.frame.size.width/2, self.view.frame.size.height/2);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CUSTOM_ANIMATE_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.customFunctionView.hidden = !isFunctionShowing;
        });
    }
    _isFunctionShowing = isFunctionShowing;
}
- (JECustomFunctionView *)customFunctionView {
    if (!_customFunctionView) {
        _customFunctionView = [[JECustomFunctionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, self.view.frame.size.width - 150)];
        _customFunctionView.delegate = self;
        _customFunctionView.center = CGPointMake(-self.view.frame.size.width/2, self.view.frame.size.height/2);
        [self.view insertSubview:_customFunctionView aboveSubview:_clearBackView];
        [self screenRotate:nil];
    }
    return _customFunctionView;
}

//透明屏蔽 view
- (void)setIsClearViewShowing:(BOOL)isClearViewShowing {
    self.clearBackView.hidden = !isClearViewShowing;
    _isClearViewShowing = isClearViewShowing;
}
- (UIView *)clearBackView {
    if (!_clearBackView) {
        _clearBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _clearBackView.backgroundColor = [UIColor blackColor];
        _clearBackView.alpha = 0.3;
        [self.view addSubview:_clearBackView];
    }
    return _clearBackView;
}

//移动延时菜单
- (void)setIsMotionLapseShowing:(BOOL)isMotionLapseShowing {
    if (isMotionLapseShowing) {
        //进入移动延时模式
        [[JEBluetoothManager shareBLESingleton] BPEnterMotionLapseMode];
    }
    else {
        
    }
    self.motionLapsePopView.hidden = !isMotionLapseShowing;
    _isMotionLapseShowing = isMotionLapseShowing;
}
- (JEVideoLocusTimeLapseView *)motionLapsePopView {
    if (!_motionLapsePopView) {
        _motionLapsePopView = [[JEVideoLocusTimeLapseView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, self.view.frame.size.width)];
        _motionLapsePopView.center = self.view.center;
        _motionLapsePopView.delegate = self;
        [self.view addSubview:_motionLapsePopView];
        [self screenRotate:nil];
    }
    return _motionLapsePopView;
}

//普通延时菜单
- (void)setIsTimeLapseShowing:(BOOL)isTimeLapseShowing {
    self.timeLapsePopView.hidden = !isTimeLapseShowing;
    _isTimeLapseShowing = isTimeLapseShowing;
}
- (JEVideoTimeLapseView *)timeLapsePopView {
    if (!_timeLapsePopView) {
        _timeLapsePopView = [[JEVideoTimeLapseView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        _timeLapsePopView.center = self.view.center;
        [self.view addSubview:_timeLapsePopView];
        [self screenRotate:nil];
    }
    return _timeLapsePopView;
}

//跟踪状态
- (void)setIsFaceTracking:(BOOL)isFaceTracking {
    _isFaceTracking = isFaceTracking;
    
    [_stillCamera.captureSession beginConfiguration];
    if (isFaceTracking) {
        //开始跟踪
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [[JEBluetoothManager shareBLESingleton] BPEnterFaceTracking];   //发送进入人脸跟踪指令
        if ([_stillCamera.captureSession canAddOutput:_metaDataOutput]) {
            [_stillCamera.captureSession addOutput:_metaDataOutput];
            
            NSArray *supportTypes = _metaDataOutput.availableMetadataObjectTypes;
            
            dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
            
            if ([supportTypes containsObject:AVMetadataObjectTypeFace]) {   //还可以添加譬如二维码
                //将人脸识别添加进去
                [_metaDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
                [_metaDataOutput setMetadataObjectsDelegate:_stillCamera queue:videoProcessingQueue];
            }
        }
        
        for(UIView *view in _faceFramesArray){
            view.hidden = NO;
        }
        
        //调整自动对焦和白平衡
        NSError *err;
        
        [self.stillCamera.inputCamera lockForConfiguration:&err];
        
        if(!err){
            if([self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
                [self.stillCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            
            if([self.stillCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]){
                [self.stillCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            
            if([self.stillCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
                [self.stillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [self.stillCamera.inputCamera unlockForConfiguration];
        }
         
    }
    else {
        //停止跟踪
        for(UIView *view in _faceFramesArray){
            view.hidden = YES;
        }
        [_stillCamera.captureSession removeOutput:_metaDataOutput];
        //移除人脸框
        [self removeFaceFocusView];
        [_cameraOutputView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [[JEBluetoothManager shareBLESingleton] BPQuitFaceTracking];    //退出跟踪
    }
    [_stillCamera.captureSession commitConfiguration];
}

- (void)setIsObjectTracking:(BOOL)isObjectTracking {
    //如果在 移动延时 && 移动变焦 模式，不允许跟踪
    if (_shootingMode == videoLocusTimeLapse || _shootingMode == videoMovingZoom) {
        SHOW_HUD_DELAY(NSLocalizedString(@"Tracking will not function in the current mode", nil), [UIApplication sharedApplication].keyWindow, 1);
        return;
    }
    
    if (isObjectTracking) {
        
    }
    else {
        if (_isObjectTracking) {
            [[JEBluetoothManager shareBLESingleton] BPQuitFaceTracking];    //退出跟踪
        }
    }
    
    if (_objectTrackingView.isHidden) {
        _objectTrackingView.frame = CGRectMake(0, 0, 0, 0);
        _objectTrackingView.layer.borderColor = MAIN_TEXT_COLOR.CGColor;
    }
    _objectTrackingView.hidden = !isObjectTracking;
    _isObjTrackStart = NO;
    _trackViewLTPoint = CGPointZero;    //初始化跟踪框的坐标
    _trackViewRDPoint = CGPointZero;
    
    _isObjectTracking = isObjectTracking;
    
}

//全景合成中
- (void)setIsAutoStitchPanoing:(BOOL)isAutoStitchPanoing {
    if (isAutoStitchPanoing) {
        [self setNeedsStatusBarAppearanceUpdate];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"panoWaitingView2" owner:self options:nil];
        _panoWaitingView = [nib objectAtIndex:0];
        
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                              M_PI_2);
        
        _panoWaitingView.transform = transform;
        _panoWaitingView.frame = self.view.frame;
        
        
        DGActivityIndicatorView *indicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeTriangleSkewSpin tintColor:[UIColor whiteColor]];
        indicatorView.size = 100;
        
        indicatorView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width*0.2, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width*0.5);
        
        [_panoWaitingView addSubview:indicatorView];
        [indicatorView startAnimating];
        
        _panoProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(_panoWaitingView.frame.size.height*0.2, indicatorView.frame.size.height + indicatorView.frame.origin.y, _panoWaitingView.frame.size.height*0.6, 20)];
        _panoProgressView.progress = 0.0;
        _panoProgressView.progressTintColor = [UIColor whiteColor];
        _panoProgressView.trackTintColor = [UIColor darkGrayColor];
        [_panoWaitingView addSubview:_panoProgressView];
        
        _panoHint = [[UILabel alloc] initWithFrame:CGRectMake(_panoWaitingView.frame.size.height*0.2, _panoProgressView.frame.size.height + _panoProgressView.frame.origin.y, [UIScreen mainScreen].bounds.size.height, 60)];
        _panoHint.backgroundColor = [UIColor clearColor];
        _panoHint.textColor = [UIColor whiteColor];
        _panoHint.text = NSLocalizedString(@"Pano starting...", nil);
        _panoHint.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        _panoHint.textAlignment = NSTextAlignmentLeft;
        [_panoWaitingView addSubview:_panoHint];
        
        [self.view addSubview:_panoWaitingView];
    }
    else {
        [_panoWaitingView removeFromSuperview];
        _panoWaitingView = nil;
        
        [self.panoImagesArray removeAllObjects];
        self.panoImagesArray = nil;
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - UI
- (void)setupUI {
    //相机 View
    [self setupStillCamera];
    
    //屏幕单击 聚焦和曝光
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(cameraOutputViewTapAction:)];
    [_cameraOutputView addGestureRecognizer:tap];
    
    //工具栏
    [self setupTopToolBar];
    [self setupMiddleToolBar];
    [self setupBottomToolBar];
    
    self.preLayer = [AVCaptureVideoPreviewLayer layerWithSession: _stillCamera.captureSession];
    self.preLayer.frame = [UIScreen mainScreen].bounds;
    self.preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preLayer.hidden = YES;
    [self.view.layer addSublayer:self.preLayer];
    
    if ([JEBluetoothManager shareBLESingleton].getBLEState == Connect) {
        _middleToolBar.bluetoothSign.selected = YES;
    }
    else {
        _middleToolBar.bluetoothSign.selected = NO;
    }
    
    //变焦对焦
    _focusingView = [[SRFocusingView alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height-300, 120, 120)];
    _focusingView.center = self.view.center;
    _focusingView.hidden = YES;
    _focusingView.backgroundColor = [UIColor clearColor];
    _focusingView.transform = [MotionOrientation sharedInstance].affineTransform;
    _focusingView.slider.labelAboveThumb.hidden = YES;
    [self.view addSubview:_focusingView];
    
    _zoomSliderView = [[SliderView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, (self.view.frame.size.height-300)/2, 8, 300)];
    _zoomSliderView.hidden = YES;
    [self.view addSubview:_zoomSliderView];
    
}

- (void)adjustUI {
    if (_controllerMode == cameraP1) {
        //三轴微单稳定器
        /*
         1.隐藏 美颜 & 滤镜 & 相机设置
         2.隐藏 拍摄模式转换按钮，默认视频模式
         3.隐藏 前后置摄像头切换按钮
         4.隐藏 延时拍摄 & 移动变焦
         5.保留 轨迹延时 名称改为 轨迹拍摄
         6.保留 追踪
         7.保留 快门按钮，但是需要屏蔽拍照事件，只保留移动延时的启动功能
         */
        
        [self.topToolBar.beautyToolButton removeFromSuperview];
        [self.topToolBar.filterToolButton removeFromSuperview];
        [self.topToolBar.cameraSetToolButton removeFromSuperview];
        [self.bottomToolBar.shootSwitchButton removeFromSuperview];
        [self.bottomToolBar.lensSwitchButton removeFromSuperview];
        [self.bottomToolBar.bottomMenu.subVideoMovingZoom removeFromSuperview];
        [self.bottomToolBar.bottomMenu.subVideoTimeLapse removeFromSuperview];
        [self bottomToolBarButtonAction:222];   //默认视频模式
        [self.bottomToolBar.bottomMenu.subVideoLocusTimeLapse setTitle:NSLocalizedString(@"Path Shoot", nil) forState:UIControlStateNormal];
        
        //调整 frame
        self.bottomToolBar.subBottomButton.center = CGPointMake((self.bottomToolBar.frame.size.width - 75)/4, self.bottomToolBar.cameraButton.center.y);
        self.bottomToolBar.albumButton.center = CGPointMake(self.bottomToolBar.frame.size.width - (self.bottomToolBar.frame.size.width - 75)/4, self.bottomToolBar.cameraButton.center.y);
        self.bottomToolBar.bottomMenu.subVideoNormal.center = CGPointMake(self.bottomToolBar.frame.size.width/4, self.bottomToolBar.bottomMenu.subVideoNormal.center.y);
        self.bottomToolBar.bottomMenu.subVideoLocusTimeLapse.center = CGPointMake(self.bottomToolBar.frame.size.width/4*3, self.bottomToolBar.bottomMenu.subVideoLocusTimeLapse.center.y);
    }
}

#pragma mark - DATA
- (void)loadData {
    _islensSwitching    = NO;
    _isSubShowing       = NO;
    
    self.mainFrameWidth = self.view.frame.size.width;
    self.mainFrameHeight = self.view.frame.size.height;
    
    //对焦变焦初始化
    currValue = 0.5;
    
    //蓝牙搜索设备数据初始化
    self.bluetoothDeviceArray = [[NSMutableArray alloc] init];
    
    //蓝牙数据参数包字符串初始化
    self.blueParameterString = [[NSString alloc] init];
    
    //设置列表数据初始化
    self.cameraSettingArray = @[@{@"name":@"Grid Line",        @"type":@"yes"},
                                @{@"name":@"Flash",            @"type":@"yes"},
                                @{@"name":@"Video Resolution", @"type":@"yes"},
                                @{@"name":@"Film Camera",      @"type":@"no"}];
    
    self.deviceSettingArray = @[
//                                @{@"name":@"Push speed(pan)",           @"type":@"no"},
//                                @{@"name":@"Push speed(tilt)",          @"type":@"no"},
                                @{@"name":@"Allow the Gimbal to function while charging", @"type":@"no"},
                                @{@"name":@"Reverse Tilting Motion",    @"type":@"no"},
                                @{@"name":@"Acceleration Calibration",  @"type":@"yes"},
                                @{@"name":@"Firmware Version",          @"type":@"no"},
                                @{@"name":@"Hardware Version",          @"type":@"no"},
                                @{@"name":@"Bluetooth Version",         @"type":@"no"},
                                @{@"name":@"APP Version",               @"type":@"no"}];
    
    //人脸跟踪数据初始化
    _faceFramesArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    for(int i = 0; i < 10; i++){
        JETrackingView *trackingView = [[JETrackingView alloc] initWithFrame:CGRectZero];
        trackingView.backgroundColor = [UIColor clearColor];
        trackingView.hidden = YES;
        [self.view addSubview:trackingView];
        [_faceFramesArray addObject:trackingView];
    }
    
    //拍摄模式初始化
    self.shootingMode = picSingle;
    
    //移动延时关键点图片数据初始化
    self.motionLapsePointArray = [[NSMutableArray alloc] init];
    
    //注册全景通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(panoprogress:) name:PANO_PROGRESS object:nil];
    
    //延时 GCD 信号量
    _seam = dispatch_semaphore_create(0);
    
    //自定义功能数组初始化
    self.customFunctionArray = @[@"Cam SWTCH",          //前后置摄像头切换
                                 @"Mod SWTCH",          //视频或拍照模式切换
                                 @"Flash",              //闪光灯开关
                                 @"Facial",             //美颜功能开关
                                 @"Filter",             //启动滤镜开关
                                 @"F - Track",          //启动或关闭人脸追踪
                                 @"X - Track",          //启动或关闭对象追踪
                                 @"PAN 90",             //启动 90 度全景拍摄
                                 @"PAN 180",            //启动 180 度全景拍摄
                                 @"PAN 360",            //启动 360 度全景拍摄
                                 @"Sudoku 1",           //启动九宫格拍摄 - 模式 1
                                 @"Sudoku 2",           //启动九宫格拍摄 - 模式 2
                                 @"Hitchcock",          //启动移动变焦拍摄
//                                 @"Slow MOV",           //启动慢动作拍摄
                                 @"Timelapse",          //启动延时拍摄
                                 @"Path TMLP",          //启动轨迹延时拍摄
                                 @"Wide Shot"];         //启动 3x3 超广角全景拍摄
    
    //相机权限请求 && 麦克风权限请求
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
    }];
    
    //固件升级回执计数初始化
    self.updateFirmwareTimeCount = 0;
    
}

//本地化数据初始化
- (void)checkUserDefaultData {
    //普通延时时间比例设置
    if (USER_GET_SaveTimelapseProportion_Interger == 0) {
        USER_SET_SaveTimelapseProportion_Integer(1);
    }
    //设备固件硬件版本
    USER_SET_SaveVersionFirmware_NSString(NULL);
    USER_SET_SaveVersionHardware_NSString(NULL);
    USER_SET_SaveVersionBluetooth_NSString(NULL);
    
    //电影镜头
    USER_SET_SaveFilmCameraState_BOOL(NO);
    
    //设备充电设置
    USER_SET_SaveChargingSwitchState_BOOL(NO);
    
    //移动方向设置
    USER_SET_SavePitchOrientationOpposite_BOOL(NO);
    
    //稳定器推动速度
    USER_SET_SaveAxisPushSpeed_Interger(NULL);
    USER_SET_SavePitchPushSpeed_Interger(NULL);
    
    //自定义功能的数组判断
    if (USER_GET_SaveFunctionMode_Integer >= _customFunctionArray.count - 1) {
        USER_SET_SaveFunctionMode_Integer(0);
    }
    
    //视频分辨率数组判断
    if (USER_GET_SaveVideoResolution_Integer >= _videoResolutionArray.count) {
        USER_SET_SaveVideoResolution_Integer(_videoResolutionArray.count - 1);
    
    }
}

#pragma mark - StillCamera && VideoCamera && FilmCamera
- (void)setupStillCamera {
    //预览 View
    self.cameraOutputView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _cameraOutputView.userInteractionEnabled    = YES;
    _cameraOutputView.fillMode                  = kGPUImageFillModePreserveAspectRatioAndFill;  //保持源图像的纵横比，放大其中心以填充视图
//    _cameraOutputView.center = self.view.center;
    [self.view addSubview:_cameraOutputView];
    
    //创建滤镜
    self.cameraFilter = [[GPUImageFilter alloc] init];
    
    //创建 Camera
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];  //初始化相机，默认为后置摄像头
    _stillCamera.outputImageOrientation                 = UIInterfaceOrientationPortrait;   //此处接入相机方向的接口
    _stillCamera.horizontallyMirrorFrontFacingCamera    = YES;                              //初始化镜像情况，仅前置为镜像
    _stillCamera.horizontallyMirrorRearFacingCamera     = NO;
    _stillCamera.delegate = self;
    
    //添加
    [_stillCamera   addTarget:_cameraFilter];
    [_cameraFilter  addTarget:_cameraOutputView];
    
    //光学防抖
    [self setVideoStabilizationMode];
    
    //开始捕获
    [_stillCamera startCameraCapture];
}

- (void)setupFilmCamera {
    [_stillCamera stopCameraCapture];
    
    self.cameraOutputView.frame = CGRectMake((_mainFrameWidth - _mainFrameWidth/_filmRatio)/2.0, 0, _mainFrameWidth/_filmRatio, _mainFrameHeight);
    _cameraOutputView.fillMode = kGPUImageFillModeStretch;
    
    [_stillCamera startCameraCapture];
}

- (void)resetStillCamera {
    
    [_stillCamera stopCameraCapture];
    
    self.cameraOutputView.frame = [UIScreen mainScreen].bounds;
    _cameraOutputView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [_stillCamera startCameraCapture];
}

#pragma mark - ToolBar
/**
 顶部 ToolBar
 */
- (void)setupTopToolBar {
    self.topToolBar = [[JECameraTopToolBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 75) CameraMode:connectXP3];
    
    _topToolBar.delegate = self;
    
    [self.view addSubview:_topToolBar];
}

/**
 中部 Toolbar
 */
- (void)setupMiddleToolBar {
    self.middleToolBar = [[JECameraMiddleToolBar alloc] initWithFrame:CGRectMake(20, 90, WIDTH - 40, 60)];
    
    _middleToolBar.delegate = self;
    
    _middleToolBar.trackStay.hidden = YES;
    
    [self.view addSubview:_middleToolBar];
}

/**
 底部 ToolBar
 */
- (void)setupBottomToolBar {
    self.bottomToolBar = [[JECameraBottomToolBar alloc] initWithFrame:CGRectMake(0, HEIGHT - WIDTH * 0.6, WIDTH, WIDTH * 0.6) CameraMode:bConnectXP3];
    
    _bottomToolBar.delegate = self;
    
    //移动延时暂停按钮
    self.stopTimeLapseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_stopTimeLapseButton setImage:[UIImage imageNamed:@"icon_timeLapse_stop"] forState:UIControlStateNormal];
    [_stopTimeLapseButton setImage:[UIImage imageNamed:@"icon_timeLapse_start"] forState:UIControlStateSelected];
    [_stopTimeLapseButton addTarget:self action:@selector(stopOrStartTimeLapseDevice) forControlEvents:UIControlEventTouchUpInside];
    _stopTimeLapseButton.hidden = YES;
    _stopTimeLapseButton.center = CGPointMake(WIDTH/4*3, _bottomToolBar.toolBar.center.y-10);
//    [_bottomToolBar addSubview:_stopTimeLapseButton];
    

    [self.view addSubview:_bottomToolBar];
}

#pragma mark - Action
//单击屏幕 聚焦曝光
- (void)cameraOutputViewTapAction:(UITapGestureRecognizer *)sender {
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    
    CGPoint tp = [tap locationInView:_cameraOutputView];
    
    CGPoint interesPoint = CGPointMake(tp.y/_cameraOutputView.bounds.size.height, 1.0-tp.x/_cameraOutputView.bounds.size.width);
    
    //对焦和曝光
    [self intresPointOfFocusAndExplosure:interesPoint];
    
    _focusingView.alpha = 1;
    
    _focusingView.slider.hidden = YES;
    
    _focusingView.hidden = NO;
    
    _focusingView.center = tp;
    
    currValue = 0.5;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_focusingView.slider setValue:currValue];
       
    });
    
    //延时后执行方法
    [self performSelector:@selector(hiddenFocuseView) withObject:nil afterDelay:4];
    
}

//隐藏曝光和聚焦 并设置为自动曝光和聚焦
- (void)hiddenFocuseView{
    
    
    _focusingView.slider.hidden = NO;
    
    _focusingView.hidden = YES;
    
    [self resetFocusAndExposureModes];
}

//旋转图标动画
- (void)screenRotate:(NSNotification *)notify {
    
    UIInterfaceOrientation orientation = [MotionOrientation sharedInstance].interfaceOrientation;
    
    self.transform = [MotionOrientation sharedInstance].affineTransform;
    
    CGFloat rotate = 0;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait: {
            //竖屏
            rotate = 0;
            if (_isFrontCamera) {
                self.imageOrientation = UIImageOrientationUpMirrored;
            }
            else {
                self.imageOrientation = UIImageOrientationUp;
            }
        }
            break;
            
        case UIInterfaceOrientationLandscapeLeft: {
            //向左横屏
            rotate = M_PI_2;
            if (_isFrontCamera) {
                self.imageOrientation = UIImageOrientationLeftMirrored;
            }
            else {
                self.imageOrientation = UIImageOrientationLeft;
            }
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight: {
            //向右横屏
            rotate = - M_PI_2;
            if (_isFrontCamera) {
                self.imageOrientation = UIImageOrientationRightMirrored;
            }
            else {
                self.imageOrientation = UIImageOrientationRight;
            }
        }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown: {
            //倒的竖屏
            rotate = 0;
            if (_isFrontCamera) {
                self.imageOrientation = UIImageOrientationDownMirrored;
            }
            else {
                self.imageOrientation = UIImageOrientationDown;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    self.mainRotate = rotate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _focusingView.transform = _transform;
    });
    
    POPBasicAnimation *ani = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    ani.toValue = [NSNumber numberWithFloat:rotate];
    ani.duration = 0.5;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //顶部按钮
        for (UIButton *subBtn in _topToolBar.toolBar.subviews) {
            
            [subBtn.layer pop_addAnimation:ani forKey:Rotation_Key];
        }
        
        for (UIView *subView in self.view.subviews) {
            //顶部的设置菜单
            if ([subView isKindOfClass:[JECameraSettingView class]]) {
                //底 view 不旋转，但是告知 view 改变 frame
                CGAffineTransform transform = CGAffineTransformMakeRotation(rotate);
                [subView setTransform:transform];
        
                [self resetSettingViewFrame];
                if (_cameraSettingView) {
                    [self resetSettingViewUIRotate:_mainRotate];
                }
                [_cameraSettingView.tableView reloadData];
            }
            //滤镜菜单
            if ([subView isKindOfClass:[_filterSubView class]]) {
                for (UIView *subView2 in subView.subviews) {
                    if ([subView2 isKindOfClass:[SR360CamFilterView class]]) {
                        //更新下列表数据就可以了，因为里面写有滤镜方向方法
                        [_filterSubIconView.containView reloadData];
                    }
                }
            }
            //倒计时按钮
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            //自定义功能菜单
            if ([subView isKindOfClass:[JECustomFunctionView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            //固件升级
            if ([subView isKindOfClass:[JEUpdateFirmwareView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            //移动延时
            if ([subView isKindOfClass:[JEVideoLocusTimeLapseView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            //普通延时
            if ([subView isKindOfClass:[JEVideoTimeLapseView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            //视频计时 label
            if ([subView isKindOfClass:[UILabel class]]) {
                CGAffineTransform transform = CGAffineTransformMakeRotation(rotate);
                [subView setTransform:transform];
                if (rotate == 0) {
                    _videoTimeLB.frame = CGRectMake(0, 60, self.view.frame.size.width, 40);
                }
                else {
                    _videoTimeLB.frame = CGRectMake(self.view.frame.size.width - 60, 0, 40, self.view.frame.size.height);
                }
            }
            //搜索蓝牙设备列表
            if ([subView isKindOfClass:[JESearchDevicesView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            
        }
        //跟踪按钮
        for (UIView *subView in _middleToolBar.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
            for (UIView *sub in _middleToolBar.trackView.subviews) {
                if ([sub isKindOfClass:[UIButton class]]) {
                    [sub.layer pop_addAnimation:ani forKey:Rotation_Key];
                }
            }
        }
        //底部按钮
        for (UIView *subView in _bottomToolBar.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.toolBar.subviews) {
            if ([subView isKindOfClass:[UIButton class]] || [subView isKindOfClass:[UIImageView class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.bottomMenu.subPictureView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.bottomMenu.subPicSingleView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.bottomMenu.subPicPanoView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.bottomMenu.subPicNLView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
        for (UIView *subView in _bottomToolBar.bottomMenu.subVideoView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [subView.layer pop_addAnimation:ani forKey:Rotation_Key];
            }
        }
    });
}

//设置页面的 frame 设置
- (void)resetSettingViewFrame {
    _cameraSettingView.frame = CGRectMake(0, _topToolBar.frame.size.height, _topToolBar.frame.size.width, HEIGHT/2);
}

- (void)resetSettingViewUIRotate:(CGFloat)rotate {
    if (rotate == 0) {
        [_cameraSettingView resetUISize:CGSizeMake(_topToolBar.frame.size.width, HEIGHT/3)];
    }
    else {
        [_cameraSettingView resetUISize:CGSizeMake(HEIGHT/2, _topToolBar.frame.size.width)];
    }
}

//消除人脸框
- (void)removeFaceFocusView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[JEFaceFocusView class]]) {
                [view removeFromSuperview];
            }
        }
    });
}

/**
 快门事件
 */
- (void)camStillAction {
    NSLog(@"当前拍摄模式是 = %d", _shootingMode);
    
    if (_controllerMode == cameraP1) {
        if (_isVideo) {
            if (_bottomToolBar.cameraButton.isSelected) {
                switch (_shootingMode) {
                    case videoLocusTimeLapse:
                    {
                        [self takeVideoWithMode:videoLocusTimeLapse];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                switch (_shootingMode) {
                    case videoLocusTimeLapse:
                    {
                        self.timeLapseProgress = (int)_motionLapsePopView.timeScale * 2;
                        [self takeVideoWithMode:videoLocusTimeLapse];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
        
        return;
    }
    
    if (_isVideo) {
        //录像模式
        if (_bottomToolBar.cameraButton.isSelected) {
            //停止录像
            switch (_shootingMode) {
                case videoSlowMotion:
                    [self takeVideoWithMode:videoSlowMotion];
                    break;
                    
                case videoTimeLapse:
                    [self takeVideoWithMode:videoTimeLapse];
                    break;
                    
                case videoLocusTimeLapse:
                    [self takeVideoWithMode:videoLocusTimeLapse];
                    break;
                    
                default:
                {
                    [self takeVideo:NO];
                }
                    break;
            }
        }
        else {
            //开始录像
            switch (_shootingMode) {
                case videoNormal:
                {
                    [self takeVideo:YES];
                }
                    break;
                    
                case videoMovingZoom:
                {
                    [self takeVideoWithMode:videoMovingZoom];
                }
                    break;
                    
                case videoSlowMotion:
                {
                    [self takeVideoWithMode:videoSlowMotion];
                }
                    break;
                    
                case videoLocusTimeLapse:
                {
                    self.timeLapseProgress = (int)_motionLapsePopView.timeScale * 2;
                    [self takeVideoWithMode:videoLocusTimeLapse];
                }
                    break;
                    
                case videoTimeLapse:
                {
                    self.timeLapseProgress = (int)USER_GET_SaveTimelapseProportion_Interger * 15 * 2;
                    [self takeVideoWithMode:videoTimeLapse];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    else {
        //拍照模式
        switch (_shootingMode) {
            case picSingle:
            {
                [self takePhoto];
            }
                break;
                
            case picSingleDelay1s:
            {
                [self takePhotoDelay:1];
            }
                break;
                
            case picSingleDelay2s:
            {
                [self takePhotoDelay:2];
            }
                break;
                
            case picSingleDelay3s:
            {
                [self takePhotoDelay:3];
            }
                break;
                
            case picSingleDelay4s:
            {
                [self takePhotoDelay:4];
            }
                break;
                
            case picSingleDelay5s:
            {
                [self takePhotoDelay:5];
            }
                break;
                
            case picSingleDelay10s:
            {
                [self takePhotoDelay:10];
            }
                break;
                
            case picPano90d:
            {
                [self takePhotoWithPano:90];
                [self setPanoModeView:YES];
            }
                break;
                
            case picPano180d:
            {
                [self takePhotoWithPano:180];
                [self setPanoModeView:YES];
            }
                break;
                
            case picPano360d:
            {
                [self takePhotoWithPano:360];
                [self setPanoModeView:YES];
            }
                break;
                
            case picPano3x3:
            {
                [self takePhotoWithPano:270];
                [self setPanoModeView:YES];
            }
                break;
                
            case picNLSquare:
            {
                [self takePhotoWithNineLattice:picNLSquare];
            }
                break;
                
            case picNLRectangle:
            {
                [self takePhotoWithNineLattice:picNLRectangle];
            }
                break;
                
            default:
                break;
        }
    }
}

//延时摄影计时器
- (void)setupTimeLapseTimer {
    //初始化计时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 0.5 * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        _timeLapseCapturing = YES;
    });
    
    _seam = dispatch_semaphore_create(0);
}

//延时摄影暂停键
- (void)stopOrStartTimeLapseDevice {
    _stopTimeLapseButton.selected = !_stopTimeLapseButton.isSelected;
    [[JEBluetoothManager shareBLESingleton] BPStopMotionLapseMode];
}

//更新辅助线 view
- (void)setupAuxLineView {
    if (_auxLineView) {
        [_auxLineView removeFromSuperview];
    }
    switch (USER_GET_SaveAuxLines_Integer) {
        case 0:
            if (_auxLineView) {
                [_auxLineView removeFromSuperview];
            }
            break;
            
        case 1:
            _auxLineView = [[JEAuxLineView alloc] initWithFrame:_cameraOutputView.bounds];
            _auxLineView.auxLineMode = Square;
            [_cameraOutputView addSubview:_auxLineView];
            break;
            
        case 2:
            _auxLineView = [[JEAuxLineView alloc] initWithFrame:_cameraOutputView.bounds];
            _auxLineView.auxLineMode = SquareDiagonal;
            [_cameraOutputView addSubview:_auxLineView];
            break;
            
        case 3:
            _auxLineView = [[JEAuxLineView alloc] initWithFrame:_cameraOutputView.bounds];
            _auxLineView.auxLineMode = CenterPoint;
            [_cameraOutputView addSubview:_auxLineView];
            break;
            
        default:
            break;
    }
}

/**
 程序智能退出后保存现有拍摄内容
 */
- (void)smartQuitCamera {
    //全景拍摄中，给设备发退出全景模式，并结束全景，不进入全景合成，直接删除全景数组和退出全景模式
    [[JEBluetoothManager shareBLESingleton] BPQuitPano];
    self.isPanoing = NO;
    
    [self setPanoModeView:NO];
    [[NSFileManager defaultManager] removeItemAtPath:[FileUtils panoDir]  error:nil];
    [self.panoImagesArray removeAllObjects];
    self.panoImagesArray = nil;
}

//推动速度发送参数包
- (void)sendBlueBagFirst {
    _blueParameterTimes = 1;
    NSString *blueData = [_blueParameterString substringWithRange:NSMakeRange(0, 38)];
    
    [[JEBluetoothManager shareBLESingleton] sendMsg:[self convertHexStrToData:blueData]];
    
    NSLog(@"第一包数据发送完毕");
}

- (void)sendBlueBagSecond {
    _blueParameterTimes = 2;

    Byte bytes1[17];
    bytes1[0] = 0xff;
    bytes1[1] = 0x32;
    bytes1[2] = 0x0e;
    bytes1[3] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(44, 2)]] intValue];
    bytes1[4] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(46, 2)]] intValue];
    bytes1[5] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(48, 2)]] intValue];
    bytes1[6] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(50, 2)]] intValue];
    bytes1[7] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(52, 2)]] intValue];
    bytes1[8] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(54, 2)]] intValue];
    bytes1[9] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(56, 2)]] intValue];
    bytes1[10] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(58, 2)]] intValue];
    bytes1[11] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(60, 2)]] intValue];
    bytes1[12] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(62, 2)]] intValue];
    bytes1[13] = (USER_GET_SavePitchPushSpeed_Interger + 1) * 5;
    bytes1[14] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(66, 2)]] intValue];
    bytes1[15] = (USER_GET_SaveAxisPushSpeed_Interger + 1) * 5;     //航向轴
    bytes1[16] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(70, 2)]] intValue];
    NSData *data = [NSData dataWithBytes:bytes1 length:17];
    
    Byte bytes[19];
    bytes[0] = 0xff;
    bytes[1] = 0x32;
    bytes[2] = 0x0e;
    bytes[3] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(44, 2)]] intValue];
    bytes[4] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(46, 2)]] intValue];
    bytes[5] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(48, 2)]] intValue];
    bytes[6] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(50, 2)]] intValue];
    bytes[7] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(52, 2)]] intValue];
    bytes[8] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(54, 2)]] intValue];
    bytes[9] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(56, 2)]] intValue];
    bytes[10] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(58, 2)]] intValue];
    bytes[11] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(60, 2)]] intValue];
    bytes[12] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(62, 2)]] intValue];
    bytes[13] = (USER_GET_SavePitchPushSpeed_Interger + 1) * 5;
    bytes[14] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(66, 2)]] intValue];
    bytes[15] = (USER_GET_SaveAxisPushSpeed_Interger + 1) * 5;      //航向轴
    bytes[16] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(70, 2)]] intValue];
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[17] = ck_ab[0];
    bytes[18] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:19];
    
    [[JEBluetoothManager shareBLESingleton] sendMsg:msg];
    
    NSLog(@"第二包数据 %@", msg);
}

- (void)sendBlueBagThird {
    _blueParameterTimes = 3;
    
    Byte bytes1[7];
    bytes1[0] = 0xff;
    bytes1[1] = 0x33;
    bytes1[2] = 4;
    bytes1[3] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(82, 2)]] intValue];
    bytes1[4] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(84, 2)]] intValue];
    bytes1[5] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(86, 2)]] intValue];
    bytes1[6] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(88, 2)]] intValue];
    NSData *data = [NSData dataWithBytes:bytes1 length:7];
    
    Byte bytes[9];
    bytes[0] = 0xff;
    bytes[1] = 0x33;
    bytes[2] = 4;
    bytes[3] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(82, 2)]] intValue];
    bytes[4] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(84, 2)]] intValue];
    bytes[5] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(86, 2)]] intValue];
    bytes[6] = [[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(88, 2)]] intValue];
    char ck_ab[2];
    ck_ab[0] = 0;
    ck_ab[1] = 0;
    char *recieved_param = (char *)[data bytes];
    char length = recieved_param[2] + 2;
    for(char i = 0; i<length; i++)
    {
        ck_ab[0] = ck_ab[0] + recieved_param[i+1];
        ck_ab[1] = ck_ab[1] + ck_ab[0];
    }
    bytes[7] = ck_ab[0];
    bytes[8] = ck_ab[1];
    NSData *msg = [NSData dataWithBytes:bytes length:9];
    
    NSLog(@"第三包数据 %@", msg);
    
    [[JEBluetoothManager shareBLESingleton] sendMsg:msg];
}

//当获取到系统智能退出信号
- (void)applicationWillResign {
    if (_videoCapturing || _isPanoing) {
        [self camStillAction];
    }
}

//当获取到系统从后台返回的信号
- (void)applicationDidBecome {

}

/**
 修改对象跟踪的分辨率
 */
- (void)configRatioByNotify {
    if (_stillCamera.captureSessionPreset == AVCaptureSessionPreset3840x2160) {
        if (_isFilm) {
            [self configRatio:_filmFrameWidth height:_filmFrameHeight];
        }
        else {
            [self configRatio:2160 height:3840];
        }
    }
    else if (_stillCamera.captureSessionPreset == AVCaptureSessionPreset1280x720) {
        if (_isFilm) {
            [self configRatio:_filmFrameWidth height:_filmFrameHeight];
        }
        else {
            [self configRatio:720 height:1280];
        }
    }
    else if (_stillCamera.captureSessionPreset == AVCaptureSessionPreset1920x1080) {
        if (_isFilm) {
            [self configRatio:_filmFrameWidth height:_filmFrameHeight];
        }
        else {
            [self configRatio:1080 height:1920];
        }
    }
    else if (_stillCamera.captureSessionPreset == AVCaptureSessionPresetPhoto) {
        if (_isFilm) {
            [self configRatio:_filmFrameWidth height:_filmFrameHeight];
        }
        else {
            [self configRatio:([UIScreen mainScreen].scale * self.view.frame.size.width) height:([UIScreen mainScreen].scale * self.view.frame.size.height)];
        }
    }
}

- (void)configRatio:(CGFloat)width height:(CGFloat)height {
    NSLog(@"width = %f, height = %f", width, height);
    _cropImageWidth = width;
    _cropImageHeight = height;
    
    _mainRatioX = width/(self.view.frame.size.width);
    _mainRatioY = height/(self.view.frame.size.height);
    _mainPreset = height/width;
    
    int trackQuality = [[[NSUserDefaults standardUserDefaults] objectForKey:@"trackQ"] intValue];
    
    _mainRatio = 0.1;
    
    if(trackQuality == 1){
        _mainRatio = 120/width;
    }else{
        _mainRatio = 100/width;
    }
}

#pragma mark - —— Photo && Video
//拍照
- (void)takePhoto {
    //起一个异步线程
    if (_pictureCapturing) {
        return;
    }
    
    self.pictureCapturing = YES;
    dispatch_async(saveImageQueue, ^{
        //创建线程池
        @autoreleasepool {
            [_stillCamera capturePhotoAsPNGProcessedUpToFilter:self.captureFilter withOrientation:self.imageOrientation withCompletionHandler:^(NSData *processedPNG, NSError *error) {
                //如果开启了电影镜头，就对获取到的照片进行尺寸调整一下
                
                UIImage *processedImage;
                
                if (_isFilm) {
                    processedImage = [self resetStillcameraProcessedPNG:processedPNG];
                }
                else {
                    processedImage = [UIImage imageWithData:processedPNG];
                }
                
                NSString *fileName = [JECameraManager shareCAMSingleton].getNowDate;
                if ([[JECameraManager shareCAMSingleton] saveImage:processedImage toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName] withOrientation:self.imageOrientation]) {
                    self.pictureCapturing = NO;
                }
                else {
                    self.pictureCapturing = NO;
                }
            }];
        }
    });
}

//延迟拍照
- (void)takePhotoDelay:(NSInteger)sec {
    [self.countdownBtn startWithTime:sec mainColor:[UIColor clearColor] countColor:[UIColor whiteColor]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self takePhoto];
    });
}

//九宫图拍照
- (void)takePhotoWithNineLattice:(shootingMode)mode {

    switch (mode) {
        case picNLSquare:
        {
            if (_pictureCapturing) {
                return;
            }
            
            self.pictureCapturing = YES;
            dispatch_async(saveImageQueue, ^{
                @autoreleasepool {
                    [_stillCamera capturePhotoAsPNGProcessedUpToFilter:self.captureFilter withOrientation:self.imageOrientation withCompletionHandler:^(NSData *processedPNG, NSError *error) {
                        NSString *fileName = [JECameraManager shareCAMSingleton].getNowDate;
                        if ([[JECameraManager shareCAMSingleton] saveImage:[UIImage NineLatticeWaterMarkWithImage:[self niceLattice:[UIImage imageWithData:processedPNG]]] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName] withOrientation:self.imageOrientation]) {
                            self.pictureCapturing = NO;
                        }
                        else {
                            self.pictureCapturing = NO;
                        }
                    }];
                }
            });
        }
            break;
         
        case picNLRectangle:
        {
            if (_pictureCapturing) {
                return;
            }
            
            self.pictureCapturing = YES;
            dispatch_async(saveImageQueue, ^{
                @autoreleasepool {
                    [_stillCamera capturePhotoAsPNGProcessedUpToFilter:self.captureFilter withOrientation:self.imageOrientation withCompletionHandler:^(NSData *processedPNG, NSError *error) {
                        UIImage *image = [UIImage imageWithData:processedPNG];
                        
                        CGFloat saveImageWidth =  image.size.width/3;
                        CGFloat saveImageHeight = image.size.height/3;
                        
                        CGImageRef cgRef = image.CGImage;
                        
                        UIImage *thumbScale9 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth*2,saveImageHeight*2,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName9 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale9 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName9] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale8 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth,saveImageHeight*2,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName8 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale8 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName8] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale7 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(0,saveImageHeight*2,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName7 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale7 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName7] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale6 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth*2,saveImageHeight,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName6 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale6 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName6] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale5 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth,saveImageHeight,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName5 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale5 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName5] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale4 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(0,saveImageHeight,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName4 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale4 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName4] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale3 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth*2,0,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName3 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale3 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName3] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale2 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(saveImageWidth,0,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName2 = [JECameraManager shareCAMSingleton].getNowDate;
                        [[JECameraManager shareCAMSingleton] saveImage:thumbScale2 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName2] withOrientation:self.imageOrientation];
                        
                        UIImage *thumbScale1 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(cgRef, CGRectMake(0,0,saveImageWidth, saveImageHeight))];
                        CGImageRelease(cgRef);
                        NSString *fileName1 = [JECameraManager shareCAMSingleton].getNowDate;
                        
                        if ([[JECameraManager shareCAMSingleton] saveImage:thumbScale1 toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", fileName1] withOrientation:self.imageOrientation]) {
                            self.pictureCapturing = NO;
                        }
                        else {
                            self.pictureCapturing = NO;
                        }
                    }];
                }
            });
        }
            break;
            
        default:
            break;
    }
}

//触发全景拍照
- (void)takePhotoWithPano:(int)angle {
    if (_isPanoing) {
        [[JEBluetoothManager shareBLESingleton] BPQuitPano];
        self.isPanoing = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopPano];
        });
    }
    else {
        if (_isFrontCamera) {
            self.isFrontCamera = NO;
        }
        
        self.panoImagesArray = [NSMutableArray array];
        
        [self.countdownBtn startWithTime:3 mainColor:[UIColor clearColor] countColor:[UIColor whiteColor]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[JEBluetoothManager shareBLESingleton] BPPanoPhoto:angle];
            
            [_bottomToolBar.cameraButton setImage:[UIImage imageNamed:@"icon_shoot_stop"] forState:UIControlStateNormal];
            
            self.isPanoing = YES;
        });
    }
}

//开始全景
- (void)startPano {
    
    [self getStillImageWithBlock:^(UIImage *img){
        if(img){
            [self.panoImagesArray addObject:img];
        }
    } animate:YES];
}

//停止全景
- (void)stopPano {
    self.isAutoStitchPanoing = YES;
    
    [_bottomToolBar.cameraButton setImage:[UIImage imageNamed:@"icon_shoot_camera"] forState:UIControlStateNormal];
    
    [self.stillCamera pauseCameraCapture];
    
    [self setPanoModeView:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.0), @"hint":NSLocalizedString(@"Start stitching...", nil)}];
        @autoreleasepool {
            
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:[FileUtils panoDir] withIntermediateDirectories:YES attributes:nil error:nil];
            
            sr::SRStitcher::Status status = [self getWrapImageAndMask];
            
            if(status == sr::SRStitcher::OK){
                NSMutableArray *sources = [NSMutableArray array];
                NSMutableArray *masks   = [NSMutableArray array];
            
                for(int i=0; i<warpImageCnt; i++){
                    [sources addObject:[FileUtils warpImagePath:i]];
                    [masks addObject:[FileUtils maskImagePath:i]];
                }
                
                NSArray *conners = [NSKeyedUnarchiver unarchiveObjectWithFile:[FileUtils connersPath]];
                NSArray *sizes = [NSKeyedUnarchiver unarchiveObjectWithFile:[FileUtils sizesPath]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.75), @"hint":NSLocalizedString(@"Blending...", nil)}];
                
                [self Blend:sources maskNames:masks points:conners];
                
                [sources removeAllObjects];
                [masks removeAllObjects];
                
                NSMutableArray *blendedimageName = [NSMutableArray array];
                for(int i=0; i<warpImageCnt; i++){
                    [blendedimageName insertObject:[FileUtils blendImagePath:i] atIndex:i];
                }
                UIImage *finalImage;
                if(warpImageCnt>0){
                    [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.85), @"hint":NSLocalizedString(@"Stiching...", nil)}];
                    
                    finalImage = [self Compose:blendedimageName points:conners sizes:sizes];
                }
                
                CGRect CropRect = CGRectMake(finalImage.size.width*0.05, finalImage.size.height*0.1,  finalImage.size.width*0.95, finalImage.size.height*0.9);
                CGImageRef imageRef = CGImageCreateWithImageInRect([finalImage CGImage], CropRect) ;
                UIImage *cropped = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.95), @"hint":NSLocalizedString(@"Saving final image...", nil)}];
                
                //UIImage压缩
                NSData *imageData = UIImageJPEGRepresentation(cropped, 0.8);
                NSInteger len = imageData.length / 1024;
                NSLog(@"当前图片大小 : %ld", (long)len);
//                NSString *panoImagePath  = [FileUtils panoShowingPath];
                
//                if([[NSFileManager defaultManager] fileExistsAtPath:panoImagePath])
//                    [[NSFileManager defaultManager]removeItemAtPath:panoImagePath error:nil];
                
//                [imageData writeToFile:panoImagePath atomically:YES];               //不懂，把这张照片存进去有什么用 后期十分有可能需要把这部分内容删除
    
                //                NSLog(@"%@",self.panoImages);
                
                UIImage *imageResult = [CVWrapper processWithArray:self.panoImagesArray withAngle:1 quality:1];
                //                                        processWithArray:self.panoImages];
                
                NSData *data = UIImageJPEGRepresentation(imageResult, 1.0);
                NSLog(@"合成的全景照片大小为 : %lu", data.length);
                
                //[self saveImage:imageResult];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //NSLog(@"%@",imageResult);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PANO_PROGRESS object:@{@"progress":@(1.0), @"hint":NSLocalizedString(@"Finished", nil)}];
                    
                    //全景图片手动裁剪
                    CGRect CropRect = CGRectMake(imageResult.size.width*0.05, imageResult.size.height*0.1,  imageResult.size.width*0.95, imageResult.size.height*0.9);
                    CGImageRef imageRef = CGImageCreateWithImageInRect([imageResult CGImage], CropRect) ;
                    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:cropped];
                    
                    cropController.delegate = self;
                    
                    [self presentViewController:cropController animated:YES completion:^{
                        
                    }];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SHOW_HUD_DELAY(NSLocalizedString(@"Image Compositing Failed\nPlease keep your phone 1 meter or farther away from the shooting object.", comment: @"default"), self.view, 3.0);
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:[FileUtils panoDir] error:nil];
                [self.stillCamera resumeCameraCapture];
                self.isAutoStitchPanoing = NO;
            });
        }
    });
}

//延时关键点拍照
- (void)takePhotoWithMotionLapse {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(saveImageQueue, ^{
        @autoreleasepool {
            [_stillCamera capturePhotoAsPNGProcessedUpToFilter:self.captureFilter withOrientation:self.imageOrientation withCompletionHandler:^(NSData *processedPNG, NSError *error) {
                NSLog(@"获得了延时拍照照片");
                
                /*
                 *  处理关键点图片
                 */
                //压缩
                NSInteger maxLength = 100 * 1024;
                CGFloat compression = 1.0;
                NSData *compressData = processedPNG;
                UIImage *finalImage;
                if (compressData.length < maxLength) {
                    finalImage = [UIImage imageWithData:compressData];
                }
                else {
                    CGFloat max = 1.0;
                    CGFloat min = 0.0;
                    for (int index = 0; index < 6; ++index) {
                        compression = (max + min)/2;
                        compressData = processedPNG;
                        if (compressData.length < maxLength * 0.9) {
                            min = compression;
                        }
                        else if (compressData.length > maxLength) {
                            max = compression;
                        }
                        else {
                            break;
                        }
                    }
                    //第一次对图片尺寸压缩后判断是否符合标准 (对图片尺寸压缩因为不会影响图片质量，所以会压缩到一定程度后无法再压缩)
                    if (compressData.length < maxLength) {
                        finalImage = [UIImage imageWithData:compressData];
                    }
                    else {
                        //不符合标准进一步对图片质量进行压缩，一直压缩到符合要求为止
                        UIImage *compressImage = [UIImage imageWithData:compressData];
                        NSUInteger lastDataLength = 0;
                        while (compressData.length > maxLength && compressData.length != lastDataLength) {
                            lastDataLength = compressData.length;
                            CGFloat ratio = (CGFloat)maxLength / compressData.length;
                            CGSize size = CGSizeMake((NSUInteger)(compressImage.size.width * sqrtf(ratio)), (NSUInteger)(compressImage.size.height * sqrtf(ratio)));
                            UIGraphicsBeginImageContext(size);
                            [compressImage drawInRect:CGRectMake(0, 0, size.width, size.height)];   //重新画尺寸
                            compressImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            compressData = UIImageJPEGRepresentation(compressImage, compression);
                        }
                        finalImage = [UIImage imageWithData:compressData];
                    }
                }
                [self.motionLapsePointArray addObject:[self image:finalImage rotation:_imageOrientation]];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [[JEBluetoothManager shareBLESingleton] BPRecordMotionLapsePosition:_motionLapsePointArray.count StandingTime:0];
                NSLog(@"_motionLapsePointArray = %@", _motionLapsePointArray);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [_motionLapsePopView.getPointTableView reloadData];
                    [_motionLapsePopView.getPointTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_motionLapsePointArray.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                });
            }];
        }
    });
}

//全景拍摄中
- (void)getStillImageWithBlock:(getStillImageBlock)block animate:(BOOL)animate {
    NSLog(@"全景拍摄中...");
//    if(self.normalFilter.outputFrameSize.width != 0){
//        CGFloat cropWidth =  _cropImageWidth/self.normalFilter.sizeOfFBO.width;
//        if(cropWidth > 1.0)
//            cropWidth = 1.0;
//
//        CGFloat cropHeigh =  _cropImageHeight/self.normalFilter.sizeOfFBO.height;
//        if(cropHeigh > 1.0)
//            cropHeigh = 1.0;
//
//        self.normalFilter.cropRegion = CGRectMake(0, 0, cropWidth, cropHeigh);
//    }else{
//        self.normalFilter.cropRegion = CGRectMake(0, 0, 1, 1);
//    }
    
//    NSLog(@"_flashMode = %d", _flashMode);
//    if (_flashMode == flashModeOff) {
//        dispatch_async([GPUImageContext sharedContextQueue], ^{
//            [_normalFilter useNextFrameForImageCapture];
//        });
//
//        UIImage *img = [self.normalFilter imageFromCurrentFramebufferWithOrientation:_imageOrientation];
//
//        block(img);
//    }
//    else {
//        dispatch_async([GPUImageContext sharedContextQueue], ^{
//            [_normalFilter useNextFrameForImageCapture];
//        });
    
        [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.normalFilter withOrientation:_imageOrientation withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            //处理图片 压缩

            NSInteger maxLength = 250 * 1024;
            CGFloat compression = 1.0;
            NSData *compressData = UIImageJPEGRepresentation(processedImage, compression);
            UIImage *finalImage;
            if (compressData.length < maxLength) {
                finalImage = [UIImage imageWithData:compressData];
            }
            else {
                CGFloat max = 1.0;
                CGFloat min = 0.0;
                for (int index = 0; index < 6; ++index) {
                    compression = (max + min)/2;
                    compressData = UIImageJPEGRepresentation(processedImage, compression);
                    if (compressData.length < maxLength * 0.9) {
                        min = compression;
                    }
                    else if (compressData.length > maxLength) {
                        max = compression;
                    }
                    else {
                        break;
                    }
                }
                //第一次对图片尺寸压缩后判断是否符合标准 (对图片尺寸压缩因为不会影响图片质量，所以会压缩到一定程度后无法再压缩)
                if (compressData.length < maxLength) {
                    finalImage = [UIImage imageWithData:compressData];
                }
                else {
                    //不符合标准进一步对图片质量进行压缩，一直压缩到符合要求为止
                    UIImage *compressImage = [UIImage imageWithData:compressData];
                    NSUInteger lastDataLength = 0;
                    while (compressData.length > maxLength && compressData.length != lastDataLength) {
                        lastDataLength = compressData.length;
                        CGFloat ratio = (CGFloat)maxLength / compressData.length;
                        CGSize size = CGSizeMake((NSUInteger)(compressImage.size.width * sqrtf(ratio)), (NSUInteger)(compressImage.size.height * sqrtf(ratio)));
                        UIGraphicsBeginImageContext(size);
                        [compressImage drawInRect:CGRectMake(0, 0, size.width, size.height)];   //重新画尺寸
                        compressImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        compressData = UIImageJPEGRepresentation(compressImage, compression);
                    }
                    finalImage = [UIImage imageWithData:compressData];
                }
            }
            NSData *finalData = UIImageJPEGRepresentation(finalImage, 1.0);
            NSLog(@"单张全景照片大小 = %lu k", finalData.length/1024);
            
            block(finalImage);
        }];
//    }
}

/**
 录像

 @param isStart 是否开始录像
 */
- (void)takeVideo:(BOOL)isStart {
    if (isStart) {
        
        if (_videoCapturing) {
            return;
        }
        
        //录像路径
        self.videoPreviewString = [JECameraManager shareCAMSingleton].getNowDate;
        self.videoPath = [[JECameraManager shareCAMSingleton] getVideoPathWithName:[NSString stringWithFormat:@"%@.mov", _videoPreviewString]];
        unlink([_videoPath UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:_videoPath];
        
        NSLog(@"视频路径%@存在? : %d", _videoPath, [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]);
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            [[NSFileManager defaultManager] removeItemAtPath:_videoPath error:nil];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtURL:movieURL error:&err];
            NSLog(@"%@", err);
        }
        
        CGSize captureSize = [self getUserSaveVideoResolution];
        NSLog(@"captureSize = (%f, %f)", captureSize.width, captureSize.height);
        NSDictionary *settings;
        
        if (captureSize.width == 2160) {
            //调整编码
            if (@available(iOS 11.0, *)) {
                settings = @{AVVideoCodecKey:AVVideoCodecHEVC, AVVideoWidthKey:[NSNumber numberWithInt:captureSize.width], AVVideoHeightKey:[NSNumber numberWithInt:captureSize.height]};
            } else {
                // Fallback on earlier versions
                SHOW_HUD_DELAY(NSLocalizedString(@"您的手机版本太低，请升级到ios11.0或以上，否则4k录制会丢帧", nil), self.view, 2);
                settings = @{AVVideoCodecKey:AVVideoCodecH264, AVVideoWidthKey:[NSNumber numberWithInt:captureSize.width], AVVideoHeightKey:[NSNumber numberWithInt:captureSize.height]};
            }
        }
        else {
            settings = @{AVVideoCodecKey:AVVideoCodecH264, AVVideoWidthKey:[NSNumber numberWithInt:captureSize.width], AVVideoHeightKey:[NSNumber numberWithInt:captureSize.height]};
        }
        
        //初始化
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:captureSize fileType:AVFileTypeQuickTimeMovie outputSettings:settings];
        _movieWriter.encodingLiveVideo = YES;
        _movieWriter.shouldPassthroughAudio = YES;
        
        //设置声道
        _stillCamera.audioEncodingTarget = _movieWriter;
        
        [_captureFilter addTarget:_movieWriter];
        
        //开始录制
        [_movieWriter startRecordingInOrientation:CGAffineTransformRotate(CGAffineTransformIdentity, -_mainRotate)];
        NSLog(@"开始录像");
    
        self.videoCapturing = YES;
    }
    else {
        
        if (!_videoCapturing) {
            return;
        }
        
        [_movieWriter finishRecording];
        [_captureFilter removeTarget:_movieWriter];
        _stillCamera.audioEncodingTarget = nil;
        NSLog(@"录像结束");
        
        //将就用存图片的线程
        dispatch_async(saveImageQueue, ^{
            @autoreleasepool {
                NSURL *movieURL = [NSURL fileURLWithPath:_videoPath];
                NSLog(@"拍完的视频路径 = %@", movieURL);
                NSData *movieData = [NSData dataWithContentsOfURL:movieURL];
                
                if ([movieData writeToFile:_videoPath atomically:YES]) {
                    if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:movieURL size:[self getUserSaveVideoResolution]] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", _videoPreviewString]]) {
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
        });
        self.videoCapturing = NO;
    }
    [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
    _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
}

- (void)takeVideoWithMode:(ShootingMode)mode {
    switch (mode) {
        case videoMovingZoom:
        {
            //移动变焦
            if (_videoCapturing) {
                return;
            }
            else {
                //调整自动对焦和白平衡
                NSError *err;
                
                [self.stillCamera.inputCamera lockForConfiguration:&err];
                
                if(!err){
                    if([self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
                        [self.stillCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                    }
                    
                    if([self.stillCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]){
                        [self.stillCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                    }
                    
                    if([self.stillCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
                        [self.stillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    }
                    
                    [self.stillCamera.inputCamera unlockForConfiguration];
                }
                
                [self.countdownBtn startWithTime:3 mainColor:[UIColor clearColor] countColor:[UIColor whiteColor]];
            
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self takeVideo:YES];
                    
                    __weak typeof(self) weakSelf = self;
                    __block CGFloat weakScale = _effectiveScale;
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        
                        for (int i = 0; i<200; i++) {
                            
                            weakScale = weakScale - 0.01;
                            
                            if (weakScale < 1||weakScale == 1) {
                                
                                weakScale = 1;
                                
                                break;
                            }
                            AVCaptureDevice *captureDevice = weakSelf.stillCamera.inputCamera;
                            NSError *error;
                            if ([captureDevice lockForConfiguration:&error]) {
                                [captureDevice rampToVideoZoomFactor:weakScale withRate:0.6f];
                                [captureDevice unlockForConfiguration];
                            }
                            //变焦时间6S，休眠时间越长，变焦时间越长，平均0.005为1s
                            [NSThread sleepForTimeInterval:0.015];
                            NSLog(@"变焦");
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_videoCapturing == YES) {
                                [weakSelf takeVideo:NO];
                            }
                            [CATransaction begin];
                            [CATransaction setAnimationDuration:0.1];
                            AVCaptureDevice *captureDevice = weakSelf.stillCamera.inputCamera;
                            NSError *error;
                            if ([captureDevice lockForConfiguration:&error]) {
                                [captureDevice rampToVideoZoomFactor:3.0 withRate:0.6f];
                                [captureDevice unlockForConfiguration];
                            }
                            [CATransaction commit];
                        });
                    });
                });
            }
        }
            break;
            
        case videoSlowMotion:
        {
            //慢动作
            if (_videoCapturing) {
                [self takeVideoWithSlowMotion:NO];
            }
            else {
                
                NSError *error;
                [self.stillCamera.inputCamera lockForConfiguration:&error];
                if(!error){
                    //对焦状态 自动
                    if([self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
                        self.stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
                    }
                    [self.stillCamera.inputCamera unlockForConfiguration];
                }
                
                [self takeVideoWithSlowMotion:YES];
                
            }
        }
            break;
            
        case videoTimeLapse:
        {
            //普通延时
            if (_videoCapturing) {
                
                [self takeVideoWithTimeLapse:NO];
                [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
                _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
                
            }
            else {
                //异步处理
                [[NSOperationQueue new] addOperationWithBlock:^{
                    [self takeVideoWithTimeLapse:YES];
                    self.videoCapturing = YES;
                    [self setupTimeLapseTimer];
                    dispatch_resume(_timer);
                }];
                
                [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
                _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
            }
        }
            break;
            
        case videoLocusTimeLapse: {
            
            //轨迹延时
            if (_videoCapturing) {
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
                if (_controllerMode == cameraP1) {
                    //不进行录制
                    self.videoCapturing = NO;
                }
                else {
                    [self takeVideoWithTimeLapse:NO];
                }
                [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
                _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
            }
            else {
                //判断是否连接了设备
                if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
                    //判断拍摄关键点在两个以上
                    if (_motionLapsePointArray.count > 1) {
                        self.isMotionLapseShowing = NO;
                        [self.countdownBtn startWithTime:3 mainColor:[UIColor clearColor] countColor:[UIColor whiteColor]];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[JEBluetoothManager shareBLESingleton] BPStartMotionLapseModeSpeed:_motionLapsePopView.deviceSpeed];
                            if (_controllerMode == cameraP1){
                                if (_motionLapsePopView.isHidden == YES) {
                                    if (!_videoCapturing) {
                                        //异步处理
                                        [[NSOperationQueue new] addOperationWithBlock:^{
                                            self.videoCapturing = YES;
                                        }];
                                        
                                        [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
                                        _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
                                    }
                                }
                            }
                        });
                    }
                    else {
                        SHOW_HUD_DELAY(NSLocalizedString(@"Two Key Shooting Points Minimum", nil), self.view, 1.5);
                    }
                }
                else {
                    SHOW_HUD_DELAY(NSLocalizedString(@"Please connect the device", nil), self.view, 1.5);
                }
            }
        }
            break;
            
        default:
            break;
    }
}

//慢动作拍摄
- (void)takeVideoWithSlowMotion:(BOOL)isStart {
    if (isStart) {
        //开始录像
        if (_videoCapturing) {
            return;
        }
        
        //录像路径
        self.videoPreviewString = [JECameraManager shareCAMSingleton].getNowDate;
        self.videoPath = [[JECameraManager shareCAMSingleton] getVideoPathWithName:[NSString stringWithFormat:@"%@.mov", _videoPreviewString]];
        unlink([_videoPath UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:_videoPath];
        
        NSLog(@"视频路径%@存在? : %d", _videoPath, [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]);
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            [[NSFileManager defaultManager] removeItemAtPath:_videoPath error:nil];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtURL:movieURL error:&err];
            NSLog(@"%@", err);
        }
        
        //初始化
        [self.stillCamera pauseCameraCapture];
        [self.stillCamera.captureSession beginConfiguration];
        [self.stillCamera.captureSession removeOutput:self.stillCamera.videoOutput];
        [self.stillCamera.captureSession commitConfiguration];
        
        self.preLayer.hidden = NO;
        self.videoRecordTool = [[SRVideoRecordTool alloc] init];
        [self.videoRecordTool setupMovieWriter:self.stillCamera.captureSession];
        self.videoRecordTool.moviePath = self.videoPath;
        self.videoRecordTool.videoResolution = [self getUserSaveVideoResolution];
        self.videoRecordTool.videoName = _videoPreviewString;
        [self.videoRecordTool startRecord];
        
        self.videoCapturing = YES;
    }
    else {
        //停止录像
        if (!_videoCapturing) {
            return;
        }
        
        [self.videoRecordTool stopRecording];
        
        [self.stillCamera.captureSession beginConfiguration];
        if([self.stillCamera.captureSession canAddOutput:self.stillCamera.videoOutput]){
            [self.stillCamera.captureSession addOutput:self.stillCamera.videoOutput];
        }
        [self.stillCamera.captureSession commitConfiguration];
        [self.stillCamera resumeCameraCapture];
        
        NSError *error;
        [self.stillCamera.inputCamera lockForConfiguration:&error];
        if(!error){
            if([self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
                self.stillCamera.inputCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            [self.stillCamera.inputCamera unlockForConfiguration];
        }
        self.preLayer.hidden = YES;
        
        //音频来源为空，就是这里埋下了bug的隐患
        _stillCamera.audioEncodingTarget = nil;
        
        self.videoCapturing = NO;
    }
    [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
    _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
}

//延时摄影拍摄
- (void)takeVideoWithTimeLapse:(BOOL)isStart {
    if (isStart) {
        //开始录像
        if (_videoCapturing) {
            return;
        }
        
        //录像路径
        self.videoPreviewString = [JECameraManager shareCAMSingleton].getNowDate;
        self.videoPath = [[JECameraManager shareCAMSingleton] getVideoPathWithName:[NSString stringWithFormat:@"%@.mov", _videoPreviewString]];
        NSLog(@"录像路径的缩略图名字 : %@, 录像路径 : %@", _videoPreviewString, _videoPath);
        unlink([_videoPath UTF8String]);
        NSURL *movieURL = [NSURL fileURLWithPath:_videoPath];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            [[NSFileManager defaultManager] removeItemAtPath:_videoPath error:nil];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtURL:movieURL error:&err];
            NSLog(@"%@", err);
        }

        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:AVFileTypeQuickTimeMovie error:nil];
        
        CGSize videoSize = [self getUserSaveVideoResolution];
        NSLog(@"videoSize : (%f, %f)", videoSize.width, videoSize.height);
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:videoSize.height], AVVideoWidthKey,
                                       [NSNumber numberWithInt:videoSize.width], AVVideoHeightKey, nil];
        
        AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
        
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                         sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        
        NSParameterAssert(writerInput);
        NSParameterAssert([videoWriter canAddInput:writerInput]);
        
        if ([videoWriter canAddInput:writerInput])
            NSLog(@"可以添加");
        else
            NSLog(@"不可以添加");
        
        [videoWriter addInput:writerInput];
        
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        int __block frame = 0;
        
        dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
        
        //开始写视频帧
        [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
            while ([writerInput isReadyForMoreMediaData]) {
                if (_videoCapturing == NO) {
                    //还没开始录制
                    [writerInput markAsFinished];
                    if(videoWriter.status == AVAssetWriterStatusWriting) {
                        NSCondition *cond = [[NSCondition alloc] init];
                        [cond lock];
                        [videoWriter finishWritingWithCompletionHandler:^{
                            [cond lock];
                            [cond signal];
                            [cond unlock];
                        }];
                        [cond wait];
                        [cond unlock];
                        
                        NSData *movieData = [NSData dataWithContentsOfURL:movieURL];
                        NSLog(@"movieURL : %@, videoPath : %@", movieURL, _videoPath);
                        
                        //修正视频方向
//                        [self fixVideoOrientation:movieURL];
                        
                        if ([movieData writeToFile:_videoPath atomically:YES]) {
                            if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:movieURL size:[self getUserSaveVideoResolution]] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", _videoPreviewString]]) {
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
                    NSLog(@"end");
                    break;
                }
                dispatch_semaphore_wait(_seam, DISPATCH_TIME_FOREVER);
                
                if (_imageBuffer) {
                    //写视频帧
                    if([adaptor appendPixelBuffer:_imageBuffer withPresentationTime:CMTimeMake(frame, self.timeLapseProgress)]) {
                        frame++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"第%d帧",frame);
                        });
                    }
                    else {
                        NSLog(@"失败");
                    }
                    //释放buffer
                    CVPixelBufferRelease(_imageBuffer);
                    _imageBuffer = NULL;
                }
            }
        }];
    }
    else {
        dispatch_cancel(_timer);
        
        _timer = nil;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _videoCapturing = NO;
            dispatch_semaphore_signal(_seam);
        });
    }
}

//进入录像模式 隐藏其他内容，显示录像时间
- (void)setVideoModeView:(BOOL)isVideoing {
    NSLog(@"进入录像模式? = %d", isVideoing);
    
    //页面其他内容的显示和隐藏
    _topToolBar.hidden = isVideoing;
    _middleToolBar.trackStay.hidden = isVideoing;
    _middleToolBar.trackView.hidden = YES;
    _bottomToolBar.subBottomButton.hidden = isVideoing;
    _bottomToolBar.shootSwitchButton.hidden = isVideoing;
    _bottomToolBar.lensSwitchButton.hidden = isVideoing;
    _bottomToolBar.albumButton.hidden = isVideoing;
    
    //如果是移动延时模式，还需要添加暂停按钮
    if (_shootingMode == videoLocusTimeLapse) {
        _stopTimeLapseButton.hidden = !isVideoing;
    }
    
    if (isVideoing) {
        //隐藏内容
        if (_isFilterShowing == YES) {
            self.isFilterShowing = NO;
        }
        if (_isCameraSetting == YES) {
            self.isCameraSetting = NO;
        }
        if (_isDeviceSetting == YES) {
            self.isDeviceSetting = NO;
        }
        if (_isSubShowing == YES) {
            self.isSubShowing = NO;
        }
        if (_isFunctionShowing == YES) {
            self.isFunctionShowing = NO;
        }
        if (_isMotionLapseShowing == YES) {
            self.isMotionLapseShowing = NO;
        }
        if (_isTimeLapseShowing == YES) {
            self.isTimeLapseShowing = NO;
        }
        
        //进入录像模式
        if (_controllerMode == cameraM1) {
            self.videoTimeLB = [[UILabel alloc] init];
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(_mainRotate);
            [_videoTimeLB setTransform:transform];
            if (_mainRotate == 0) {
                self.videoTimeLB.frame = CGRectMake(0, 60, self.view.frame.size.width, 40);
            }
            else {
                self.videoTimeLB.frame = CGRectMake(self.view.frame.size.width - 60, 0, 40, self.view.frame.size.height);
            }
            _videoTimeLB.textColor = [UIColor whiteColor];
            _videoTimeLB.textAlignment = NSTextAlignmentCenter;
            _videoTimeLB.font = [UIFont systemFontOfSize:18];
            _videoTimeLB.text = @"00:00:00";
            [self.view addSubview:_videoTimeLB];
            
            if ([_videoTimer isValid]) {
                [_videoTimer invalidate];
            }
            
            _videoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(videoTimeCount) userInfo:nil repeats:YES];
        }
    }
    else {
        //退出录像模式
        if (_controllerMode == cameraM1) {
            [_videoTimer invalidate];
            _videoTimer = nil;
            _videoTimerSecond = 0;
            [_videoTimeLB removeFromSuperview];
            _videoTimeLB = nil;
        }
    }
}

//进入全景模式 隐藏其他内容
- (void)setPanoModeView:(BOOL)panoing {
    //页面其他内容的显示和隐藏
    _topToolBar.hidden = panoing;
    _middleToolBar.trackStay.hidden = panoing;
    _middleToolBar.trackView.hidden = YES;
    _bottomToolBar.subBottomButton.hidden = panoing;
    _bottomToolBar.shootSwitchButton.hidden = panoing;
    _bottomToolBar.lensSwitchButton.hidden = panoing;
    _bottomToolBar.albumButton.hidden = panoing;

    if (panoing) {
        if (_isFilterShowing == YES) {
            self.isFilterShowing = NO;
        }
        if (_isCameraSetting == YES) {
            self.isCameraSetting = NO;
        }
        if (_isDeviceSetting == YES) {
            self.isDeviceSetting = NO;
        }
        if (_isSubShowing == YES) {
            self.isSubShowing = NO;
        }
        if (_isFunctionShowing == YES) {
            self.isFunctionShowing = NO;
        }
        if (_isMotionLapseShowing == YES) {
            self.isMotionLapseShowing = NO;
            [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
            [_motionLapsePointArray removeAllObjects];
            _motionLapsePopView.pointPicArray = _motionLapsePointArray;
            [_motionLapsePopView.getPointTableView reloadData];
        }
        if (_isTimeLapseShowing == YES) {
            self.isTimeLapseShowing = NO;
        }
    }
}

//视频时长计时
- (void)videoTimeCount {
    _videoTimerSecond++;
    _videoTimeLB.text = [self getMMSSFromSS:_videoTimerSecond];
}

#pragma mark - TouchDelegate
//屏幕触碰事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {

    if (_isFilterShowing == YES) {
        self.isFilterShowing = NO;
    }
    if (_isCameraSetting == YES) {
        self.isCameraSetting = NO;
        [_cameraSettingView cleanCameraSettingOption];
    }
    if (_isDeviceSetting == YES) {
        self.isDeviceSetting = NO;
    }
    if (_isSubShowing == YES) {
        self.isSubShowing = NO;
    }
    if (_isTimeLapseShowing == YES) {
        self.isTimeLapseShowing = NO;
    }
    if (_isMotionLapseShowing == YES) {
        self.isMotionLapseShowing = NO;
        [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
        [_motionLapsePointArray removeAllObjects];
        _motionLapsePopView.pointPicArray = _motionLapsePointArray;
        [_motionLapsePopView.getPointTableView reloadData];
    }
    
    UITouch *aTouch  = [touches anyObject];
    CGPoint tPoint = [aTouch locationInView:_cameraOutputView];
    
    if (_isObjectTracking) {
        _isObjTrackReady = NO;
        
        _objectTrackingView.hidden = NO;
        _objectTrackingView.layer.borderColor = MAIN_TEXT_COLOR.CGColor;
        _trackViewLTPoint = tPoint;
        _trackViewRDPoint = CGPointZero;
        NSLog(@"落手坐标 = (%f, %f)", tPoint.x, tPoint.y);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
        UITouch *aTouch  = [touches anyObject];
        CGPoint tPoint = [aTouch locationInView:_cameraOutputView];
    
    if (_isObjectTracking) {
        _trackViewRDPoint = tPoint;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
        UITouch *aTouch  = [touches anyObject];
        CGPoint tPoint = [aTouch locationInView:_cameraOutputView];
    
    if (_isObjectTracking && !_isObjTrackStart) {
        _isObjTrackReady = YES;
        
        _trackViewRDPoint = tPoint;
        NSLog(@"抬手坐标 = (%f, %f)", tPoint.x, tPoint.y);
    }
    
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    NSLog(@"屏幕手势");
    
    if (_focusingView.isHidden == NO) {
        if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            
            currValue = currValue - 0.05;
            
            if (currValue<0) {
                
                currValue=0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_focusingView.slider setValue:currValue];
            });
        }
        
        if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            
            NSLog(@"swipe up");
            
            currValue = currValue + 0.05;
            
            if (currValue>1) {
                
                currValue=1;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_focusingView.slider setValue:currValue];
            });
        }
    }
}

#pragma mark - JEBluetoothManagerDelegate
- (void)updateBLEState:(bluetoothToolsState)bluetoothState {
    NSLog(@"smartVC 当前蓝牙状态 : %lu", (unsigned long)bluetoothState);
    if (bluetoothState == DisConnect) {
        _middleToolBar.bluetoothSign.selected = NO;
        //清空计时器
        if (_updateFirmwareTimer.isValid) {
            [self.updateFirmwareTimer invalidate];
            self.updateFirmwareTimer = nil;
            _updateFirmwareTimeCount = 0;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

    if (bluetoothState == Connect) {
        //成功连接
        _middleToolBar.bluetoothSign.selected = YES;
    }
}

//提示当前手机蓝牙的状态
- (void)hintBLEStatus:(bluetoothToolsState)bleStatus {
    if (bleStatus == PoweredOff) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Bluetooth Required", nil)
                                                                        message:NSLocalizedString(@"Please turn on the mobile Bluetooth", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                 }]];
        
        [self presentViewController:alertC animated:YES completion:nil];
        
        return;
    }
}

/**
 蓝牙收到的指令消息

 @param msg 指令消息
 */
- (void)commandDidRecieved:(NSString *)msg {
    NSLog(@"蓝牙收到的关键命令 : %@", [msg substringWithRange:NSMakeRange(2, 2)]);
    NSLog(@"接收消息 = %@", msg);
    
    /*
     *  蓝牙数据参数包
     */
    //收到第一包数据
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"31"]) {
        self.blueParameter1 = msg;
        [[JEBluetoothManager shareBLESingleton] BPGetBLEParameterBag];
        return;
    }
    //收到第二包数据
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"32"]) {
        self.blueParameter2 = msg;
        [[JEBluetoothManager shareBLESingleton] BPGetBLEParameterBag];
        return;
    }
    //收到第三包数据，合成数据字符串并保存相应的重要参数
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"33"] && ([_blueParameter1 length] != 0) && ([_blueParameter2 length] != 0)) {
        self.blueParameterString = [NSString stringWithFormat:@"%@%@%@",_blueParameter1, _blueParameter2, msg];

        //保存 航向轴 && 俯仰轴 速度
        USER_SET_SaveAxisPushSpeed_Interger(([[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(68, 2)]] integerValue]/5)-1);
        USER_SET_SavePitchPushSpeed_Interger(([[self numberHexString:[_blueParameterString substringWithRange:NSMakeRange(64, 2)]] integerValue]/5)-1);
    
        NSLog(@"收到的蓝牙总参数数据 : %@", _blueParameterString);
        return;
    }
    //蓝牙收到上一包数据，请求下一包数据
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"2a"]) {
        if (_blueParameterTimes == 1) {
            [self sendBlueBagSecond];
        }
        if (_blueParameterTimes == 2) {
            [self sendBlueBagThird];
        }
        return;
    }
    //蓝牙收到三包完整数据，告诉 app 参数保存成功
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"2b"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        SHOW_HUD_DELAY(NSLocalizedString(@"Setting Saved", comment: ""), self.view, 0.5);
        return;
    }
    
    /*
     *  固件更新
     */
    //获取蓝牙版本信息
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"40"]) {
        NSString *string = [msg substringWithRange:NSMakeRange(7, 1)];
        NSString *string1 = [msg substringWithRange:NSMakeRange(9, 1)];
        NSString *string2 = [msg substringWithRange:NSMakeRange(11, 1)];
        
        NSString *bluetoothVersion = [NSString stringWithFormat:@"%@%@%@", string, string1, string2];
    
        USER_SET_SaveVersionBluetooth_NSString(bluetoothVersion);
        
        return;
    }
    //获取到固件和硬件版本信息
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"1d"]) {
        NSString *string = [msg substringWithRange:NSMakeRange(6, 2)];
        
        NSString *firmwareVersion = [self numberHexString:string];
        
        NSString *string1 = [msg substringWithRange:NSMakeRange(8, 2)];
        
        NSString *hardwareVersion = [self numberHexString:string1];
        
        //此处持久化处理保存固件版本信息、硬件固件版本信息和蓝牙固件版本信息
        USER_SET_SaveVersionFirmware_NSString(firmwareVersion);
        USER_SET_SaveVersionHardware_NSString(hardwareVersion);
        
        return;
    }
    //已经准备好接受数据
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"25"]) {
        if ([_updateFirmwareDataString length] != 0) {
            //隐藏确认和取消键，显示进度条
            self.updateFirmwareView.updateConfirmBtn.hidden = YES;
            self.updateFirmwareView.updateCancelBtn.hidden = YES;
            self.updateFirmwareView.progressView.hidden = NO;
            
            //进度条开始
            [self.updateFirmwareView.progressView start];
            
            [self doSomeWorkWithProgress];
            
            NSString *currDataString = [_updateFirmwareDataString substringWithRange:NSMakeRange(0, 32)];
            
            NSData *currData = [self convertHexStrToData:currDataString];
            
            NSUInteger len = [currData length];
            Byte *byteData = (Byte*)malloc(len);
            memcpy(byteData, [currData bytes], len);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //发送下载好的第一个固件数据包
                [[JEBluetoothManager shareBLESingleton] BPFirmwareUpdateFirstPacket:byteData];
                self.updateFirmwareBag = 0;
                //开始计时
                _updateFirmwareTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateFirmwareTimeAction) userInfo:nil repeats:YES];
            });
            
            return;
        }
        return;
    }
    //确认收到第一个固件数据包
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"26"]){
        
        [_updateFirmwareDataString deleteCharactersInRange:NSMakeRange(0, 32)]; //删除上一包内容
        
        //清空计时器
        if (_updateFirmwareTimer.isValid) {
            [self.updateFirmwareTimer invalidate];
            self.updateFirmwareTimer = nil;
            _updateFirmwareTimeCount = 0;
        }
        
        if ([_updateFirmwareDataString length] == 0) {
            
            //退出固件升级
            [[JEBluetoothManager shareBLESingleton] BPQuitFirmwareUpdata];
        }
        if ([_updateFirmwareDataString length] != 0) {
            
            NSString *currDataString = [_updateFirmwareDataString substringWithRange:NSMakeRange(0, 32)];
            
            [self doSomeWorkWithProgress];
            
            NSData *currData = [self convertHexStrToData:currDataString];
            
            NSUInteger len = [currData length];
            Byte *byteData = (Byte*)malloc(len);
            memcpy(byteData, [currData bytes], len);
            
            [[JEBluetoothManager shareBLESingleton] BPFirmwareUpdateSecondPacket:byteData];
            self.updateFirmwareBag = 1;
            //开始计时
            _updateFirmwareTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateFirmwareTimeAction) userInfo:nil repeats:YES];
            
            return;
        }
        return;
    }
    //确认收到了整个包，发送下一个包
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"22"]) {
        
        [_updateFirmwareDataString deleteCharactersInRange:NSMakeRange(0, 32)]; //删除上一包内容
        
        //清空计时器
        if (_updateFirmwareTimer.isValid) {
            [self.updateFirmwareTimer invalidate];
            self.updateFirmwareTimer = nil;
            _updateFirmwareTimeCount = 0;
        }
        
        if ([_updateFirmwareDataString length] == 0) {
            
            //退出固件升级
            [[JEBluetoothManager shareBLESingleton] BPQuitFirmwareUpdata];
        }
        if ([_updateFirmwareDataString length] != 0) {
            NSString *currDataString = [_updateFirmwareDataString substringWithRange:NSMakeRange(0, 32)];
            
            [self doSomeWorkWithProgress];
            
            NSData *currData = [self convertHexStrToData:currDataString];
            
            NSUInteger len = [currData length];
            Byte *byteData = (Byte*)malloc(len);
            memcpy(byteData, [currData bytes], len);
            
            [[JEBluetoothManager shareBLESingleton] BPFirmwareUpdateFirstPacket:byteData];
            self.updateFirmwareBag = 0;
            //开始计时
            _updateFirmwareTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateFirmwareTimeAction) userInfo:nil repeats:YES];
        }
        return;
    }
    //固件升级完成
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"24"]){
        
        //清空计时器
        if (_updateFirmwareTimer.isValid) {
            [self.updateFirmwareTimer invalidate];
            self.updateFirmwareTimer = nil;
            _updateFirmwareTimeCount = 0;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Information", nil) message:NSLocalizedString(@"Firmware Updated", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            self.isClearViewShowing = NO;
            //获取固件版本信息
            [[JEBluetoothManager shareBLESingleton] BPGetDeviceVersion];
        }]];
        
        [_updateFirmwareView removeFromSuperview];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //校准完成
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"17"]) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        [_accelerationVC accelerationSuccess];
        return;
    }
    
    /*
     *  拍照
     */
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"0a"]) {
        if (_controllerMode == cameraP1) {
            return;
        }
        
        //全景模式下
        if (_shootingMode == picPano90d || _shootingMode == picPano180d || _shootingMode == picPano360d || _shootingMode == picPano3x3) {
            //正在全景拍摄中
            if (_isPanoing) {
                [[JEBluetoothManager shareBLESingleton] BPQuitPano];
                self.isPanoing = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopPano];
                });
            }
            else {
                //触发拍摄全景
                [self bottomToolBarButtonAction:224];
            }
            return;
        }
        //移动延时模式下
        if (_shootingMode == videoLocusTimeLapse) {
            if (_motionLapsePopView.isHidden == YES) {
                if (!_videoCapturing) {
                    //已经准备好了可以开始拍摄
                    //判断是否连接了设备
                    if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
                        //判断拍摄关键点在两个以上
                        if (_motionLapsePointArray.count > 1) {
                            //异步处理
                            [[NSOperationQueue new] addOperationWithBlock:^{
                                [self takeVideoWithTimeLapse:YES];
                                self.videoCapturing = YES;
                                [self setupTimeLapseTimer];
                                dispatch_resume(_timer);
                            }];
                            
                            [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
                            _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
                        }
                        else {
                            SHOW_HUD_DELAY(NSLocalizedString(@"Two Key Shooting Points Minimum", nil), self.view, 1.5);
                        }
                    }
                    else {
                        SHOW_HUD_DELAY(NSLocalizedString(@"Please connect the device", nil), self.view, 1.5);
                    }
                }
                else {
                    [self camStillAction];
                }
            }
            else {
                //触发快门事件，向设备发送开启延时命令
                self.timeLapseProgress = (int)_motionLapsePopView.timeScale * 2;
                [self takeVideoWithMode:videoLocusTimeLapse];
            }
        }
        //非全景模式下
        else {
            [self camStillAction];
        }
        
        return;
    }
    
    /*
     *  全景拍摄
     */
    //全景拍照
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"60"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        if (_shootingMode == picPano90d || _shootingMode == picPano180d || _shootingMode == picPano360d || _shootingMode == picPano3x3) {
            if (_isPanoing) {
                [self startPano];
            }
        }
        return;
    }
    
    //停止全景
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"08"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        self.isPanoing = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopPano];
        });
        return;
    }
    
    /*
     *  移动延时
     */
    //停止移动延时
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"0c"]) {
        if (_videoCapturing) {
            [_motionLapsePointArray removeAllObjects];
            _motionLapsePopView.pointPicArray = _motionLapsePointArray;
            [_motionLapsePopView.getPointTableView reloadData];
            if (_controllerMode == cameraP1) {
                self.videoCapturing = NO;
            }
            else {
                [self takeVideoWithTimeLapse:NO];
            }
            [self setVideoModeView:!_bottomToolBar.cameraButton.isSelected];
            _bottomToolBar.cameraButton.selected = !_bottomToolBar.cameraButton.isSelected;
        }
        return;
    }
    
    /*
     *  滚轮
     */
    //对焦反方向
    if ([[msg substringWithRange:NSMakeRange(2, 8)] isEqualToString:@"06040100"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        //在自定义模式下，要修改自定义模式内容，屏蔽对焦事件
        if (_isFunctionShowing) {
            [_customFunctionView changePickerViewValue:NO];
            return;
        }
        //录像非普通模式和延时模式时屏蔽滚轮事件
        if (_shootingMode == videoMovingZoom || _shootingMode == videoLocusTimeLapse) {
            return;
        }
        
        _focusingView.alpha = 1;
        _focusingView.hidden = NO;
        currValue = currValue - 0.05;
        if (currValue<0) {
            currValue=0;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration: 0.5 animations: ^{
                [_focusingView.slider setValue:currValue];
            } completion: nil];
            NSError *error;
            if ([self.stillCamera.inputCamera lockForConfiguration:&error]) {
                
                [self.stillCamera.inputCamera setFocusModeLockedWithLensPosition:currValue completionHandler:nil];
                [self.stillCamera.inputCamera unlockForConfiguration];
                
                POPBasicAnimation *alpAni = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
                alpAni.duration = 5.0;
                alpAni.fromValue = @(1.0);
                alpAni.toValue = @(0.0);
                
                [_focusingView pop_addAnimation:alpAni forKey:@"alpha"];
            }
        });
        return;
    }
    //对焦正方向
    if ([[msg substringWithRange:NSMakeRange(2, 8)] isEqualToString:@"06040101"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        if (_isFunctionShowing) {
            [_customFunctionView changePickerViewValue:YES];
            return;
        }
        //录像非普通模式和延时模式时屏蔽滚轮事件
        if (_shootingMode == videoMovingZoom || _shootingMode == videoLocusTimeLapse) {
            return;
        }
        
        _focusingView.alpha = 1;
        
        _focusingView.hidden = NO;
        
        currValue = currValue + 0.05;
        
        if (currValue>1) {
            
            currValue=1;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration: 0.5 animations: ^{
                
                [_focusingView.slider setValue:currValue];
                
            } completion: nil];
            
            NSError *error;
            
            if ( [self.stillCamera.inputCamera lockForConfiguration:&error]) {
                [self.stillCamera.inputCamera setFocusModeLockedWithLensPosition:currValue completionHandler:nil];
                [self.stillCamera.inputCamera unlockForConfiguration];
                
                POPBasicAnimation *alpAni = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
                alpAni.duration = 5.0;
                alpAni.fromValue = @(1.0);
                alpAni.toValue = @(0.0);
                
                [_focusingView pop_addAnimation:alpAni forKey:@"alpha"];
            }
        });
        return;
    }
    //变焦反方向
    if ([[msg substringWithRange:NSMakeRange(2, 8)] isEqualToString:@"06040000"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        if (_isFunctionShowing) {
            [_customFunctionView changePickerViewValue:NO];
            return;
        }
        //录像非普通模式和延时模式时屏蔽滚轮事件
        if (_shootingMode == videoMovingZoom || _shootingMode == videoLocusTimeLapse) {
            return;
        }
        
        _zoomSliderView.alpha = 1;
        _zoomSliderView.hidden = NO;
        //缩小 反转
        NSString *string_11 = [msg substringWithRange:NSMakeRange(10, 2)];
        float sum = [[self numberHexString:string_11] floatValue];
        NSLog(@"%.2f",sum);
        if (sum==1.00) {
            sum=3.00;
        }
        if (sum==2.00) {
            sum=3.00;
        }
        flags = sum/30.00;
        curr = curr-flags;
        if (curr<1) {
            curr=1;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration: 0.5 animations: ^{
                [_zoomSliderView.srSlider setValue:curr];
                _zoomSliderView.srSlider.labelAboveThumb.hidden = YES;
            } completion:nil];
        });
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.1];
        AVCaptureDevice *captureDevice = self.stillCamera.inputCamera;
        NSError *error;
        if ([captureDevice lockForConfiguration:&error]) {
            [captureDevice rampToVideoZoomFactor:curr withRate:0.6f];
            [captureDevice unlockForConfiguration];
            POPBasicAnimation *alpAni = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            alpAni.duration = 5.0;
            alpAni.fromValue = @(1.0);
            alpAni.toValue = @(0.0);
            
            [_zoomSliderView pop_addAnimation:alpAni forKey:@"alpha"];
        }
        [CATransaction commit];
        return;
    }
    //变焦正方向
    if ([[msg substringWithRange:NSMakeRange(2, 8)] isEqualToString:@"06040001"]) {
        if (_controllerMode != cameraM1) {
            return;
        }
        if (_isFunctionShowing) {
            [_customFunctionView changePickerViewValue:YES];
            return;
        }
        //录像非普通模式和延时模式时屏蔽滚轮事件
        if (_shootingMode == videoMovingZoom || _shootingMode == videoLocusTimeLapse) {
            return;
        }
        
        _zoomSliderView.alpha = 1;
        _zoomSliderView.hidden = NO;
        //放大 正转
        NSString *string_11 = [msg substringWithRange:NSMakeRange(12, 2)];
        float sum = [[self numberHexString:string_11] floatValue];
        NSLog(@"%.2f",sum);
        if (sum == 1.00) {
            sum = 3.00;
        }
        if (sum == 2.00) {
            sum = 3.00;
        }
        flags = sum/30.00;
        if (curr > 1) {
            curr = curr + flags;
        }else{
            curr = 1.00 + flags;
        }
        if (curr > 3) {
            curr = 3;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration: 0.5 animations: ^{
                [_zoomSliderView.srSlider setValue:curr];
                _zoomSliderView.srSlider.labelAboveThumb.hidden = YES;
            } completion:nil];
        });
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.1];
        AVCaptureDevice *captureDevice = self.stillCamera.inputCamera;
        NSError *error;
        if ([captureDevice lockForConfiguration:&error]) {
            [captureDevice rampToVideoZoomFactor:curr withRate:0.6f];
            [captureDevice unlockForConfiguration];
            
            POPBasicAnimation *alpAni = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            alpAni.duration = 5.0;
            alpAni.fromValue = @(1.0);
            alpAni.toValue = @(0.0);
            
            [_zoomSliderView pop_addAnimation:alpAni forKey:@"alpha"];
        }
        [CATransaction commit];
        return;
    }
    
    /*
     *  充电开关机状态
     */
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"38"]) {
        if ([[msg substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]) {
            USER_SET_SaveChargingSwitchState_BOOL(NO);
            return;
        }
        else if ([[msg substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]) {
            USER_SET_SaveChargingSwitchState_BOOL(YES);
            return;
        }
    }
    
    /*
     *  手柄俯仰轴方向
     */
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"3d"]) {
        if ([[msg substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]) {
            //默认方向
            USER_SET_SavePitchOrientationOpposite_BOOL(NO);
            return;
        }
        else if ([[msg substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]) {
            USER_SET_SavePitchOrientationOpposite_BOOL(YES);
            return;
        }
    }
    
    /*
     *  APP连接成功通知
     */
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"3b"]) {
        //发送自定义功能按键状态
        [[JEBluetoothManager shareBLESingleton] BPSendCustomFunctionStr:self.customFunctionArray[USER_GET_SaveFunctionMode_Integer]];
        return;
    }
    
    /*
     *  自定义功能按键
     */
    //如果在全景拍照中、视频拍摄中、图片拍摄中时候不响应自定义功能按键
    //单击
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"1c"]) {
        if (_controllerMode == cameraP1) {
            return;
        }
        if (_isPanoing || _videoCapturing || _pictureCapturing) {
            return;
        }
        self.isFunctionShowing = !_isFunctionShowing;
        return;
    }
    //双击触发功能
    if ([[msg substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"30"]) {
        if (_controllerMode == cameraP1) {
            return;
        }
        if (_isPanoing || _videoCapturing || _pictureCapturing) {
            return;
        }
        if (_isFunctionShowing) {
            self.isFunctionShowing = NO;
        }
        NSLog(@"获取下现在自定义功能是 : %ld", (long)USER_GET_SaveFunctionMode_Integer);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[JEBluetoothManager shareBLESingleton] BPSendCustomFunctionStr:self.customFunctionArray[USER_GET_SaveFunctionMode_Integer]];
        });
        switch (USER_GET_SaveFunctionMode_Integer) {
            case 0:
            {
                //前后置摄像头切换
                [self bottomToolBarButtonAction:225];
            }
                break;
             
            case 1:
            {
                //视频或拍照模式切换
                [self bottomToolBarButtonAction:222];
            }
                break;
                
            case 2:
            {
                //闪光灯开关
                if (_flashMode == 0) {
                    USER_SET_SaveFlashMode_Integer(1);
                }
                else {
                    USER_SET_SaveFlashMode_Integer(0);
                }
                [self setCameraFlashMode:USER_GET_SaveFlashMode_Integer];
            }
                break;
                
            case 3:
            {
                //美颜功能开关
                self.isBeautyOpening = !_isBeautyOpening;
            }
                break;
                
            case 4:
            {
                //启动滤镜功能
                self.isFilterShowing = !_isFilterShowing;
            }
                break;
                
            case 5:
            {
                //启动或关闭人脸追踪
                if (_isObjectTracking) {
                    [_middleToolBar takeTrack];
                }
                if (_isFaceTracking) {
                    [_middleToolBar takeTrack];
                }
                else {
                    [_middleToolBar trackBtnAction:_middleToolBar.faceTrackBtn];
                }
            }
                break;
                
            case 6:
            {
                //启动或关闭对象追踪
                if (_isFaceTracking) {
                    [_middleToolBar takeTrack];
                }
                if (_isObjectTracking) {
                    [_middleToolBar takeTrack];
                }
                else {
                    [_middleToolBar trackBtnAction:_middleToolBar.objectTrackBtn];
                }
            }
                break;
                
            case 7:
            {
                //启动90度全景拍摄
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicPano90d];
                    [self camStillAction];
                });
            }
                break;
                
            case 8:
            {
                //启动180度全景拍摄
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicPano180d];
                    [self camStillAction];
                });
                
            }
                break;
                
            case 9:
            {
                //启动360度全景拍摄
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicPano360d];
                    [self camStillAction];
                });
                
            }
                break;
                
            case 10:
            {
                //启动九宫格拍摄 - 模式1
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicNLSquare];
                    [self camStillAction];
                });
                
            }
                break;
                
            case 11:
            {
                //启动九宫格拍摄 - 模式2
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicNLRectangle];
                    [self camStillAction];
                });
                
            }
                break;
                
            case 12:
            {
                //启动移动变焦拍摄
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subVideoMovingZoom];
//                    [self camStillAction];
                });
                
            }
                break;
                
                /*
            case 13:
            {
                //启动慢动作拍摄
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subVideoSlowMotion];
                    [self camStillAction];
                });
                
            }
                break;
                 */
                
            case 13:
            {
                //启动延时拍摄
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.timeLapseProgress = (int)USER_GET_SaveTimelapseProportion_Interger * 15 * 2;
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subVideoTimeLapse];
                    [self camStillAction];
                });
            }
                break;
                
            case 14:
            {
                //启动轨迹延时拍摄
//                self.isMotionLapseShowing = !_isMotionLapseShowing;
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subVideoLocusTimeLapse];
                });
            }
                break;
                
            case 15:
            {
                //启动3x3 超广角全景拍摄
                if (_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_bottomToolBar.bottomMenu subViewButtonAction:_bottomToolBar.bottomMenu.subPicPano3x3];
                    [self camStillAction];
                });
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
}

#pragma mark - GPUImageVideoCameraDelegate
//获取到视频的每一帧图像 sampleBuffer 便于对象追踪
- (BOOL)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (_isObjectTracking) {
        //开启对象追踪
        [self getROIFromSampleBuffer:sampleBuffer];
    }
    
    if ((_shootingMode == videoTimeLapse || _shootingMode == videoLocusTimeLapse) &&  _timeLapseCapturing) {
        _timeLapseCapturing = NO;
        //获取buffer
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        _imageBuffer =  CVPixelBufferRetain(imageBuffer);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        dispatch_semaphore_signal(_seam);
    }
    
    
    return NO;
}

//获取人脸数据
- (void)didOutputMetadataObjects:(NSArray *)metadataObjects {
    //每次都去除掉人脸框，便于刷新
    [self removeFaceFocusView];
    if (metadataObjects.count == 0) {
        //人脸丢失
        NSLog(@"人脸丢失");
        [[JEBluetoothManager shareBLESingleton] BPFaceMsgLoss];
    }
    else {
        //人脸数据数组，用作对比faceID跟踪用
        NSMutableArray *faceObjArray = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isFaceTracking) {
                //遍历人脸数据
                for (AVMetadataObject *metaObj in metadataObjects) {
                    AVMetadataFaceObject *faceObj = (AVMetadataFaceObject *)[self.preLayer transformedMetadataObjectForMetadataObject:metaObj];
                    
                    //将需要的人脸数据存入数组
                    NSMutableDictionary *faceMsgDic = [[NSMutableDictionary alloc] init];
                    [faceMsgDic setObject:[NSString stringWithFormat:@"%ld",(long)faceObj.faceID] forKey:@"ID"];
                    [faceMsgDic setObject:NSStringFromCGRect(faceObj.bounds) forKey:@"Bounds"];
                    [faceObjArray addObject:faceMsgDic];
                    
                    //出现的人脸都框选出来
                    JEFaceFocusView *allFaceView = [[JEFaceFocusView alloc] initWithFrame:faceObj.bounds];
                    allFaceView.layer.borderColor = [UIColor whiteColor].CGColor;
                    allFaceView.layer.borderWidth = 1;
                    [self.view addSubview:allFaceView];
                }
                
                NSLog(@"faceObjArray = %@", faceObjArray);
                
                /*
                 *  最佳的人脸数据，如果人脸数据不大于1，则唯一的即为最佳人脸数据
                 */
                int bestFaceID = [[NSString stringWithFormat:@"%@", [faceObjArray[0] objectForKey:@"ID"]] intValue];
                CGRect bestFaceRect = CGRectFromString([NSString stringWithFormat:@"%@", [faceObjArray[0] objectForKey:@"Bounds"]]);
                
                if (metadataObjects.count > 1) {
                    //遍历判断获取最小faceID的rect
                    for (int i = 0; i < metadataObjects.count; i++) {
                        if (bestFaceID > [[NSString stringWithFormat:@"%@", [faceObjArray[i] objectForKey:@"ID"]] intValue]) {
                            bestFaceID = [[NSString stringWithFormat:@"%@", [faceObjArray[i] objectForKey:@"ID"]] intValue];
                            bestFaceRect = CGRectFromString([NSString stringWithFormat:@"%@", [faceObjArray[i] objectForKey:@"Bounds"]]);
                        }
                    }
                }
                
                //最佳人脸框置为绿色
                JEFaceFocusView *_highlightView = [[JEFaceFocusView alloc] initWithFrame:bestFaceRect];
                _highlightView.layer.borderWidth = 1;
                _highlightView.layer.borderColor = MAIN_FACE_COLOR.CGColor;
                [self.view addSubview:_highlightView];
                
                //跟踪框存在，且数据不为空
                if ((bestFaceID != 0) && _highlightView) {

                    int curr = 5000;
                    int currX = 5000;
                    int Mid = 10000;
                    /*
                     先发左右y值得变化  再发上下x值的变化
                     */
                    /*
                     俯仰滚动范围，需要添加一个差值，差值在()范围内不发送数据
                     */
                    
                    /*
                     判断如果俯仰和横滚范围与中点差值范围在设定以内，就只发中点坐标
                     */
                    //语法糖，临时变量，水平不够，先这么解决了
                    CGFloat viewCenterX = self.view.center.x;
                    CGFloat highlightCenterX = _highlightView.center.x;
                    CGFloat DValueX = 20;
                    
                    CGFloat viewCenterY = self.view.center.y;
                    CGFloat highlightCenterY = _highlightView.center.y;
                    CGFloat DValueY = 20;
                    
                    if(highlightCenterX >= (viewCenterX - DValueX) && highlightCenterX <= (viewCenterX + DValueX) &&
                       highlightCenterY >= (viewCenterY - DValueY) && highlightCenterY <= (viewCenterY + DValueY)) {
                        highlightCenterX = viewCenterX;
                        highlightCenterY = viewCenterY;
                        NSLog(@"在中点范围附近");
                    }
                    
                    //前置后置的坐标处理，和硬件约定好的扩大10000倍
                    //先计算 y 的百分比，然后扩大系数倍，前置摄像头需要反向发送坐标值(10000*计算出的百分比)，后置摄像头不需要反向，直接发送坐标值
                    if ([_stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
                        curr = Mid - (highlightCenterY / self.view.frame.size.height * Mid);
                        currX = Mid - (highlightCenterX / self.view.frame.size.width * Mid);
                    }
                    if ([_stillCamera cameraPosition] == AVCaptureDevicePositionBack) {
                        curr = (highlightCenterY * Mid / self.view.frame.size.height);
                        currX = (highlightCenterX * Mid / self.view.frame.size.width);
                    }
                    
                    [[JEBluetoothManager shareBLESingleton] BPFaceMsgX:currX Y:curr];
                }
            }
        });
    }
}

//实时获取到对象跟踪框的位置
- (void)getROIFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CGFloat lx = _trackViewLTPoint.x;
    CGFloat rx = _trackViewRDPoint.x;
    
    CGFloat ly = _trackViewLTPoint.y;
    CGFloat ry = _trackViewRDPoint.y;
    
    CGFloat maxX = fmax(lx, rx);
    CGFloat minX = fmin(lx, rx);
    
    CGFloat maxY = fmax(ly, ry);
    CGFloat minY = fmin(ly, ry);
    
    CGPoint lp = CGPointMake(minX, minY);
    CGPoint rp = CGPointMake(maxX, maxY);
    
    //track
    if (lp.x != 0 && lp.y != 0 && rp.x != 0 && rp.y != 0 && _isObjectTracking && !_isObjTrackStart) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //画跟踪框
            NSLog(@"画跟踪框");
            _objectTrackingView.frame = CGRectMake(lp.x, lp.y, fabs(rp.x-lp.x), fabs(rp.y-lp.y));
        });
    }
    
//    if (_isObjTrackStart) {
        [self cmtTracking:sampleBuffer];
//    }
}

//物体跟踪
- (void)cmtTracking:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width =  CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    CGFloat minX = fmin(_trackViewLTPoint.x, _trackViewRDPoint.x);
    CGFloat minY = fmin(_trackViewLTPoint.y, _trackViewRDPoint.y);
    CGFloat maxX = fmax(_trackViewLTPoint.x, _trackViewRDPoint.x);
    CGFloat maxY = fmax(_trackViewLTPoint.y, _trackViewRDPoint.y);
    
    CGPoint lp;
    CGPoint rp;
    
    if([_stillCamera cameraPosition] == AVCaptureDevicePositionFront){
        lp = CGPointMake(minY*_mainRatioY, minX*_mainRatioX);
        rp = CGPointMake(maxY*_mainRatioY, maxX*_mainRatioX);
    }
    else if ([_stillCamera cameraPosition] == AVCaptureDevicePositionBack){
        lp = CGPointMake(minY*_mainRatioY, height-minX*_mainRatioX);
        rp = CGPointMake(maxY*_mainRatioY, height-maxX*_mainRatioX);
    }
    
    if (_isObjTrackReady) {
        //如果物体跟踪准备就绪，初始化
        BOOL vfix = NO;
        CGFloat tRatio = _mainRatio;
        
        if ((width/height) > (_mainFrameWidth/_mainFrameHeight)) {
            vfix = YES;
        }
        
        CGFloat fillfix = (width * (_mainFrameWidth / height)) / _mainFrameHeight;
        
        CGFloat fixFillMode = lp.x * tRatio;
        
        if(vfix){
            fixFillMode = width*tRatio/2.0 + (lp.x * tRatio - width*tRatio/2.0)/fillfix;
        }
        
        selectBox = cv::Rect(fixFillMode, rp.y*tRatio, (rp.x-lp.x)*tRatio, (lp.y-rp.y)*tRatio);
        
        CGRect ocRect =CGRectMake(selectBox.x, selectBox.y, selectBox.width, selectBox.height);
        
        int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"trackQ"] intValue];
        SRObjTracker = [[SRTrackingCore alloc] initTracker:ocRect imageBuffer:sampleBuffer compressRate:tRatio type:type];
        
        NSLog(@"cmt track init!");
        _isObjTrackStart = YES;
        _isObjTrackReady = NO;
        
        return;
    }
    
    if (_isObjTrackStart) {
        NSLog(@"cmt process...");
        //        cmtTracker->processFrame(img_gray);
//        oatFrame++;
        CGRect ocRect;
        
        //        if(oatFrame % 2 == 0){
        ocRect = [SRObjTracker track:sampleBuffer];
        ocRect = SRObjTracker.trackingRect;
        //        }
        if([SRObjTracker isLost]){
            
//            [self drawCVError:sampleBuffer];
            NSLog(@"cmt丢失");
            [[JEBluetoothManager shareBLESingleton] BPFaceMsgLoss];     //人脸丢失指令
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _objectTrackingView.layer.borderColor = [UIColor redColor].CGColor;
            });
//            @weakify(self)
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self)
                
//                self->trackingFrame.isLost = YES;
//            });
        }else{
//            @weakify(self)
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self)
//                self->trackingFrame.isLost = NO;
//            });
            [self drawCVRect:sampleBuffer rect:ocRect ratio:SRObjTracker.compressRatio size:CGSizeMake(width, height)];
        }
    }else{
        
    }
}

- (void)drawCVRect:(CMSampleBufferRef)sampleBuffer rect:(CGRect)rect ratio:(CGFloat)hRatio size:(CGSize)captureSzie {
    //    lastTrackingRect = [SRTrackingCore drawBufferRotateRect:sampleBuffer rotateRect:CGRectMake(rect.center.x, rect.center.y, rect.size.width, rect.size.height) ratio:hRatio lastRect:lastTrackingRect];
    
    BOOL vfix = false;
    
    if(captureSzie.width/captureSzie.height < _mainFrameWidth/_mainFrameHeight){
        vfix = false;
    }else{
        vfix = true;
    }
    
    CGFloat tRatio = _mainRatio;
    
    CGFloat ox;
    CGFloat oy;
    
    CGRect res;
    
    if([_stillCamera cameraPosition] == AVCaptureDevicePositionFront){
        NSLog(@"前摄");
        ox = rect.origin.x - (rect.size.width)/2.0;
        oy = rect.origin.y - (rect.size.height)/2.0 - rect.size.height;
        res = CGRectMake(oy/(_mainRatioX*tRatio), ox/(_mainRatioY*tRatio),
                         rect.size.height/(_mainRatioX*tRatio), rect.size.width/(_mainRatioY*tRatio));
        
    }else{
        NSLog(@"后摄");
        ox = rect.origin.x - rect.size.width/2.0;
        oy = rect.origin.y + rect.size.height/2.0;
        
        if(vfix){
            CGFloat ty = ox/(_mainRatioY*tRatio);
            CGFloat fillfix = (captureSzie.width*(_mainFrameWidth/captureSzie.height))/_mainFrameHeight;
            CGFloat fixFillMode = _mainFrameHeight/2.0 + (ty - _mainFrameHeight/2.0)*fillfix;
            
            res = CGRectMake(_mainFrameWidth-oy/(_mainRatioX*tRatio), fixFillMode, rect.size.height/(_mainRatioX*tRatio), rect.size.width/(_mainRatioY*tRatio));
            
        }else{
            res = CGRectMake(_mainFrameWidth-oy/(_mainRatioX*tRatio), ox/(_mainRatioY*tRatio), rect.size.height/(_mainRatioX*tRatio), rect.size.width/(_mainRatioY*tRatio));
            
        }
        
    }
    
//    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self)
        _objectTrackingView.frame = res;
        _objectTrackingView.layer.borderColor = [UIColor greenColor].CGColor;
//        resultPoint = CGPointMake(trackingFrame.center.x, trackingFrame.center.y);
//        if (trackMode==0) {
            //NSLog(@"发送对象跟踪的数据");
            int curr = 5000;
            int currX = 5000;
            int Mid = 10000;
            /*
             先发左右y值得变化  再发上下x值的变化
             */
            AVCaptureDevicePosition position = [_stillCamera cameraPosition];
            if (position == AVCaptureDevicePositionFront){
//                curr = Mid- int(trackingFrame.center.y*Mid/self.view.height);
//                currX = Mid- int(trackingFrame.center.x*Mid/self.view.width);
                curr = Mid - (_objectTrackingView.center.y * Mid / self.view.frame.size.height);
                currX = Mid - (_objectTrackingView.center.x * Mid / self.view.frame.size.width);
            }
            if (position == AVCaptureDevicePositionBack) {
//                curr = int(trackingFrame.center.y*Mid/self.view.height);
//                currX = int(trackingFrame.center.x*Mid/self.view.width);
                curr = (_objectTrackingView.center.y * Mid / self.view.frame.size.height);
                currX = (_objectTrackingView.center.x * Mid / self.view.frame.size.width);
            }
        
        [[JEBluetoothManager shareBLESingleton] BPFaceMsgX:currX Y:curr];
        
//        }
        
    });
    
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
//慢动作开始
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
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
    
    if (@available(iOS 10.0, *)) {
        [self.movieFileOutput setOutputSettings:nil forConnection:captureConnection];
        
        NSLog(@"慢动作开始录制");
    } else {
        // Fallback on earlier versions
    }
}

//慢动作录制完成
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"captureOutput = %@, \noutputFileURL = %@, \nconnections = %@", captureOutput, outputFileURL, connections);
    AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported]){
        [captureConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    
    AVAsset *asset = [AVAsset assetWithURL:outputFileURL];
    NSLog(@"asset = %@", asset);
    
//    if ([asset isKindOfClass:[AVComposition class]]) {
        AVAsset *videoAsset = asset;
        //AVMutableComposition是个容器，可以在里面添加和移除视频轨和音频轨
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        
        //媒体轨道，有音频轨和视频轨，可以插入各种素材
//        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
        //把视频数据插入到可变媒体轨道中，时间就是整个视频播放时间
//        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,  videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
        //这是媒体轨道中的一个视频，可以进行视频缩放和旋转等操作
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        
        //视频轨道，包含了所有的视频素材
//        AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
        //视频资源轨道，包含了视频创建时间，总时长，音量等等信息
        AVAssetTrack *assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        
//        mainInstruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
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
//        [videoLayerInstruction setTransform:assetTrack.preferredTransform atTime:kCMTimeZero];
//        [videoLayerInstruction setOpacity:0.0 atTime: videoAsset.duration];
    
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
    
        NSLog(@"mainCompositionInstrument = %@", mainCompositionInstrument);
        
        //Begin slow mo video export
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition
                                                                          presetName:AVAssetExportPreset1280x720];
        exporter.outputURL = outputFileURL;
        exporter.videoComposition = mainCompositionInstrument;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
    
        NSLog(@"exporter = %@", exporter);
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"exporter1 = %@, \nexpoter.status = %ld", exporter, (long)exporter.status);
            if (exporter.status == 3) {
                dispatch_async(saveImageQueue, ^{
                    @autoreleasepool {
                        NSLog(@"拍完的慢动作视频路径 = %@", exporter.outputURL);
                        NSData *movieData = [NSData dataWithContentsOfURL:exporter.outputURL];
                        if ([movieData writeToFile:[exporter.outputURL absoluteString] atomically:YES]) {
                            if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:exporter.outputURL size:[self getUserSaveVideoResolution]] toSandboxWithFileName:[NSString stringWithFormat:@"%@.png", _videoPreviewString]]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    SHOW_HUD_DELAY(NSLocalizedString(@"Saved", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                    NSLog(@"保存成功");
                                });
                            }
                            else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                    NSLog(@"保存视频预览图失败");
                                });
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                NSLog(@"保存原视频失败");
                            });
                        }
                    }
                });
            }
        }];
//    }
    
    NSLog(@"慢动作录制完成");
    /*
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[outputFileURL] options:nil];
    NSLog(@"fetchResult = %@", fetchResult);
    PHAsset *phAsset = fetchResult.firstObject;
    NSLog(@"phAsset = %@", phAsset);
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSLog(@"options = %@, asset = %@, audioMix = %@, info = %@", options, asset, audioMix, info);
            if ([asset isKindOfClass:[AVComposition class]]) {
                AVAsset *videoAsset = asset;
                
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
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = paths.firstObject;
                NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SlowVideo-%d.mov",arc4random() % 10000]];
                NSURL *url = [NSURL fileURLWithPath:myPathDocs];
                if ([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
                }
                //Begin slow mo video export
                AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition
                                                                                  presetName:AVAssetExportPreset1280x720];
                exporter.outputURL = url;
                exporter.videoComposition = mainCompositionInstrument;
                exporter.outputFileType = AVFileTypeQuickTimeMovie;
                exporter.shouldOptimizeForNetworkUse = YES;
                [exporter exportAsynchronouslyWithCompletionHandler:^{
                    if (exporter.status == 3) {
                        dispatch_async(saveImageQueue, ^{
                            @autoreleasepool {
                                NSLog(@"拍完的慢动作视频路径 = %@", exporter.outputURL);
                                NSData *movieData = [NSData dataWithContentsOfURL:exporter.outputURL];
                                if ([movieData writeToFile:[exporter.outputURL absoluteString] atomically:YES]) {
                                    if ([[JECameraManager shareCAMSingleton] saveVideoPreview:[self firstFrameWithVideoURL:exporter.outputURL size:[self getUserSaveVideoResolution]] toSandboxWithFileName:_videoPreviewString]) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SHOW_HUD_DELAY(NSLocalizedString(@"Saved", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                            NSLog(@"保存成功");
                                        });
                                    }
                                    else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                            NSLog(@"保存视频预览图失败");
                                        });
                                    }
                                }
                                else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                                        NSLog(@"保存原视频失败");
                                    });
                                }
                            }
                        });
                    }
                }];
            }
        }];
    }
     */
}

#pragma mark - JECamera Top && Middle && Bottom ToolBarDelegate
- (void)topToolBarButton:(UIButton *)button {
    switch (button.tag) {
        case 123:
            NSLog(@"返回首页");
            [self dismissViewControllerAnimated:YES completion:^{
                [[JEBluetoothManager shareBLESingleton] disconnectDevice];
            }];
            break;
            
        case 124:
            NSLog(@"滤镜");
            self.isFilterShowing = !_isFilterShowing;
            break;
            
        case 125:
            NSLog(@"美颜");
            self.isBeautyOpening = !_isBeautyOpening;
            break;
            
        case 126:
            NSLog(@"相机设置");
            self.isCameraSetting = !_isCameraSetting;
            break;
            
        case 127:
            NSLog(@"设备设置");
            self.isDeviceSetting = !_isDeviceSetting;
            break;
            
        default:
            break;
    }
}

/**
 取消跟踪状态
 */
- (void)cleanTrackState {
    if (_isFaceTracking) {
        self.isFaceTracking = NO;
    }
    if (_isObjectTracking) {
        self.isObjectTracking = NO;
    }
}

- (void)takeTrackMode:(UIButton *)sender {
    switch (sender.tag) {
        case 283:
        {
            //人脸跟踪
            if (_isObjectTracking) {
                self.isObjectTracking = NO;
            }
            if (_isFaceTracking) {
                return;
            }
            else {

                //如果在 移动延时 && 移动变焦 模式，不允许跟踪
                if (_shootingMode == videoLocusTimeLapse || _shootingMode == videoMovingZoom) {
                    SHOW_HUD_DELAY(NSLocalizedString(@"Tracking will not function in the current mode", nil), [UIApplication sharedApplication].keyWindow, 1.0);
                    return;
                }
                
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_middleToolBar.trackStay setImage:[UIImage imageNamed:@"icon_track_face_on"] forState:UIControlStateSelected];
                    _middleToolBar.trackStay.selected = YES;
                    _middleToolBar.trackView.hidden = YES;
                    self.isFaceTracking = YES;
                });
            }
        }
            break;
            
        case 284:
        {
            //物体跟踪
            if (_isFaceTracking) {
                self.isFaceTracking = NO;
            }
            if (_isObjectTracking) {
                return;
            }
            else {
                
                //在非 普通 && 延时拍摄 模式，不允许跟踪
                if (!(_shootingMode == videoNormal || _shootingMode == videoTimeLapse)) {
                    SHOW_HUD_DELAY(NSLocalizedString(@"Tracking will not function in the current mode", nil), [UIApplication sharedApplication].keyWindow, 1.0);
                    return;
                }
                
                if (!_isVideo) {
                    [self bottomToolBarButtonAction:222];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_middleToolBar.trackStay setImage:[UIImage imageNamed:@"icon_track_thing_on"] forState:UIControlStateSelected];
                    _middleToolBar.trackStay.selected = YES;
                    _middleToolBar.trackView.hidden = YES;
                    self.isObjectTracking = YES;
                });
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)bottomToolBarButtonAction:(NSInteger)buttonTag {
    switch (buttonTag) {
        case 222: {
            NSLog(@"切换拍摄模式");
            
            //判断 4k 不支持前置摄像头，4k 时自动切换成后置摄像头
            if (USER_GET_SaveVideoResolution_Integer == 2) {
                if ([_stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
                    self.isFrontCamera = NO;
                    SHOW_HUD_DELAY(NSLocalizedString(@"The front-facing camera does not support 4k resolution", nil), self.view, 2);
                }
            }
            
            [self changeStillcameraVideoResolution:!_isVideo];  //修改屏幕分辨率
            
            [self setVideoStabilizationMode];   //光学防抖
            
            //清空追踪状态
            if (_middleToolBar.trackStay.isSelected) {
                _middleToolBar.trackStay.selected = NO;
                [self cleanTrackState];
            }
            
            POPBasicAnimation *ani = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            ani.duration = 0.5;
            CGRect toValue;
            if (!_isVideo) {
                //录像
                _bottomToolBar.shootSwitchPhoto.image = [UIImage imageNamed:@"icon_shootSwitchPhoto"];
                _bottomToolBar.shootSwitchVideo.image = [UIImage imageNamed:@"icon_shootSwitchVideo_select"];
                
                _middleToolBar.trackStay.hidden = NO;
                
                //修改拍摄模式
                self.shootingMode = videoNormal;
                
                if (_mainRotate == 0) {
                    toValue = CGRectMake(_bottomToolBar.shootSwitchButton.frame.size.height, 0, _bottomToolBar.shootSwitchButton.frame.size.height, _bottomToolBar.shootSwitchButton.frame.size.height);
                }
                else {
                    toValue = CGRectMake(_bottomToolBar.shootSwitchButton.frame.size.width, 0, _bottomToolBar.shootSwitchButton.frame.size.width, _bottomToolBar.shootSwitchButton.frame.size.width);
                }
            }else{
                //拍照
                _bottomToolBar.shootSwitchPhoto.image = [UIImage imageNamed:@"icon_shootSwitchPhoto_select"];
                _bottomToolBar.shootSwitchVideo.image = [UIImage imageNamed:@"icon_shootSwitchVideo"];
                
                _middleToolBar.trackStay.hidden = YES;
                
                //修改拍摄模式
                self.shootingMode = picSingle;
                
                if (_mainRotate == 0) {
                    toValue = CGRectMake(0, 0, _bottomToolBar.shootSwitchButton.frame.size.height, _bottomToolBar.shootSwitchButton.frame.size.height);
                }
                else {
                    toValue = CGRectMake(0, 0, _bottomToolBar.shootSwitchButton.frame.size.width, _bottomToolBar.shootSwitchButton.frame.size.width);
                }
            }
            
            ani.toValue = [NSValue valueWithCGRect:toValue];
            
            [_bottomToolBar.shootSwitchTone pop_addAnimation:ani forKey:@"rect"];
            
            [self restoreZoom];
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            
            self.isVideo = !_isVideo;
        }
            break;
            
        case 223: {
            NSLog(@"菜单键");
            //拍摄模式菜单
            self.isSubShowing = !_isSubShowing;
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
        }
            break;
            
        case 224: {
            NSLog(@"快门");
            [self camStillAction];
        }
            break;
            
        case 225: {
            NSLog(@"切换镜头");
            //前后置摄像头切换
            if (_stillCamera.captureSessionPreset == AVCaptureSessionPreset3840x2160) {
                SHOW_HUD_DELAY(NSLocalizedString(@"The front-facing camera does not support 4k resolution", nil), self.view, 2);
                return;
            }
            
            self.isFrontCamera = !_isFrontCamera;
            
        }
            break;
            
        case 226: {
            NSLog(@"相册");
            JEAlbumViewController *picker = [[JEAlbumViewController alloc] init];
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
            break;
           
        case 233: {
            NSLog(@"拍照-单拍");
            self.shootingMode = picSingle;
        }
            break;
            
        case 234: {
            NSLog(@"拍照-全景");
            self.shootingMode = picPano90d;
        }
            break;
            
        case 235: {
            NSLog(@"拍照-九宫图");
            self.shootingMode = picNLSquare;
        }
            break;
            
            
        case 243:
        {
            //拍照单拍普通
            self.shootingMode = picSingle;
        }
            break;
            
        case 244:
        {
            //拍照单拍 1s
            self.shootingMode = picSingleDelay1s;
        }
            break;
            
        case 245:
        {
            //拍照单拍 2s
            self.shootingMode = picSingleDelay2s;
        }
            break;
            
        case 246:
        {
            //拍照单拍 3s
            self.shootingMode = picSingleDelay3s;
        }
            break;
            
        case 247:
        {
            //拍照单拍 4s
            self.shootingMode = picSingleDelay4s;
        }
            break;
            
        case 248:
        {
            //拍照单拍 5s
            self.shootingMode = picSingleDelay5s;
        }
            break;
            
        case 249:
        {
            //拍照单拍 10s
            self.shootingMode = picSingleDelay10s;
            
        }
            break;
            
        case 253:
        {
            //拍照全景 90d
            self.shootingMode = picPano90d;
        }
            break;
            
        case 254:
        {
            //拍照全景 180d
            self.shootingMode = picPano180d;
        }
            break;
            
        case 255:
        {
            //拍照全景 360d
            self.shootingMode = picPano360d;
        }
            break;
            
        case 256:
        {
            //拍照全景 3x3
            self.shootingMode = picPano3x3;
        }
            break;
            
        case 263:
        {
            //拍照九宫格模式一
            self.shootingMode = picNLSquare;
        }
            break;
            
        case 264:
        {
            //拍照九宫格模式二
            self.shootingMode = picNLRectangle;
        }
            break;
            
        case 273:
        {
            //录像普通
            self.shootingMode = videoNormal;
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            [self restoreZoom];
        }
            break;
            
        case 274:
        {
            //录像移动变焦
            self.shootingMode = videoMovingZoom;
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            
            _effectiveScale = 3.0;
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.1];
            AVCaptureDevice *captureDevice = self.stillCamera.inputCamera;
            NSError *error;
            if ([captureDevice lockForConfiguration:&error]) {
                [captureDevice rampToVideoZoomFactor:3.0 withRate:50.0f];
                [captureDevice unlockForConfiguration];
            }
            [CATransaction commit];
        }
            break;
            
        case 275:
        {
            //录像慢动作
            self.shootingMode = videoSlowMotion;
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            [self restoreZoom];
        }
            break;
            
        case 276:
        {
            //录像轨迹延时
            self.shootingMode = videoLocusTimeLapse;
            if (_isTimeLapseShowing) {
                self.isTimeLapseShowing = NO;
            }
            if (_isMotionLapseShowing == YES) {
                //告知设备退出移动延时模式
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            self.isMotionLapseShowing = !_isMotionLapseShowing;
            [self restoreZoom];
        }
            break;
            
        case 277:
        {
            //录像延时
            self.shootingMode = videoTimeLapse;
            if (_isMotionLapseShowing) {
                self.isMotionLapseShowing = NO;
                [[JEBluetoothManager shareBLESingleton] BPQuitMotionLapseMode];
                [_motionLapsePointArray removeAllObjects];
                _motionLapsePopView.pointPicArray = _motionLapsePointArray;
                [_motionLapsePopView.getPointTableView reloadData];
            }
            self.isTimeLapseShowing = !_isTimeLapseShowing;
            [self restoreZoom];
        }
            break;
        
        default:
            break;
    }
}

#pragma mark - JESearchDevicesViewDelegate
- (void)searchDeviceSelect:(CBPeripheral *)per {
    [[JEBluetoothManager shareBLESingleton] connectDeviceWithCBPeripheral:per];
}

#pragma mark - SR360CamFilterDelegate
//添加滤镜
- (void)process:(GPUImageFilter *)filter {
    NSLog(@"添加滤镜");
    if (_isBeautyOpening) {
        self.isBeautyOpening = NO;
    }
    
    self.cameraFilter = _filterSubIconView.currentFilter;
    self.captureFilter = self.cameraFilter;

    [_stillCamera  pauseCameraCapture];
    [_stillCamera  removeAllTargets];
    [_cameraFilter removeAllTargets];
    [_stillCamera  addTarget:_cameraFilter];
    [_cameraFilter addTarget:_cameraOutputView];
    [_stillCamera  addTarget:self.normalFilter];
    [_stillCamera  resumeCameraCapture];

    if (_filterSubIconView.currentIndex == 0) {
        _topToolBar.filterToolButton.selected = NO;
    }
    else {
        _topToolBar.filterToolButton.selected = YES;
    }
}

#pragma mark - JEVideoLocusTimeLapseViewDelegate
//拍摄轨迹延时的关键点照片
- (void)takePointPicWithMotionLapse {
    [self takePhotoWithMotionLapse];
}

#pragma mark - JECameraSettingDelegate
- (void)tableViewPushVC:(UIViewController *)pushVC {
    [self presentViewController:pushVC animated:YES completion:^{
        
    }];
}

//闪光灯设置
- (void)setCameraFlashMode:(NSInteger)mode {
    switch (mode) {
        case 0:
        {
            //闪光灯关闭
            NSError *err;
            [self.stillCamera.inputCamera lockForConfiguration:&err];
            
            if(!err){
                if([self.stillCamera.inputCamera isTorchModeSupported:AVCaptureTorchModeOff]){
                    [self.stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
                }
                [self.stillCamera.inputCamera unlockForConfiguration];
            }
            self.flashMode = flashModeOff;
        }
            break;
            
        case 1:
        {
            //闪光灯开启
            NSError *err;
            [self.stillCamera.inputCamera lockForConfiguration:&err];
            
            if(!err){
                if([self.stillCamera.inputCamera isTorchModeSupported:AVCaptureTorchModeOn]){
                    [self.stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                }
                [self.stillCamera.inputCamera unlockForConfiguration];
            }
            self.flashMode = flashModeOn;
        }
            break;
            
        case 2:
        {
            //闪光灯自动
            NSError *err;
            [self.stillCamera.inputCamera lockForConfiguration:&err];
            
            if(!err){
                if([self.stillCamera.inputCamera isTorchModeSupported:AVCaptureTorchModeAuto]){
                    [self.stillCamera.inputCamera setTorchMode:AVCaptureTorchModeAuto];
                }
                [self.stillCamera.inputCamera unlockForConfiguration];
            }
            self.flashMode = flashModeAuto;
        }
            break;
            
        default:
            break;
    }
    NSLog(@"当前闪光灯模式 = %d", self.flashMode);
}

//辅助线设置
- (void)setCameraAuxLineMode:(NSInteger)mode {
    [self setupAuxLineView];
}

//设备设置
- (void)deviceSettingMode:(NSInteger)mode {
    switch (mode) {
        case 2: {
            //加速度校准
            if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Acceleration Calibration", nil) message:NSLocalizedString(@"The consequences might be quite serious if acceleration calibration failed. Are you sure to continue to calibrate?", nil) preferredStyle:UIAlertControllerStyleAlert];
                
                [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    self.accelerationVC = [[SRMotionViewController alloc] init];
                    [self presentViewController:_accelerationVC animated:YES completion:nil];
                }]];
                
                [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController:alertC animated:YES completion:nil];
                
            }
            else {
                SHOW_HUD_DELAY(NSLocalizedString(@"Please connect the device", nil), self.view, 1.5);
            }
        }
            break;
            
        default:
            break;
    }
}

//分辨率设置
- (void)setCameraVideoResMode:(NSInteger)mode {
    [self changeStillcameraVideoResolution:_isVideo];
}

//固件升级按钮
- (void)deviceUpdateAction {
    if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
        //服务器版本大于本地固件版本时
        if ([self.deviceNewVersion compare:USER_GET_SaveVersionFirmware_NSString] == NSOrderedDescending || (USER_GET_SaveVersionFirmware_NSString == NULL)) {
            if (_isDeviceSetting) {
                self.isDeviceSetting = NO;
            }
            
            _updateFirmwareView = [[JEUpdateFirmwareView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, self.view.frame.size.width)];
            _updateFirmwareView.center = self.view.center;
            _updateFirmwareView.updateConfirmBtn.hidden = NO;
            _updateFirmwareView.updateCancelBtn.hidden = NO;
            _updateFirmwareView.progressView.hidden = YES;
            self.isClearViewShowing = YES;
            
            [_updateFirmwareView.updateTextView setText:self.deviceUpdateString];
            
            __block JESmartCameraViewController *blockSelf = self;
            
            //固件升级确认
            _updateFirmwareView.confirmBlock = ^{
                
                NSMutableArray *params = [NSMutableArray array];
                
                if (_controllerMode == cameraM1) {
                    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"ProdID", nil]];
                }
                else if (_controllerMode == cameraP1) {
                    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"ProdID", nil]];
                }
                
                [JEWebManager loadDataCenter:params methodName:@"SR_GetLastFirmwareBinData" result:^(NSDictionary *resultDic, NSString *error) {
                
                    _updateFirmwareDataString = resultDic[@"SOAP-ENV:Body"][@"NS1:SR_GetLastFirmwareBinDataResponse"][@"return"][@"__text"];
                    _updateFirmwareDataLength = [_updateFirmwareDataString length];
                    
                    if (_updateFirmwareDataLength != 0) {
                        //进入固件更新模式
                        [[JEBluetoothManager shareBLESingleton] BPEnterFirmwareUpdate];
                    }
                    else {
                        //固件更新内容为空
                        
                        SHOW_HUD_DELAY(NSLocalizedString(@"The current firmware upgrade package is empty. Please retrieve server data again.", nil), blockSelf.view, 1.5);
                        
                        return;
                    }
                }];
            };
            
            //固件升级取消
            _updateFirmwareView.cancelBlock = ^{
                [blockSelf.updateFirmwareView removeFromSuperview];
                blockSelf.isClearViewShowing = NO;
            };
            
            [self.view addSubview:_updateFirmwareView];
            [self screenRotate:nil];
        }
        else {
            SHOW_HUD_DELAY(NSLocalizedString(@"Your firmware version is up to date", nil), self.view, 1.0);
        }
    }
    else {
        SHOW_HUD_DELAY(NSLocalizedString(@"Please connect the device", nil), self.view, 1.5);
    }
}

//app 升级按钮
- (void)appUpdateAction {
    //检查系统是否有新版本
    [self checkNewVersion];
}

/**
 检查新版本
 */
- (void)checkNewVersion {
    //1.确定请求路径
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://47.52.17.78/AppUpdate/SwiftAppUpdate.txt"]];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    //3.获得会话对象，并设置代理
    _askSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //4.根据会话对象创建一个task 发送会话请求
    NSURLSessionDataTask *dataTask = [_askSession dataTaskWithRequest:request];
    //5.执行任务
    [dataTask resume];
}

- (void)filmCameraAction:(BOOL)on {
    self.isFilm = on;
    [self changeFilmRatio];
    if (on) {
        [self setupFilmCamera];
    }
    else {
        [self resetStillCamera];
    }
    [self changeStillcameraVideoResolution:_isVideo];
    [self getUserSaveVideoResolution];
    [self setupAuxLineView];
}

#pragma mark - NSURLSessionDataDelegate
//1.接收到服务器响应的时候调用该方法
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //在该方法中可以得到响应头信息，即response
    //注意：需要使用completionHandler回调告诉系统应该如何处理服务器返回的数据
    //默认是取消的
    /*
     NSURLSessionResponseCancel = 0,        默认的处理方式，取消
     NSURLSessionResponseAllow = 1,         接收服务器返回的数据
     NSURLSessionResponseBecomeDownload = 2,变成一个下载请求
     NSURLSessionResponseBecomeStream        变成一个流
     */
    
    completionHandler(NSURLSessionResponseAllow);
}

//2.接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    if (session == _askSession) {
        
        NSString *resultHexStr = [self convertDataToHexStr:data];
        
        NSString *serverStr = [self stringFromHexString:resultHexStr];

        NSString *serverVersionUpdate = [serverStr substringWithRange:NSMakeRange(1, 1)];
        
        if ([USER_GET_SaveVersionNewAPP_NSString compare:USER_GET_SaveVersionAPP_NSString] == NSOrderedDescending) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Version update", nil) message:NSLocalizedString(@"There is a new version update.", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *bundleId = infoDict[@"CFBundleIdentifier"];
                NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleId]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                            
                            NSInteger resultCount = [responseDict[@"resultCount"] integerValue];
                            if(resultCount == 1) {
                                NSArray *resultArray = responseDict[@"results"];
                                NSDictionary *result = resultArray.firstObject;
                                
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"trackViewUrl"]]];
                            }
                        });
                    }];
                    
                    [dataTask resume];
                    
                });
            }]];
            
            if ([serverVersionUpdate isEqualToString:@"F"]) {
                //非强制升级，增加取消键
                [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertC animated:YES completion:^{
                    if (_isDeviceSetting) {
                        self.isDeviceSetting = NO;
                    }
                }];
            });
        }
    }
}

//3.当请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error == nil)
    {
    }
    else {
        SHOW_HUD_DELAY(NSLocalizedString(@"Failed to request information from server", nil), self.view, 1.5);
    }
}

#pragma mark - JECustomFunctionViewDelegate
- (void)exitCustomFunctionView {
    self.isFunctionShowing = NO;
}

#pragma mark - Tools
-(BOOL)shouldAutorotate{
    
    return NO;
}

- (UIImage *)resetStillcameraProcessedPNG:(NSData *)processedPNG {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIImage *image = [UIImage imageWithData:processedPNG];
    UIGraphicsBeginImageContext(CGSizeMake(_filmFrameWidth, _filmFrameHeight));
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, _filmFrameWidth, _filmFrameHeight)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    NSLog(@"scaledImage = %@", scaledImage);
    return scaledImage;
}

- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 修改电影镜头适配的 ratio
 */
- (void)changeFilmRatio {
    DeviceType deviceType = [JEGetDeviceVersion deviceVersion];
    switch (deviceType) {
        case iPhone_XS_MAX:
        case iPhone_XR:
        case iPhone_XS:
        case iPhone_X:
        {
            _filmRatio = 1.03;
        }
            break;
        
        //iphone8 及以下
        default:
        {
            _filmRatio = 1.29;
        }
            break;
    }
    
    NSLog(@"_filmRatio = %f", _filmRatio);
    
}

/**
 固件升级触发重发机制
 */
- (void)updateFirmwareTimeAction {
    
    NSLog(@"触发重发第 %d 次", _updateFirmwareTimeCount);
    
    if (_updateFirmwareTimeCount > 3) {
        //超过三次收不到回执，清空计时器和计数器
        if (_updateFirmwareTimer.isValid) {
            [self.updateFirmwareTimer invalidate];
            self.updateFirmwareTimer = nil;
            _updateFirmwareTimeCount = 0;
        }
        
        //退出并断开蓝牙
//        [self dismissViewControllerAnimated:YES completion:^{
            [[JEBluetoothManager shareBLESingleton] disconnectDevice];
//        }];
    }
    else {
        
        NSString *currDataString = [_updateFirmwareDataString substringWithRange:NSMakeRange(0, 32)];
        
        [self doSomeWorkWithProgress];
        
        NSData *currData = [self convertHexStrToData:currDataString];
        
        NSUInteger len = [currData length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [currData bytes], len);
        
        if (_updateFirmwareBag == 0) {
            //重发第一包
            [[JEBluetoothManager shareBLESingleton] BPFirmwareUpdateFirstPacket:byteData];
        }
        else {
            //重发第二包
            [[JEBluetoothManager shareBLESingleton] BPFirmwareUpdateSecondPacket:byteData];
        }
        
        //计数器加一
        _updateFirmwareTimeCount++;
    }
}

/**
 判断是否支持光学防抖
 */
- (void)setVideoStabilizationMode {
    NSError *error;
    [self.stillCamera.inputCamera lockForConfiguration:&error];
    if (!error) {
        if ([_stillCamera.inputCamera.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeStandard]) {
            _stillCamera.videoCaptureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
            /*
             视频防抖动模式
             typedef NS_ENUM(NSInteger, AVCaptureVideoStabilizationMode) {
             AVCaptureVideoStabilizationModeOff       = 0,  // 视频防抖动模式关闭
             AVCaptureVideoStabilizationModeStandard  = 1,  // 视频防抖标准模式
             AVCaptureVideoStabilizationModeCinematic = 2,  // 视频防抖电影模式
             AVCaptureVideoStabilizationModeAuto      = -1, // 视频防抖自动模式
             } NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
             */
        }
        else {
            _stillCamera.videoCaptureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
        }
        
        [self.stillCamera.inputCamera unlockForConfiguration];
    }
}

//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/**
 获取视频分辨率
 */
- (void)getVideoResolution {
    
    self.videoResolutionArray = [[NSMutableArray alloc] init];
    
//    if ([_stillCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
//        [_videoResolutionArray addObject:@{@"option":@"640x480"}];
//        _highestResolution = AVCaptureSessionPreset640x480;
//    }
    if ([_stillCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_videoResolutionArray addObject:@{@"option":@"1280x720"}];
        _highestResolution = AVCaptureSessionPreset1280x720;
    }
    if ([_stillCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [_videoResolutionArray addObject:@{@"option":@"1920x1080"}];
        _highestResolution = AVCaptureSessionPreset1920x1080;
    }
    if (@available(iOS 9.0, *)) {
        if ([_stillCamera.captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
            [_videoResolutionArray addObject:@{@"option":@"3840x2160"}];
            _highestResolution = AVCaptureSessionPreset3840x2160;
        }
    }
    NSLog(@"当前相机支持的分辨率为 = %@", _videoResolutionArray);
}

/**
 获取用户当前选择的分辨率尺寸

 @return 尺寸
 */
- (CGSize)getUserSaveVideoResolution {
    NSInteger videoResolutionInteger = USER_GET_SaveVideoResolution_Integer;
    switch (videoResolutionInteger) {
        case 0:
        {
            if (_isFilm) {
                _filmFrameWidth = 720 / _filmRatio;
                _filmFrameHeight = 1280;
                
                return CGSizeMake(_filmFrameWidth, _filmFrameHeight);
            }
            else {
                return CGSizeMake(720, 1280);
            }
        }
            
            break;
            
        case 1:
        {
            if (_isFilm) {
                _filmFrameWidth = 1080 / _filmRatio;
                _filmFrameHeight = 1920;
                
                return CGSizeMake(_filmFrameWidth, _filmFrameHeight);
            }
            else {
                return CGSizeMake(1080, 1920);
            }
        }
            
            break;
            
        case 2:
        {
            if (_isFilm) {
                _filmFrameWidth = 2160 / _filmRatio;
                _filmFrameHeight = 3840;
                
                return CGSizeMake(_filmFrameWidth, _filmFrameHeight);
            }
            else {
                return CGSizeMake(2160, 3840);
            }
        }
            
            break;
            
        default:
            return CGSizeMake(0, 0);
            break;
            
    }
}

/**
 修改当前屏幕的分辨率

 @param video 是否在录像模式
 */
- (void)changeStillcameraVideoResolution:(BOOL)video {
    if (video) {
        NSInteger videoResolutionInt = USER_GET_SaveVideoResolution_Integer;
        switch (videoResolutionInt) {
            case 0:
                if (_stillCamera.captureSessionPreset != AVCaptureSessionPreset1280x720) {
                    self.stillCamera.captureSessionPreset = AVCaptureSessionPreset1280x720;
                }
                break;
                
            case 1:
                if (_stillCamera.captureSessionPreset != AVCaptureSessionPreset1920x1080) {
                    self.stillCamera.captureSessionPreset = AVCaptureSessionPreset1920x1080;
                }
                break;
                
            case 2:
                if (_stillCamera.captureSessionPreset != AVCaptureSessionPreset3840x2160) {
                    self.stillCamera.captureSessionPreset = AVCaptureSessionPreset3840x2160;
                }
                break;
                
            default:
                break;
        }
    }
    else {
        if (_isFilm) {
            if (_stillCamera.captureSessionPreset != _highestResolution) {
                self.stillCamera.captureSessionPreset = _highestResolution;
            }
        }
        else {
            if (_stillCamera.captureSessionPreset != AVCaptureSessionPresetPhoto) {
                self.stillCamera.captureSessionPreset = AVCaptureSessionPresetPhoto;
            }
        }
    }
    //修改跟踪的分辨率
    [self configRatioByNotify];
}

//更改录制时间字符串
-(NSString *)getMMSSFromSS:(NSUInteger)sec {
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",sec/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(sec%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",sec%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

/**
 获取视频第一帧图片

 @param url 视频地址
 @param size 视频尺寸
 @return 视频第一帧图片
 */
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size {
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

//复原zoom的大小 : 1.0表示缩放回原来的大小
- (void)restoreZoom{
    //显式事务
    //修改执行时间
    [CATransaction begin];
    //动画执行时间
    [CATransaction setAnimationDuration:0.1];
    AVCaptureDevice *captureDevice = self.stillCamera.inputCamera;
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        [captureDevice rampToVideoZoomFactor:1.0 withRate:50.0f];
        [captureDevice unlockForConfiguration];
    }
    [CATransaction commit];
}

/**
 图片方向矫正
 
 @param image 需要矫正的图片
 @param orientation 图片当前的方向
 @return 矫正后的图片
 */
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 33 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

//修正视频方向
- (void)fixVideoOrientation:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    NSInteger degress;
    
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if (t.a == 1 && t.b == 0 && t.c == 0 && t.d == 1) {
            degress = 0;
        }
    }
    
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    CGAffineTransform t1;
    CGAffineTransform t2;
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    if (!_mutableComposition) {
        // Check whether a composition has already been created, i.e, some other tool has already been applied
        // Create a new composition
        _mutableComposition = [AVMutableComposition composition];
        // Insert the video and audio tracks from AVAsset
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [_mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [_mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        }
    }
    // Step 2
    // Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
//    t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.height, 0.0);
    // Rotate transformation
//    t2 = CGAffineTransformRotate(t1, degreesToRadians(90));
    if (degress == 0) {
        t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(0));
    }
    
    // Step 3
    // Set the appropriate render sizes and rotational transforms
    if (!_mutableVideoComposition) {
        // Create a new video composition
        _mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        if (degress == 0 || degress == 180) {
            _mutableVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
        }else{
            _mutableVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
        }
        _mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        // The rotate transform is set on a layer instruction
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [_mutableComposition duration]);
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(_mutableComposition.tracks)[0]];
        [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    } else {
        _mutableVideoComposition.renderSize = CGSizeMake(_mutableVideoComposition.renderSize.height, _mutableVideoComposition.renderSize.width);
        // Extract the existing layer instruction on the mutableVideoComposition
        instruction = (_mutableVideoComposition.instructions)[0];
        layerInstruction = (instruction.layerInstructions)[0];
        // Check if a transform already exists on this layer instruction, this is done to add the current transform on top of previous edits
        CGAffineTransform existingTransform;
        if (![layerInstruction getTransformRampForTime:[_mutableComposition duration] startTransform:&existingTransform endTransform:NULL timeRange:NULL]) {
            [layerInstruction setTransform:t2 atTime:kCMTimeZero];
        } else {
            // Note: the point of origin for rotation is the upper left corner of the composition, t3 is to compensate for origin
            CGAffineTransform t3 = CGAffineTransformMakeTranslation(-1*assetVideoTrack.naturalSize.height/2, 0.0);
            CGAffineTransform newTransform = CGAffineTransformConcat(existingTransform, CGAffineTransformConcat(t2, t3));
            [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
        }
    }
    // Step 4
    // Add the transform instructions to the video composition
    instruction.layerInstructions = @[layerInstruction];
    _mutableVideoComposition.instructions = @[instruction];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPreset1280x720];
    exportSession.videoComposition = _mutableVideoComposition;
    exportSession.outputURL = videoURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"转换视频成功 : %ld", (long)exportSession.status);
        }
        else {
            NSLog(@"转换视频失败 : %ld", (long)exportSession.status);
        }
        
    }];
    
    
//    NSLog(@"assetTrack = %@, videoTransform(a,b,c,d)(tx,ty) = (%f, %f, %f, %f)(%f, %f);", assetTrack, videoTransform.a, videoTransform.b, videoTransform.c, videoTransform.d, videoTransform.tx, videoTransform. ty);
}

//给图片画上九宫格
- (UIImage *)niceLattice:(UIImage *)image{
    NSLog(@"给图片画上九宫格");
    UIImage *resizeImage;
    CGFloat iw = image.size.width;
    CGFloat ih = image.size.height;
    if (iw > ih) {
        CGFloat H =  (iw - ih)/2;
        CGImageRef cgimage =CGImageCreateWithImageInRect([image CGImage], CGRectMake(H,0, ih, ih));
        resizeImage = [[UIImage alloc] initWithCGImage:cgimage scale:1 orientation:image.imageOrientation];
        CGImageRelease(cgimage);
    } else {
        CGFloat H =  (ih - iw)/2;
        CGImageRef cgimage =CGImageCreateWithImageInRect([image CGImage], CGRectMake(0,H, iw, iw));
        resizeImage = [[UIImage alloc] initWithCGImage:cgimage scale:1 orientation:image.imageOrientation];
        CGImageRelease(cgimage);
    }
    NSLog(@"返回来的九宫格图片 = %@", resizeImage);
    return resizeImage;
}

//设置自动曝光和聚焦
- (void)resetFocusAndExposureModes{
    /*
    AVCaptureDevice *device = self.stillCamera.inputCamera;
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    }
    else{
        
        return NO;
    }
     */
    NSError *err;
    
    [self.stillCamera.inputCamera lockForConfiguration:&err];
    
    if(!err){
        if([self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [self.stillCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if([self.stillCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]){
            [self.stillCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        if([self.stillCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
            [self.stillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        [self.stillCamera.inputCamera unlockForConfiguration];
    
    }
}

- (void)intresPointOfFocusAndExplosure:(CGPoint)interesPoint {
    NSError *error;
    [_stillCamera.inputCamera lockForConfiguration:&error];
    if(!error){
        if(_stillCamera.inputCamera.isFocusPointOfInterestSupported){
            _stillCamera.inputCamera.focusPointOfInterest = interesPoint;
            _stillCamera.inputCamera.focusMode = AVCaptureFocusModeAutoFocus;
            
        }
        
        if(_stillCamera.inputCamera.isExposurePointOfInterestSupported){
            _stillCamera.inputCamera.exposurePointOfInterest = interesPoint;
            _stillCamera.inputCamera.exposureMode = AVCaptureExposureModeAutoExpose;
            
        }
        
        [_stillCamera.inputCamera unlockForConfiguration];
    }
}

//16进制字符串转10进制字符串
- (NSString *)numberHexString:(NSString *)aHexString
{
    // 为空,直接返回.
    if (nil == aHexString)
    {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    
    unsigned long long longlongValue;
    
    [scanner scanHexLongLong:&longlongValue];
    
    NSString *str = [NSString stringWithFormat:@"%llu",longlongValue];
    
    return str;
}

//16进制字符串转data
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];// 接收到的数据：<ff0a000a 14>
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

/**
 data转字符串

 @param data data类型
 @return 字符串类型
 */
- (NSString *)convertDataToHexStr:(NSData *)data{
    
    if (!data || [data length] == 0) {
        
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

/**
 十六进制转换为普通字符串

 @param hexString 十六进制
 @return 十进制字符串
 */
- (NSString *)stringFromHexString:(NSString *)hexString {
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    
    return unicodeString;
}

/**
 更新固件升级进度条
 */
- (void)doSomeWorkWithProgress{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float  progress = 1.0f - (float)[_updateFirmwareDataString length]/(float)_updateFirmwareDataLength;
        
        [_updateFirmwareView.progressView setProgess:progress];
        
        float por = progress * 100;

    });
}

//全景合成
-(sr::SRStitcher::Status)getWrapImageAndMask
{
    std::vector<cv::Mat> matImages;
    
    BOOL savePano = [[NSUserDefaults standardUserDefaults]boolForKey:@"SavaOrignPano"];         //保存全景照片原图
    
    if(savePano){
        [[NSNotificationCenter defaultCenter] postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.05), @"hint":NSLocalizedString(@"SaveingOrigin pano images...", nil)}];
        
        NSUInteger panoIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"panoIndex"];
        
        NSString *panoDir = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/panos/%lu", (unsigned long)panoIndex];
        
        NSError *error;
        if(![[NSFileManager defaultManager] fileExistsAtPath:panoDir isDirectory:nil]){
            [[NSFileManager defaultManager] createDirectoryAtPath:panoDir withIntermediateDirectories:true attributes:nil error:&error];
        }else{
            error = [NSError errorWithDomain:@"dir exit" code:-1 userInfo:nil];
        }
        if(!error){
            for(int cnt=0; cnt<self.panoImagesArray.count; cnt++){
                @autoreleasepool {
                    //UIImage保存压缩 UIImageJPEGRepresentation第二个参数，是压缩比
                    //后期优化时通过再次压缩以防止内存溢出而导致的崩溃
                    NSString *savePath = [panoDir stringByAppendingFormat:@"/%d.jpg", cnt];
                    NSData *imageData = UIImageJPEGRepresentation(self.panoImagesArray[cnt], 0.8);
                    NSInteger len = imageData.length / 1024;
                    NSLog(@"全景照片保存压缩后，图片大小 : %ld", len);
                    [imageData writeToFile:savePath atomically:YES];
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.1), @"hint":NSLocalizedString(@"Preparing images...", nil)}];
    
    int panoQ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"panoQ"] intValue];
    CGFloat quality = 0.1;
    
    switch (panoQ) {
        case 0:
        {
            //high
            //                quality = self.fullPano?0.3:0.5;
            quality = 0.8;
            
        }
            break;
        case 1:
        {
            //medium
            //                quality = self.fullPano?0.2:0.4;
            quality = 0.6;
            
        }
            break;
        case 2:
        {
            //low
            //                quality = self.fullPano?0.2:0.3;
            quality = 0.4;
            
        }
            break;
        default:
            break;
    }
    
    for(UIImage *img in self.panoImagesArray){
        UIImage *ci = [self compressedToRatio:img ratio:quality];
        cv::Mat matImage = [ci CVMat3];
        matImages.push_back(matImage);
    }
    
    sr::SRStitcher stitcher = sr::SRStitcher::createDefault(false);
    stitcher.setRegistrationResol(0.1);
    
    sr::SRStitcher::Status status = stitcher.getWrapImageAndMask(matImages, warpImageCnt);
    
    for(int i=0; i<matImages.size(); i++){
        cv::Mat m = matImages[i];
        m.release();
    }
    std::vector <cv::Mat>().swap(matImages);
    
    return status;
}

-(void)panoprogress:(NSNotification *)notify
{
    NSDictionary *dic = notify.object;
    float progress = [dic[@"progress"] floatValue];
    NSString *hint = dic[@"hint"];
    [self updatePanoProgressAndHint:progress hint:hint];
}

-(void)updatePanoProgressAndHint:(float)progress hint:(NSString *)hint
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _panoProgressView.progress = progress;
        _panoHint.text = hint;
    });
}

- (UIImage *)compressedToRatio:(UIImage *)img ratio:(float)ratio {
    UIGraphicsBeginImageContext(CGSizeMake(img.size.width * ratio, img.size.height * ratio));
    [img drawInRect:CGRectMake(0, 0, img.size.width * ratio, img.size.height * ratio)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(void)Blend:(NSArray *)srcName maskNames:(NSArray *)maskNames points:(NSArray *)points
{
    CGFloat minx = 0.0, maxx = 0.0;
//    CGFloat miny, maxy;
    
    int lastIndex = 0;
    int firstIndex = 0;
    
    for(int index=0; index<points.count; index++){
        CGPoint mp = [points[index]CGPointValue];
        
        minx = fmin(mp.x, minx);
        maxx = fmax(mp.x, maxx);
        if(maxx == mp.x){
            lastIndex = index;
        }else{
            firstIndex = index;
        }
    }
    
    for(int index=0; index<maskNames.count; index++){
        int type = 1;
        
        if(index == firstIndex)
            type = 0;
        
        if(index == lastIndex)
            type = 2;
        
        [self blendImage:srcName mask:maskNames index:index type:type];
    }
}

-(void)blendImage:(NSArray *)srcName mask:(NSArray *)maskNames index:(int)index type:(int)type
{
    @autoreleasepool {
        UIImage *overlayImage = [UIImage imageWithContentsOfFile:srcName[index]];
        UIImage *backgroundImage;
        
        backgroundImage = [UIImage imageWithContentsOfFile:maskNames[index]];
        
        CGFloat imgRatio = overlayImage.size.width/overlayImage.size.height;
        
        if(imgRatio < 2.0){
            backgroundImage = [self getMaskFromContextWithbound:CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height) type:type];
        }
        
        CIImage *moi2 = [CIImage imageWithCGImage:overlayImage.CGImage];
        CIImage *gradimage = [CIImage imageWithCGImage:backgroundImage.CGImage];
        
        CIFilter* blend = [CIFilter filterWithName:@"CIBlendWithMask"];
        [blend setValue:moi2 forKey:@"inputImage"];
        [blend setValue:gradimage forKey:@"inputMaskImage"];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = blend.outputImage;
        
        CGImageRef image = [context createCGImage:outputImage fromRect:outputImage.extent];
        UIImage *blendedImage = [UIImage imageWithCGImage:image];
        CGImageRelease(image);
        
        NSData *imageData = UIImagePNGRepresentation(blendedImage);
        [imageData writeToFile:[FileUtils blendImagePath:index] atomically:YES];
    }
}

-(UIImage *)getMaskFromContextWithbound:(CGRect)bounds type:(int)type
{
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradeRef = nullptr;
    
    if(type == 1){
        gradeRef = CGGradientCreateWithColorComponents(colorSpace,
                                                       (CGFloat[]){
                                                           0.0f, 0.0f, 0.0f, 1.0f,
                                                           1.0f, 1.0f, 1.0f, 1.0f,
                                                           1.0f, 1.0f, 1.0f, 1.0f,
                                                           0.0f, 0.0f, 0.0f, 1.0f
                                                       },
                                                       (CGFloat[]){
                                                           0.0f,
                                                           0.25f,
                                                           0.75f,
                                                           1.0f
                                                       }, 4);
    }else if(type == 0){
        gradeRef = CGGradientCreateWithColorComponents(colorSpace,
                                                       (CGFloat[]){
                                                           1.0f, 1.0f, 1.0f, 1.0f,
                                                           0.0f, 0.0f, 0.0f, 1.0f
                                                       },
                                                       (CGFloat[]){
                                                           0.75f,
                                                           1.0f
                                                       }, 2);
    }else{
        gradeRef = CGGradientCreateWithColorComponents(colorSpace,
                                                       (CGFloat[]){
                                                           0.0f, 0.0f, 0.0f, 1.0f,
                                                           1.0f, 1.0f, 1.0f, 1.0f
                                                       },
                                                       (CGFloat[]){
                                                           0.0f,
                                                           0.25f,
                                                       }, 2);
        
    }
    
    CGContextDrawLinearGradient(context, gradeRef, CGPointMake(0.0, bounds.size.height/2.0), CGPointMake(bounds.size.width, bounds.size.height/2.0), kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradeRef);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage *)Compose:(NSArray *)imagesName points:(NSArray *)points sizes:(NSArray *)sizes
{
    CGFloat minx, maxx;
    CGFloat miny, maxy;
    CGFloat minW, maxW;
    CGFloat minH, maxH;
    
    CGPoint firstPoint = [points[points.count-1] CGPointValue];
    minx = maxx = firstPoint.x;
    maxy = miny = firstPoint.y;
    minH = maxW = minW = maxH = 0;
    int lastIndex = 0;
    int firstIndex = 0;
    
    for(int index=0; index<points.count; index++){
        CGPoint mp = [points[index]CGPointValue];
        CGSize size = [sizes[index]CGSizeValue];
        
        minx = fmin(mp.x, minx);
        maxx = fmax(mp.x, maxx);
        if(maxx == mp.x){
            lastIndex = index;
        }else{
            firstIndex = index;
        }
        
        
        miny = fmin(mp.y, miny);
        maxy = fmax(mp.y, maxy);
        
        minW = fmin(minW, size.width);
        minH = fmin(minH, size.height);
        
        maxW = fmax(maxW, size.width);
        maxH = fmax(maxH, size.height);
    }
    
    firstPoint = [points[firstIndex] CGPointValue];
    
    //suppose its cycline pano
    CGFloat markWidth = maxx-minx+[sizes[lastIndex]CGSizeValue].width;
    CGFloat height = maxH;
    CGFloat width = fmax(markWidth, maxW);
    
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    
    for(NSUInteger i=0; i<points.count; i++){
        
        UIImage *img = [UIImage imageWithContentsOfFile:imagesName[i]];
        CGPoint CVPoint = [points[i]CGPointValue];
        CGPoint drawPoint;
        
        if(i == firstIndex){
            drawPoint = CGPointMake(0, 0);
        }else{
            drawPoint = CGPointMake(CVPoint.x-firstPoint.x, CVPoint.y-firstPoint.y);
        }
        
        CGSize size = [sizes[i]CGSizeValue];
        
        [img drawInRect:CGRectMake(drawPoint.x, drawPoint.y, size.width, size.height)];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}



@end
