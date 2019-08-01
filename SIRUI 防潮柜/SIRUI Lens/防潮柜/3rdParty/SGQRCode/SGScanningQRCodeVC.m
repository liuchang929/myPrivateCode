//
//  SGScanningQRCodeVC.m
//  SGQRCodeExample
//
//  Created by Sorgle on 16/8/25.
//  Copyright © 2016年 Sorgle. All rights reserved.


#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SGScanningQRCodeView.h"
#import "SGQRCodeTool.h"
#import <Photos/Photos.h>
#import "SGAlertView.h"
#import "Macros.h"
#import "JPUSHService.h"
#import "CommonUtils.h"
#import "SRLocalData.h"

//#import "SRContact.h"
@interface SGScanningQRCodeVC () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
/** 会话对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图层类 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) SGScanningQRCodeView *scanningView;

@property (nonatomic, strong) UIButton *right_Button;
@property (nonatomic, assign) BOOL first_push;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation SGScanningQRCodeVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 创建扫描边框
    self.scanningView = [[SGScanningQRCodeView alloc] initWithFrame:self.view.frame outsideViewLayer:self.view.layer];
    [self.view addSubview:self.scanningView];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"Scan", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];

    // 二维码扫描
    [self setupScanningQRCode];
    
    self.first_push = YES;
    

    
    
}

#pragma mark - - - 二维码扫描
- (void)setupScanningQRCode {
    // 初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    [SGQRCodeTool SG_scanningQRCodeOutsideVC:self session:_session previewLayer:_previewLayer];
}

#pragma mark - - - 二维码扫描代理方法
// 调用代理方法，会频繁的扫描
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
 
    
    
    
    
    
    
   //扫描获得did
    NSString *didStr =  [self getDidStr:metadataObjects];

    //获取设备别名,同时判断是否本地存在该设备
    NSMutableDictionary  * dict =[NSMutableDictionary dictionary];
    [dict setValue:didStr forKey:kDidsKey];
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kDeviceNameUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];
        NSDictionary  * dic  =[CommonUtils parserData_key:data];
        
        NSLog(@"获取别名%@",dic);
        
        
        if (dic.count) {//
         
        if ([[dic valueForKey:didStr] isKindOfClass:[NSString class]]) {
     
            
        [SRLocalData saveDataByDid:didStr];
         //获取所有本地的id，进行极光tag推送
        NSMutableArray  * keyIMEIArr = [SRLocalData readAllData];
         if (keyIMEIArr.count) {
        [JPUSHService setTags:[NSSet setWithArray:keyIMEIArr] alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            
          // NSLog(@"扫一扫之后的iTags=======%@",iTags);
          }];
                            
                            
         

        }
            
            
          [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else{//没有名字的情况下则没有进行配置网络阶段
            
            
            
            
            UIAlertController  *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"The device has not yet configured the network, first configured the device's network", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            
            
            
            
            [self presentViewController:alert animated:YES completion:nil];
            
            
        }
        
        }else{
            
            [self showHintMessage:NSLocalizedString(@"The device ID does not exist", nil)];
            
             [self.navigationController popViewControllerAnimated:YES];
            
        }
        

        
    } failure:^(NSError *error) {
       
        [weakSelf stopLoading];
        //SRLog(@"error:%@",error);
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
    }];
    
    
    
}



























-(NSString *)getDidStr:(NSArray *)metadataObjects{
    
    
    // 0、扫描成功之后的提示音
    [self playSoundEffect:@"sound.caf"];
    
    // 1、如果扫描完成，停止会话
    [self.session stopRunning];
    
    // 2、删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    // 3、设置界面显示扫描结果
    
    NSString *didStr = [NSString string];
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        
        
        
        
        if ([obj.stringValue hasPrefix:@"http"]) {
            if (obj.stringValue.length<=16) {
               // [self showAlert:@"无效的保险箱ID" cancelTitle:@"OK"];
                return @"";
                
            }else {
                
                didStr = [obj.stringValue substringFromIndex:obj.stringValue.length-12];
            }
            
        }else{
            
            didStr = obj.stringValue;
        }
        
        
    }
    

     return didStr;
    
}

#pragma mark - - - 扫描提示声
/** 播放音效文件 */
- (void)playSoundEffect:(NSString *)name{
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;

    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
   // SRLog(@"播放完成...");
}

#pragma mark - - - 移除定时器
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
    //    SRLog(@" - - -- viewDidAppear");
}



@end


