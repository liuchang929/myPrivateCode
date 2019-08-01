//
//  IoTBaseViewController.m
//  IoTLogin
//
//  Created by sirui on 2017/3/3.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FGGReachability.h"
#import "Reachability.h"
#define kSrMessageWidth 180.f
#import "RecordQueryViewController.h"
#import "DeviceListViewController.h"
#import "Macros.h"

//NSString * const kWorkStatusWifiNotify = @"workStatusWifiNotify";
//NSString * const kWorkStatusOtherNotify = @"workStatusOtherNotify";

@interface BaseViewController ()
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic,strong) UIImageView  *backgoundView;
@end
@implementation BaseViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self startNetworkListening];//每一次加载视图都进行网络监听

}





-(void)startNetworkListening{
    
    _reachability=[Reachability reachabilityForInternetConnection];
    //网络状态改变时调用estimateNetwork方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(estimateNetwork) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
    
    //判断网络状态
    [self estimateNetwork];
    
    
}




//判断网络状态
-(void)estimateNetwork
{
    FGGNetWorkStatus status=[FGGReachability networkStatus];
    
    if (status==FGGNetWorkStatusWifi) {
        

        NSNotification  *notion =[NSNotification notificationWithName:@"workStatusWifiNotify" object:nil];//[NSNotification notificationWithName:@"xiaoxi" object:<#(nullable id)#>];
        
        
        [[NSNotificationCenter  defaultCenter] postNotification:notion];
        
        
    }else{
        
        NSNotification  *notion =[NSNotification notificationWithName:@"workStatusOtherNotify" object:nil];//[NSNotification notificationWithName:@"xiaoxi" object:<#(nullable id)#>];
        
        
        [[NSNotificationCenter  defaultCenter] postNotification:notion];
        
        
        
    }
    

    
    
    switch (status) {
        case FGGNetWorkStatus2G:
        {
            SRLog(@"当前网络状态2G");
           // [self showAlert:@"当前网络状态2G" cancelTitle:@"确定"];
            //[self sh:@"当前网络状态2G"];
            break;
        }
        case FGGNetWorkStatusEdge:
        {
            SRLog(@"当前网络状态2.75G(Edge)");
          // [self showAlert:@"当前网络状态2.75G(Edge)" cancelTitle:@"确定"];
            break;
        }
        case FGGNetWorkStatus3G:
        {
            SRLog(@"当前网络状态3G");
           //[self showAlert:@"当前网络状态3G" cancelTitle:@"确定"];
            break;
        }
        case FGGNetWorkStatus4G:
        {
            SRLog(@"当前网络状态4G");
            //[self showAlert:@"当前网络状态4G" cancelTitle:@"确定"];
            break;
        }
        case FGGNetWorkStatusWifi:
        {
            SRLog(@"当前网络状态wifi");
         //  [self showAlert:@"当前网络状态wifi" cancelTitle:@"确定"];
            break;
        }
        case FGGNetWorkStatusNotReachable:
        {
            SRLog(@"当前网络状态不可用");
            [self showAlert:NSLocalizedString(@"NetworkFailInfo", nil) cancelTitle:@"OK"];
            break;
           
            
        }
        default:
            break;
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
   // self.scrollView.frame = self.view.bounds;
      self.backgoundView.frame =self.view.bounds;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)addTapGesture {
    if (nil == self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    }
    [self.view addGestureRecognizer:self.tapGesture];
}


- (void)removeTapGesture {
    [self.view removeGestureRecognizer:self.tapGesture];
}

//继承给手势的动作
- (void)tapAction {
    [self.view endEditing:YES];
}




- (void)showAlert:(NSString *)title cancelTitle:(NSString *)cancelTitle {
    [self showAlert:title withMessage:nil cancelTitle:cancelTitle];
}



- (void)showAlert:(NSString *)title withMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    [self showAlert:title withMessage:message cancelTitle:cancelTitle confirmTitle:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message  cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle
{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
    {
        
        UIAlertController  *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
        
        if (confirmTitle) {
            [alert addAction:[UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //[self alertSelectorAction];
                
                
                
            }]];
        }
        
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
    
}




#pragma mark - Rotation & Interface & status bar

// 覆写父类的方法
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}








#pragma mark - HUD
- (BOOL)isShowingLoading {
    return self.hud.superview != nil;//hud的父视图不等于空，就是存在，存在的话就为真
}

- (void)showLoading {
    

    
    
    
    [self showHudLoading:NSLocalizedString(@"Being loaded..", nil)];
}

- (void)showLoading:(NSString *)msg {
    [self showHudLoading:msg];
}

- (void)showHudLoading:(NSString *)msg {
    
    if (self.navigationController) {
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:(self.navigationController)?self.navigationController.view:self.view animated:YES];

    self.hud.label.text = NSLocalizedString(@"Being loaded..", nil);


}



-(void)showDelayedLoading:(NSString *)msg{
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:(self.navigationController)?self.navigationController.view:self.view animated:YES];
    
  //  self.hud.label.text = NSLocalizedString(@"Being loaded..", nil);
    
    // Set the annular determinate mode to show task progress.
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.label.text = msg;
    
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//        // Do something useful in the background and update the HUD periodically.
//        [self doSomeWorkWithProgress];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//        });
//    });
    
    
}







- (void)showHintMessage:(NSString *)message{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:(self.navigationController)?self.navigationController.view:self.view animated:YES];
    
    // Set the text mode to show only text.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, 0.f);
    
    [hud hideAnimated:YES afterDelay:1.f];
    
}





- (void)stopLoading {
    
    if (self.navigationController) {
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    
    
    [self.hud removeFromSuperview];
    self.hud = nil;
}



@end
