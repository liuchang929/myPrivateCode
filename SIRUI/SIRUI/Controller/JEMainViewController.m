//
//  JEMainViewController.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/21.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import "JEMainViewController.h"
#import "JESearchDevicesView.h"
#import "JEBluetoothManager.h"
#import "POP.h"
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "StrokeCircleLayerConfigure.h"
#import "EnterCameraButton.h"
#import "JESmartCameraViewController.h"
#import <Masonry.h>

#define SAFE_SPACING 50     //安全间隔

@interface JEMainViewController ()<EnterCameraButtonDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) JESearchDevicesView   *searchDevicesView;         //搜索设备 View
@property (nonatomic, strong) CBPeripheral          *willConnectPeripheral;     //准备连接的设备
@property (nonatomic, strong) UIView                *obscuredView;              //遮挡 view
@property (nonatomic, strong) NSArray               *deviceNameArray;           //设备名字数组
@property (nonatomic, strong) NSArray               *deviceGIFNameArray;        //设备 gif 数组
@property (nonatomic, strong) EnterCameraButton     *enterCameraBtn;            //进入相机按钮
@property (nonatomic, strong) UIScrollView          *searchDevicesScrollView;   //搜索设备的 scrollView
@property (nonatomic, strong) UIPageControl         *pageControl;               //提示小圆点
@property (nonatomic, strong) UIWebView             *deviceWebView;             //搜索设备的 gif 图
@property (nonatomic, strong) UITableView           *deviceTableView;           //搜索设备的列表
@property (nonatomic, strong) UIView                *deviceBackgroundView;      //搜索设备背景图
@property (nonatomic, strong) UILabel               *countDownLabel;            //倒计时 label

//DATA
@property (nonatomic, strong) NSMutableArray        *dArray;
//关键字 "Name" "Mac" "Gif"

@property (nonatomic, strong) NSMutableArray        *flashDevicesArray;         //暂时存储当次循环内的设备计算列表
@property (nonatomic, strong) NSMutableArray        *flashDevicesTitleArray;    //暂时存储当次循环内的设备对外名字列表
@property (nonatomic, strong) NSMutableArray        *flashDevicesNameArray;     //暂时存储当次循环内的设备内部名字列表
@property (nonatomic, strong) NSMutableArray        *flashDevicesMacArray;      //暂时存储当次循环内的设备 MAC 地址列表
@property (nonatomic, strong) NSMutableArray        *flashDevicesGIFArray;      //暂时存储当次循环内的设备 GIF 名字列表
@property (nonatomic, strong) NSArray               *readySandDevicesArray;     //准备好要发送的名字数组
@property (nonatomic, strong) NSMutableArray        *comparisonDevicesArray;    //对比前后的设备列表
@property (nonatomic, strong) NSTimer               *autoConnectCountdown;      //自动连接倒计时
@property (nonatomic, strong) NSURLSession          *askSession;                //网络升级请求
@property (nonatomic, assign) int                   autoConnectTimes;           //倒计时次数
@property (nonatomic, assign) BOOL                  isXP3;                      //连接的设备是不是 XP3

@end

@implementation JEMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [JEBluetoothManager shareBLESingleton].delegate = self;    //蓝牙代理
    [JEBluetoothManager shareBLESingleton].peripheralName = DEVICE_NAME_ARRAY;
    [[JEBluetoothManager shareBLESingleton] getBLEState];
    [[JEBluetoothManager shareBLESingleton] initCentralManager];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;    //状态栏颜色
    
    //加载设备类型数据
    [self loadDeviceArrayData];
    
    //检查系统是否有新版本
    [self checkNewVersion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //SIRUI LOGO
    {
        FBShimmeringView *shimmeringView           = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        shimmeringView.center = CGPointMake(self.contentView.center.x, self.contentView.center.y - 150);
        shimmeringView.shimmering                  = YES;
        shimmeringView.shimmeringBeginFadeDuration = 0.5;
        shimmeringView.shimmeringOpacity           = 10.0;
        [self.contentView addSubview:shimmeringView];
        
        UILabel *logoLabel         = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
        logoLabel.text             = @"SIRUI";
        logoLabel.font             = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60.0];
        logoLabel.textColor        = MAIN_TEXT_COLOR;
        logoLabel.textAlignment    = NSTextAlignmentCenter;
        logoLabel.backgroundColor  = [UIColor clearColor];
        
        shimmeringView.contentView = logoLabel;
    }
    
    //靠近设备提示
    {
        FBShimmeringView *shimmeringView2 = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, HEIGHT/2 - 90, WIDTH, 20)];
        shimmeringView2.shimmering = YES;
        shimmeringView2.shimmeringBeginFadeDuration = 0.5;
        shimmeringView2.shimmeringOpacity           = 10.0;
        [self.contentView addSubview:shimmeringView2];
        
        UILabel *tintLabel         = [[UILabel alloc] initWithFrame:shimmeringView2.bounds];
        tintLabel.text             = NSLocalizedString(@"Please close to the device", nil);
        tintLabel.font             = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0];
        tintLabel.textColor        = MAIN_BLUE_COLOR;
        tintLabel.textAlignment    = NSTextAlignmentCenter;
        tintLabel.backgroundColor  = [UIColor clearColor];
        
        shimmeringView2.contentView = tintLabel;
    }
    
    //圆环
    {
        FBShimmeringLayer *shimmeringLayer          = [FBShimmeringLayer layer];
        shimmeringLayer.frame                       = (CGRect){CGPointZero, CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)};
        shimmeringLayer.position                    = CGPointMake(self.contentView.center.x + (self.contentView.frame.size.width - (130 + 1.5)*2)/2, self.contentView.center.y - 70);
        shimmeringLayer.shimmering                  = YES;
        shimmeringLayer.shimmeringBeginFadeDuration = 0.5;
        shimmeringLayer.shimmeringOpacity           = 10.0;
        shimmeringLayer.shimmeringPauseDuration     = 0.9f;
        [self.contentView.layer addSublayer:shimmeringLayer];
        
        CAShapeLayer *circleShape          = [CAShapeLayer layer];
        StrokeCircleLayerConfigure *config = [StrokeCircleLayerConfigure new];
        config.lineWidth                   = 1.5f;
        config.startAngle                  = 0;
        config.endAngle                    = M_PI * 2;
        config.radius                      = 130.f;
        config.strokeColor                 = MAIN_BLUE_COLOR;
        [config configCAShapeLayer:circleShape];
        
        shimmeringLayer.contentLayer = circleShape;

    }
    
    //进入相机按钮
    {
        self.enterCameraBtn = [[EnterCameraButton alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
            _enterCameraBtn.font     = [UIFont systemFontOfSize:14.f];
            _enterCameraBtn.delegate = self;
        
            _enterCameraBtn.normalTextColor    = MAIN_TEXT_COLOR;
            _enterCameraBtn.highlightTextColor = MAIN_TEXT_COLOR;
            _enterCameraBtn.animationColor     = MAIN_BLUE_COLOR;
        
            _enterCameraBtn.animationWidth     = 250;
            _enterCameraBtn.text               = NSLocalizedString(@"Click to activate the camera app", nil);
    
        [self.windowView addSubview:self.enterCameraBtn];
        [self.enterCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(280);
            make.height.mas_equalTo(30);
            make.centerY.equalTo(self.contentView.mas_centerY).with.offset(HEIGHT/4);
        }];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;    //状态栏颜色
    
    [self clearPopView];
    
    [[JEBluetoothManager shareBLESingleton] stopScanDevice];
}

#pragma mark - LazyLoading
- (UIView *)obscuredView {
    if (!_obscuredView) {
        self.obscuredView = [[UIView alloc] initWithFrame:CGRectMake(0, - SAFE_SPACING, self.contentView.frame.size.width, HEIGHT)];
            _obscuredView.backgroundColor = [UIColor blackColor];
            _obscuredView.alpha           = 0.2;
            _obscuredView.center          = self.windowView.center;
        [self.contentView addSubview:self.obscuredView];
    }
    return _obscuredView;
}

- (void)setupDeviceBackgroundView {
    if (!_deviceBackgroundView) {
        int num = HEIGHT > 811.0 ? 5 : 3;
        self.deviceBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(SAFE_SPACING, HEIGHT, self.contentView.frame.size.width - 2 * SAFE_SPACING, self.contentView.frame.size.height - num * SAFE_SPACING)];
            _deviceBackgroundView.layer.cornerRadius    = 20;
            _deviceBackgroundView.layer.masksToBounds   = YES;
            _deviceBackgroundView.backgroundColor       = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

        //滚动视图
        if (!_searchDevicesScrollView) {
            self.searchDevicesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.deviceBackgroundView.frame.size.width, self.deviceBackgroundView.frame.size.height - 2 * SAFE_SPACING)];
                _searchDevicesScrollView.delegate = self;
                _searchDevicesScrollView.pagingEnabled = YES;
                _searchDevicesScrollView.bounces = NO;
                _searchDevicesScrollView.scrollEnabled = YES;
                _searchDevicesScrollView.userInteractionEnabled = YES;
                _searchDevicesScrollView.showsVerticalScrollIndicator = NO;
                _searchDevicesScrollView.showsHorizontalScrollIndicator = NO;
                _searchDevicesScrollView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
                _searchDevicesScrollView.contentSize = CGSizeMake(self.flashDevicesArray.count * self.deviceBackgroundView.frame.size.width, 0);
            
            for (int index = 0; index < self.flashDevicesArray.count; index++) {
                //GIF 图
                UIWebView *deviceWebView = [[UIWebView alloc] initWithFrame:CGRectMake(index * self.searchDevicesScrollView.frame.size.width + self.searchDevicesScrollView.frame.size.width/4, 0, self.searchDevicesScrollView.frame.size.width/2, self.searchDevicesScrollView.frame.size.height - 30)];
                deviceWebView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
                deviceWebView.scalesPageToFit = YES;
                deviceWebView.userInteractionEnabled = NO;
                NSData *gifData;
                if ([self.flashDevicesTitleArray[index][0] isEqualToString:M1_DEVICE]) {
                    gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.deviceGIFNameArray[0] ofType:@"gif"]];
                }
                else {
                    gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.deviceGIFNameArray[1] ofType:@"gif"]];
                }
                [deviceWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
                [self.searchDevicesScrollView addSubview:deviceWebView];
            }
            [self.deviceBackgroundView addSubview:self.searchDevicesScrollView];
        }
        
        //提示小圆点
        if (!_pageControl) {
            self.pageControl                    = [[UIPageControl alloc] init];
                _pageControl.backgroundColor    = [UIColor clearColor];
                _pageControl.bounds             = CGRectMake(0, 0, 200, 100);
                _pageControl.center             = CGPointMake(self.deviceBackgroundView.frame.size.width/2, self.searchDevicesScrollView.frame.size.height - 10);
                _pageControl.numberOfPages      = self.flashDevicesGIFArray.count;
                _pageControl.currentPage        = 0;
                _pageControl.currentPageIndicatorTintColor = MAIN_TEXT_COLOR;
                _pageControl.pageIndicatorTintColor = [UIColor grayColor];
                _pageControl.userInteractionEnabled = NO;
            
            [self.deviceBackgroundView addSubview:self.pageControl];
        }
        
        [self.windowView addSubview:self.deviceBackgroundView];
    }
}

- (UITableView *)deviceTableView {
    if (!_deviceTableView) {
        self.deviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchDevicesScrollView.frame.size.height, self.deviceBackgroundView.frame.size.width, self.deviceBackgroundView.frame.size.height - self.searchDevicesScrollView.frame.size.height) style:UITableViewStylePlain];
            _deviceTableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
            _deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _deviceTableView.delegate = self;
            _deviceTableView.dataSource = self;
        
        [self.deviceBackgroundView addSubview:self.deviceTableView];
    }
    return _deviceTableView;
}

#pragma mark - LoadData
//加载设备类型数据
- (void)loadDeviceArrayData {
    self.deviceNameArray    = DEVICE_NAME_ARRAY;
    self.deviceGIFNameArray = DEVICE_GIF_ARRAY;
    
    self.readySandDevicesArray = [[NSArray alloc] init];
    
    self.dArray = [[NSMutableArray alloc] init];    //设备列表
    
    //初始化数组
    self.flashDevicesArray      = [[NSMutableArray alloc] init];    //存储当次循环的设备计算列表
    self.flashDevicesTitleArray = [[NSMutableArray alloc] init];    //设备外部名
    self.flashDevicesNameArray  = [[NSMutableArray alloc] init];    //设备内部名
    self.flashDevicesMacArray   = [[NSMutableArray alloc] init];    //设备地址
    self.flashDevicesGIFArray   = [[NSMutableArray alloc] init];    //设备 gif 名
    self.comparisonDevicesArray = [[NSMutableArray alloc] init];    //对比数组
    
    //初始化连接模式
    self.isXP3 = 1;
}

#pragma mark - Action
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

- (void)clearPopView {
    if (_obscuredView) {
        [self.obscuredView removeFromSuperview];
        self.obscuredView = nil;
    }
    if (_deviceBackgroundView) {
        [self.deviceBackgroundView removeFromSuperview];
        self.deviceBackgroundView = nil;
        [self.deviceTableView removeFromSuperview];
        self.deviceTableView = nil;
        self.searchDevicesScrollView = nil;
        self.pageControl = nil;
    }
    [self.comparisonDevicesArray removeAllObjects];
    if (_autoConnectCountdown.isValid) {
        [self.autoConnectCountdown invalidate];
        self.autoConnectCountdown = nil;
        _autoConnectTimes = 0;
    }
}

//自动连接倒计时
- (void)autoConnectCountdownAction {
    if (_autoConnectTimes > 4) {
        if (_flashDevicesArray.count > 0) {
            CBPeripheral *per = self.flashDevicesArray[0][0];
            if ([per.name isEqualToString:self.deviceNameArray[0]]) {
                self.isXP3 = YES;
            }
            else {
                self.isXP3 = NO;
            }
            [[JEBluetoothManager shareBLESingleton] connectDeviceWithCBPeripheral:per];
            if (_autoConnectCountdown.isValid) {
                [self.autoConnectCountdown invalidate];
                self.autoConnectCountdown = nil;
            }
            _autoConnectTimes = 0;
        }
    }
    else {
        _autoConnectTimes = _autoConnectTimes + 1;
        _countDownLabel.text = [NSString stringWithFormat:@"%d", 6 - _autoConnectTimes];
    }
}

#pragma mark - 网络请求
//1.接收到服务器响应的时候调用该方法
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
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
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (session == _askSession) {
        
        NSString *resultHexStr = [self convertDataToHexStr:data];
        
        NSString *serverStr = [self stringFromHexString:resultHexStr];
        
        NSString *serverVersionUpdate = [serverStr substringWithRange:NSMakeRange(1, 1)];
        
        NSString *serverVersion = [serverStr substringWithRange:NSMakeRange(2, 5)];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        USER_SET_SaveVersionNewAPP_NSString(serverVersion);
        USER_SET_SaveVersionAPP_NSString(app_Version);
        
        if ([serverVersion compare:app_Version] == NSOrderedDescending) {
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
                    //取消更新
                    [[JEBluetoothManager shareBLESingleton] initCentralManager];
                }]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertC animated:YES completion:^{
                    [self clearPopView];
                    
                    [[JEBluetoothManager shareBLESingleton] stopScanDevice];
                }];
            });
        }
    }
}

//3.当请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        
    }
}

#pragma mark - Animation
- (void)doAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.deviceBackgroundView.center = self.windowView.center;
    }];
}

- (void)closeAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.deviceBackgroundView.center = CGPointMake(WIDTH/2, HEIGHT*1.5);
    }];
}

#pragma mark - JEBluetoothManagerDelegate
- (void)updateBLEState:(bluetoothToolsState)bluetoothState {
    NSLog(@"MainVC当前蓝牙状态 : %lu", (unsigned long)bluetoothState);
    if (bluetoothState == DisConnect) {
        //重新开启扫描
        [[JEBluetoothManager shareBLESingleton] scanDevice:[JEBluetoothManager shareBLESingleton].peripheralName];
    }
    
    if (bluetoothState == Connect) {
        //连接之后停止扫描并弹出相机

        JESmartCameraViewController *vc = [[JESmartCameraViewController alloc] init];
        
        if (_isXP3) {
            vc.controllerMode = cameraM1;
        }
        else {
            vc.controllerMode = cameraP1;
        }
        
        [self presentViewController:vc animated:YES completion:nil];
        
        [self clearPopView];
    }
}

- (void)updateDevices:(NSArray *)devicesArray Macs:(NSArray *)macArray {
//    dispatch_async(dispatch_get_main_queue(), ^{
    
    NSLog(@"devicesArray = %@, macArray = %@", devicesArray, macArray);
    
    [self.flashDevicesArray         removeAllObjects];
    [self.flashDevicesTitleArray    removeAllObjects];
    [self.flashDevicesNameArray     removeAllObjects];
    [self.flashDevicesMacArray      removeAllObjects];
    [self.flashDevicesGIFArray      removeAllObjects];
    
    if (devicesArray.count == 0) {
        //现在无设备
        if (_obscuredView) {
            [self.obscuredView removeFromSuperview];
            self.obscuredView = nil;
        }
        if (_deviceTableView) {
            [self.deviceTableView removeFromSuperview];
            self.deviceTableView = nil;
        }
        if (_searchDevicesScrollView) {
            [self.searchDevicesScrollView removeFromSuperview];
            self.searchDevicesScrollView = nil;
            self.pageControl = nil;
        }
        if (_deviceBackgroundView) {
            [self.deviceBackgroundView removeFromSuperview];
            self.deviceBackgroundView = nil;
            [self closeAnimation];  //关闭动画
        }
        [self.comparisonDevicesArray removeAllObjects];
        return;
    }
    
//    for (int index = 0; index < devicesArray.count; index++) {
//        //设备列表为空时直接存入
//        if (self.dArray.count == 0) {
//            NSArray *name = [NSArray arrayWithObject:((CBPeripheral *)devicesArray[index]).name];
//            NSArray *mac = [NSArray arrayWithObject:macArray[index]];
//            [self.dArray addObject:@{@"Name":name, @"Mac":mac}];
//        }
//        else {
            //设备列表不为空
            
//            if (((CBPeripheral *)devicesArray[index]).name isEqual:_dArray[0][@"Name"]) {
//
//            }
//        }
//    }
//    NSLog(@"dArray = %@", self.dArray);
    
    for (int index = 0; index < devicesArray.count; index++) {
        //设备列表为空则直接存入
        if (self.flashDevicesArray.count == 0) {
            [self.flashDevicesArray         addObject:[NSArray arrayWithObject:devicesArray[index]]];
            if ([((CBPeripheral *)devicesArray[index]).name isEqualToString:self.deviceNameArray[0]]) {
                [self.flashDevicesTitleArray    addObject:[NSArray arrayWithObject:M1_DEVICE]];
            }
            else {
                [self.flashDevicesTitleArray    addObject:[NSArray arrayWithObject:P1_DEVICE]];
            }
            [self.flashDevicesNameArray     addObject:[NSArray arrayWithObject:((CBPeripheral *)devicesArray[index]).name]];
            [self.flashDevicesMacArray      addObject:[NSArray arrayWithObject:macArray[index]]];
            [self.flashDevicesGIFArray      addObject:(([((CBPeripheral *)devicesArray[index]).name isEqualToString:self.deviceNameArray[0]]) ? self.deviceGIFNameArray[0] : self.deviceGIFNameArray[1])];
        }
        //设备列表不为空，则对比已存入的设备，相同的存到一起，循环全数组都没有相同的再新增
        else {
            for (int indexTwo = 0; indexTwo < self.flashDevicesArray.count; indexTwo++) {
                //判断与哪一组的设备名相同
                if ([self.flashDevicesNameArray[indexTwo][0] isEqualToString:((CBPeripheral *)devicesArray[index]).name]) {
                    //相同则保存到同一组中，gif 数组不用更新
                    NSMutableArray *device  = [NSMutableArray arrayWithArray:self.flashDevicesArray[indexTwo]];
                    NSMutableArray *title   = [NSMutableArray arrayWithArray:self.flashDevicesTitleArray[indexTwo]];
                    NSMutableArray *mac     = [NSMutableArray arrayWithArray:self.flashDevicesMacArray[indexTwo]];
                    [device addObject:devicesArray[index]];
                    if ([((CBPeripheral *)devicesArray[index]).name isEqualToString:self.deviceNameArray[0]]) {
                        [title  addObject:M1_DEVICE];
                    }
                    else {
                        [title addObject:P1_DEVICE];
                    }
                    [mac    addObject:macArray[index]];
                    [self.flashDevicesArray         replaceObjectAtIndex:indexTwo withObject:device];
                    [self.flashDevicesTitleArray    replaceObjectAtIndex:indexTwo withObject:title];
                    [self.flashDevicesMacArray      replaceObjectAtIndex:indexTwo withObject:mac];
                    break;
                }
                else {
                    //不同则判断是否已经循环到最后一个数组
                    if (indexTwo == (self.flashDevicesArray.count - 1)) {
                        //是，则新增一组，并新增 gif 数据
                        [self.flashDevicesArray         addObject:[NSArray arrayWithObject:devicesArray[index]]];
                        if ([((CBPeripheral *)devicesArray[index]).name isEqualToString:self.deviceNameArray[0]]) {
                            [self.flashDevicesTitleArray    addObject:[NSArray arrayWithObject:M1_DEVICE]];
                        }
                        else {
                            [self.flashDevicesTitleArray    addObject:[NSArray arrayWithObject:P1_DEVICE]];
                        }
                        [self.flashDevicesNameArray     addObject:[NSArray arrayWithObject:((CBPeripheral *)devicesArray[index]).name]];
                        [self.flashDevicesMacArray      addObject:[NSArray arrayWithObject:macArray[index]]];
                        [self.flashDevicesGIFArray      addObject:(([((CBPeripheral *)devicesArray[index]).name isEqualToString:self.deviceNameArray[0]]) ? self.deviceGIFNameArray[0] : self.deviceGIFNameArray[1])];
                        break;
                    }
                    else {
                        //不是，则继续循环
                        continue;
                    }
                }
            }
        }
    }
    
    if (![self.comparisonDevicesArray isEqualToArray:self.flashDevicesArray]) {
        NSLog(@"前后设备列表不一致，更新列表和 UI");
        
        //更新 UI
        if (!_obscuredView) {
            [self obscuredView];
        }
        
        if (!_deviceBackgroundView) {
            [self setupDeviceBackgroundView];
            [self deviceTableView];
            [self doAnimation];
        }
        else {
            if (_searchDevicesScrollView) {
                for (UIWebView *web in self.searchDevicesScrollView.subviews) {
                    [web removeFromSuperview];
                }
                for (int index = 0; index < self.flashDevicesArray.count; index++) {
                    //GIF 图
                    UIWebView *deviceWebView = [[UIWebView alloc] initWithFrame:CGRectMake(index * self.searchDevicesScrollView.frame.size.width + self.searchDevicesScrollView.frame.size.width/4, 0, self.searchDevicesScrollView.frame.size.width/2, self.searchDevicesScrollView.frame.size.height - 30)];
                    deviceWebView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
                    deviceWebView.scalesPageToFit = YES;
                    deviceWebView.userInteractionEnabled = NO;
                    NSData *gifData;
                    if ([self.flashDevicesTitleArray[index][0] isEqualToString:M1_DEVICE]) {
                        gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.deviceGIFNameArray[0] ofType:@"gif"]];
                    }
                    else {
                        gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.deviceGIFNameArray[1] ofType:@"gif"]];
                    }
                    [deviceWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
                    
                    [self.searchDevicesScrollView addSubview:deviceWebView];
                }
                self.searchDevicesScrollView.contentSize = CGSizeMake(self.flashDevicesArray.count * self.deviceBackgroundView.frame.size.width, 0);
                self.pageControl.numberOfPages = self.flashDevicesGIFArray.count;
            }
        }
        
        [self.deviceTableView reloadData];
        
        [self.comparisonDevicesArray replaceObjectsInRange:NSMakeRange(0, self.comparisonDevicesArray.count) withObjectsFromArray:self.flashDevicesArray];
    }
//    });
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
        
        if (self.obscuredView) {
            [self.obscuredView removeFromSuperview];
            self.obscuredView = nil;
        }
        if (self.searchDevicesScrollView) {
            [self.searchDevicesScrollView removeFromSuperview];
            self.searchDevicesScrollView = nil;
        }
        return;
    }
}

#pragma mark - EnterCameraButtonDelegate
- (void)finishedEventByEnterCameraButton:(EnterCameraButton *)button {

    JESmartCameraViewController *vc = [[JESmartCameraViewController alloc] init];
    vc.controllerMode = cameraM1;
    [self presentViewController:vc animated:YES completion:nil];
    [self clearPopView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *flashArray = [[NSArray alloc] init];
    
    //滑动视图的页数
    CGFloat pageWidth = self.searchDevicesScrollView.frame.size.width;
    int currentPage = floor((self.searchDevicesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    flashArray = self.flashDevicesArray[currentPage];
    
    //当只有一个设备的时候，开启计时器，如果设备大于一个设备，就取消计时器
    if (self.flashDevicesArray.count == 1 && flashArray.count == 1) {
        if (!_autoConnectCountdown) {
            self.autoConnectCountdown = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(autoConnectCountdownAction) userInfo:nil repeats:YES];
        }
    }
    else {
        if (_countDownLabel) {
            [_countDownLabel removeFromSuperview];
            _countDownLabel = nil;
        }
        if (_autoConnectCountdown.isValid) {
            [self.autoConnectCountdown invalidate];
            self.autoConnectCountdown = nil;
        }
    }
    
    return flashArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"CELLID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    }
    
    //滑动视图的页数
    CGFloat pageWidth = self.searchDevicesScrollView.frame.size.width;
    int currentPage = floor((self.searchDevicesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    cell.textLabel.text             = self.flashDevicesTitleArray[currentPage][indexPath.row];
    cell.textLabel.textColor        = themeColor;
    cell.textLabel.font             = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text       = self.flashDevicesMacArray[currentPage][indexPath.row];
    cell.detailTextLabel.textColor  = [UIColor grayColor];
    if (_flashDevicesTitleArray.count == 1) {
        self.countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _countDownLabel.text = @"";
        _countDownLabel.textColor = [UIColor redColor];
        _countDownLabel.center = CGPointMake(cell.frame.size.width - 50, cell.center.y);
        [cell addSubview:_countDownLabel];
    }
    else {
        if (_countDownLabel) {
            [_countDownLabel removeFromSuperview];
            _countDownLabel = nil;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    //滑动视图的页数
    CGFloat pageWidth = self.searchDevicesScrollView.frame.size.width;
    int currentPage = floor((self.searchDevicesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    CBPeripheral *per = self.flashDevicesArray[currentPage][indexPath.row];
    
    if ([per.name isEqualToString:self.deviceNameArray[0]]) {
        self.isXP3 = YES;
    }
    else {
        self.isXP3 = NO;
    }
    
    [[JEBluetoothManager shareBLESingleton] connectDeviceWithCBPeripheral:per];
    
    if (_autoConnectCountdown.isValid) {
        [self.autoConnectCountdown invalidate];
        self.autoConnectCountdown = nil;
        _autoConnectTimes = 0;
    }
    if (_countDownLabel) {
        [_countDownLabel removeFromSuperview];
        _countDownLabel = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.searchDevicesScrollView.frame.size.width;
    
    int currentPage = floor((self.searchDevicesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    self.pageControl.currentPage = currentPage;
    
    [self.deviceTableView reloadData];
}

#pragma mark - Tools
//data转字符串
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

// 十六进制转换为普通字符串
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


@end
