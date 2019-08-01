//
//  BindViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/22.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "BindViewController.h"
#import "WifiBindingViewController.h"
#import "RecordQueryViewController.h"

/**
 QRcode
 */
#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SGAlertView.h"
#import "Macros.h"


//#import "ProductScanViewController.h"

@interface BindViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgoundView;


@property (weak, nonatomic) IBOutlet UIButton *configueButton;

- (IBAction)ConfigureInternetAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;

- (IBAction)ScanAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation BindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
     
  
}

-(void)setupSubViews{
    [_backgoundView setImage:[UIImage imageNamed:@"cabinet_background"]];
    
    self.titleLabel.text =  NSLocalizedString(@"Please confirm the current device status before adding the device", nil);
    self.subtitleLabel.text = NSLocalizedString(@"When configuring the network of the device, press the 'Password reset / wifi reset' button for the humidity cabinet for more than 5 seconds and wait for 'bi'", nil);
    
    
    
    [self.configueButton setTitle:NSLocalizedString(@"Configure the device's network", nil) forState:UIControlStateNormal];
    [self.configueButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.configueButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    self.configueButton.layer.borderWidth = 1.f;
    self.configueButton.layer.borderColor = kColorBlue.CGColor;
    self.configueButton.layer.cornerRadius = 15.0f;
    
    
    [self.scanButton setTitle:NSLocalizedString(@"Directly scan to bind the device", nil) forState:UIControlStateNormal];
    [self.scanButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.scanButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    self.scanButton.layer.borderWidth = 1.f;
    self.scanButton.layer.borderColor = kColorBlue.CGColor;
    self.scanButton.layer.cornerRadius = 15.0f;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///进入配置网络
- (IBAction)ConfigureInternetAction:(id)sender {
    
    WifiBindingViewController  *vc = [[WifiBindingViewController alloc]init];
    
   [self.navigationController pushViewController:vc animated:YES];
}


///扫描二维码
- (IBAction)ScanAction:(id)sender {
    
    
    
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            __weak typeof(self) weakSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
#if 1
                        SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
                        [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
                        
                        
#else
             
//         ProductScanViewController  *vc =[[ProductScanViewController alloc]init];
//          [self.navigationController pushViewController:vc animated:YES];
                        
                        
#endif
                        

                    });
                    
                    
                   
                    
                    // 用户第一次同意了访问相机权限
                
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
#if 1
            SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
            [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
            
            
#else
            
//            ProductScanViewController  *vc =[[ProductScanViewController alloc]init];
//            [self.navigationController pushViewController:vc animated:YES];
            
            
#endif
            
            
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            
            [self showAlert:NSLocalizedString(@"Tips", nil) withMessage:NSLocalizedString(@"Please go to - > [privacy Settings - - camera - iotplatform] open access switch", nil) cancelTitle:@"OK"];//
        } else if (status == AVAuthorizationStatusRestricted) {
            
            [self showHintMessage:NSLocalizedString(@"The album can not be accessed for system reasons", nil)];
            //SRLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        
        
         [self showAlert:NSLocalizedString(@"warning", nil) withMessage:NSLocalizedString(@"Did not detect your camera, please test it on a real machine", nil) cancelTitle:@"OK"];

    }
    

    
    
}
@end
