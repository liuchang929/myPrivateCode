//
//  WifiBindingViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/10.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "WifiBindingViewController.h"
#import "CommonUtils.h"
#import "CustomTextField.h"
#import "SRCabinetInfo.h"

#import "SetNameViewController.h"
#import "UIView+Sizes.h"

#import "Macros.h"


/**
 espTouch
 */
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>




#define HEIGHT_KEYBOARD 216
#define HEIGHT_TEXT_FIELD 30
#define HEIGHT_SPACE (6+HEIGHT_TEXT_FIELD)
#define kRegVerifyViewDuration 60
#define kRegVerifyViewDuration 60
#define kRegVerifyViewDuration 60





@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = NSLocalizedString(@"DeviceSuccess", nil);//[NSString stringWithFormat:@"%@ is connected to the wifi" , result.bssid];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    //SRLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
}

@end




@interface WifiBindingViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) CustomTextField *ssidField;
@property (nonatomic, strong) CustomTextField *passwordField;
@property (nonatomic, assign) BOOL mobileValid;
@property (nonatomic, assign) BOOL passwordValid;
@property (nonatomic, assign) BOOL againPasswordValid;

@property (nonatomic, strong) UIButton *displayPassWordBtn;


@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger leftDuration;
@property (nonatomic, strong) UIButton *configureButton;

@property (nonatomic,strong) UIImageView  *backgoundView;

@property (nonatomic,strong)UIActivityIndicatorView *spinner;


// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// the state of the confirm/cancel button
@property (nonatomic, assign) BOOL _isConfirmState;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;


@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;




@end






@implementation WifiBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColorLoginBG;
    self.title=NSLocalizedString(@"Configure the device's network", nil);

    [self setupSubviews];
    
    [self addTapGesture];
    
  
    self._isConfirmState = NO;
    self._condition = [[NSCondition alloc]init];
    self._esptouchDelegate = [[EspTouchDelegateImpl alloc]init];
    [self enableConfirmBtn];
    
    
    
    
    NSNotificationCenter  *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(changeFieldText) name:@"workStatusWifiNotify" object:nil];
    
    
    
    [center addObserver:self selector:@selector(changeFieldTextOther) name:@"workStatusOtherNotify" object:nil];
    
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    
    [self.spinner stopAnimating];
    // [self stopLoading];
    self.passwordField.userInteractionEnabled = YES;
    
    [self enableConfirmBtn];
    // SRLog(@"ESPViewController do cancel action...");
    [self cancel];
    
    
}


//- (void)setupNavigationItem {
//    UIButton *left_Button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];//nav_back_blue@2x
//     // [left_Button setTitle:@"<back" forState:UIControlStateNormal];
//    [left_Button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [left_Button addTarget:self action:@selector(left_BarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *left_BarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left_Button];
//    
//    UIBarButtonItem *nagetiveSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                                   target:nil action:nil];
//    nagetiveSpacer.width = -15;
//    
//    self.navigationItem.leftBarButtonItems = @[nagetiveSpacer,left_BarButtonItem];//left_BarButtonItem;
//}
//- (void)left_BarButtonItemAction {
//    
//    
//    [self.spinner stopAnimating];
//    // [self stopLoading];
//    self.passwordField.userInteractionEnabled = YES;
//    
//    [self enableConfirmBtn];
//    // SRLog(@"ESPViewController do cancel action...");
//    [self cancel];
//    
//    return;
//    //不做返回动作，保证只能在点击确认按钮直接返回根页面
//    [self.navigationController popViewControllerAnimated:YES];
//    
//}




#pragma mark - 检测是否处于wifi环境
-(void)viewDidAppear:(BOOL)animated{
    if (![CommonUtils getWifiSSID]) {
        [self showAlert:NSLocalizedString(@"Wi-fi is not available", nil) cancelTitle:@"OK"];

        return;
    }
}

-(void)changeFieldText{
    
        self.ssidField.textField.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Wi-fi account", nil),[CommonUtils getWifiSSID]];
}

-(void)changeFieldTextOther{
    
 self.ssidField.textField.text = @"";
    
    
}





-(void)setupSubviews{
    self.backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];

    
    //设置访问密码
    self.ssidField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    self.ssidField.placeholderText = NSLocalizedString(@"WifiAccount", nil);
    
    self.ssidField.textField.keyboardType = UIKeyboardTypeDefault;
    self.ssidField.textField.delegate=self;
   // self.ssidField.validationDelegate = self;
    self.ssidField.textField.textColor = kColorWhite;
    self.ssidField.userInteractionEnabled = NO;//禁止手动输入，自动捕捉当前手机连入wifi情况
    [self.ssidField setBottomLine];
    
    
    
    //如果当前链接上wifi，直接获取当前的wifi网络
    if ([CommonUtils getWifiSSID]) {
        self.ssidField.textField.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"Wi-fi account", nil),[CommonUtils getWifiSSID]];//[CommonUtils getWifiSSID];
    }
    
    
    [self.view addSubview:self.ssidField];
    
    
    //密码
    self.passwordField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    [self.passwordField setSecurityInput:YES];
   // _passwordField.tag = KPasswordTag;
    [self.passwordField setBottomLine];
    self.passwordField.textFieldRightMargin = 32.f;
    self.passwordField.placeholderText = NSLocalizedString(@"WifiPassword", nil);
    self.passwordField.textField.delegate=self;
    //self.passwordField.validationDelegate = self;
    self.passwordField.textField.textColor = kColorWhite;
    //self.passwordField.textField.text = kWifiPassWord;
    [self.view addSubview:self.passwordField];
    
    
    
    
    
    
    
    
    //
    _displayPassWordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_displayPassWordBtn setImage:[UIImage imageNamed:@"wifi_password_invisible_icon"] forState:UIControlStateNormal];
    [_displayPassWordBtn setImage:[UIImage imageNamed:@"wifi_password_visible_icon"] forState:UIControlStateSelected];
    [_displayPassWordBtn addTarget:self action:@selector(displayPassWord:) forControlEvents:UIControlEventTouchUpInside];
    [_displayPassWordBtn setContentMode:UIViewContentModeCenter];
    [self.view addSubview:_displayPassWordBtn];
    
    

    
    
    
    
    
    
    
    
    
    self.configureButton = [[UIButton alloc]init];
    
    
    [self.configureButton setTitle:NSLocalizedString(@"Configure", nil) forState:UIControlStateNormal];
    [self.configureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.configureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    self.configureButton.layer.borderWidth = 1.f;
    self.configureButton.layer.borderColor = kColorBlue.CGColor;
    self.configureButton.layer.cornerRadius = 15.0f;
    
    
    
    [self.configureButton addTarget:self action:@selector(configureAction) forControlEvents:UIControlEventTouchUpInside];
  //  self.configureButton.enabled = NO;
    [self.view addSubview:self.configureButton];
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.spinner];

    
    
}




-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    

    [self.ssidField.textField resignFirstResponder];
    
    [_passwordField.textField resignFirstResponder];
    
    
    return NO;
}

#pragma mark - 配置设备连上路由
-(void)configureAction{

    

    
    
    if (self.ssidField.textField.text.length==0) {
        
        [self showHintMessage:NSLocalizedString(@"Please configure the wi-fi network", nil)];
        return;
        
    }
    
    
    
    if (self.passwordField.textField.text.length==0) {
        
        [self showHintMessage:NSLocalizedString(@"password can not be blank", nil)];
        return;
        
    }
    

    
     //点击完成返回结果
     [self tapConfirmForResults];

    
    
}


- (void) tapConfirmForResults
{
    // do confirm
    
    if (self._isConfirmState)//如果是执行状态
    {
        __weak typeof(self) weakSelf = self;
        self.passwordField.userInteractionEnabled = NO;
        
        
        
        
        
        
        
        //[self showLoading];
       
        [self enableCancelBtn];
      //  SRLog(@"ESPViewController do confirm action...");
        
        
        [self.spinner startAnimating];
        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
           // SRLog(@"ESPViewController do the execute work...");
            // execute the task
            NSArray *esptouchResultArray = [weakSelf executeForResults];
            // show the result to the user in UI Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner stopAnimating];
                //[self stopLoading];
                self.passwordField.userInteractionEnabled = YES;
                
                [self enableConfirmBtn];
                
                ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
                // check whether the task is cancelled and no results received
                if (!firstResult.isCancelled)
                {
                    NSMutableString *mutableStr = [[NSMutableString alloc]init];
                    NSUInteger count = 0;
                    // max results to be displayed, if it is more than maxDisplayCount,
                    // just show the count of redundant ones
                    const int maxDisplayCount = 5;
                    if ([firstResult isSuc])
                    {
                        
                        for (int i = 0; i < [esptouchResultArray count]; ++i)
                        {
                            ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                            [mutableStr appendString:[resultInArray description]];
                            [mutableStr appendString:@"\n"];
                            count++;
                            if (count >= maxDisplayCount)
                            {
                                break;
                            }
                        }
                        
                        if (count < [esptouchResultArray count])
                        {
                            [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                        }
                        
                       
                        
                   //     SRLog(@"firstResult.bssid:==========>%@",firstResult.bssid);
                        
                        
                        NSString * str  =[NSString stringWithFormat:@"%@",firstResult.bssid];
                        
    SetNameViewController *vc  =[[SetNameViewController alloc]init];
                        vc.didStr = str;//firstResult.bssid;
                        [self.navigationController pushViewController:vc animated:YES];

                        
                        
                        
                        
                        
                        
                    }
                    
                    else
                    {
//                        [[[UIAlertView alloc]initWithTitle:@"Execute Result" message:@"Esptouch fail" delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil]show];
                        
                        
                        
                        [self showAlert:NSLocalizedString(@"Connection network failed", nil) withMessage:NSLocalizedString(@"Please reconnect to the network", nil) cancelTitle:NSLocalizedString(@"Iknow", nil)];
                        
                        
                        
                        
                        
                        
                    }
                }
                
            });
        });
    }
    // do cancel
    else
    {
        [self.spinner stopAnimating];
       // [self stopLoading];
        
        self.passwordField.userInteractionEnabled = YES;
        
        [self enableConfirmBtn];
       // SRLog(@"ESPViewController do cancel action...");
        [self cancel];
    }
}



//- (void) tapConfirmForResult
//{
//    // do confirm
//    if (self._isConfirmState)
//    {
//        //[self._spinner startAnimating];
//        [self showLoading];
//        
//        
//        [self enableCancelBtn];
//        NSLog(@"ESPViewController do confirm action...");
//        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(queue, ^{
//            NSLog(@"ESPViewController do the execute work...");
//            // execute the task
//            ESPTouchResult *esptouchResult = [self executeForResult];
//            // show the result to the user in UI Main Thread
//            dispatch_async(dispatch_get_main_queue(), ^{
//               // [self._spinner stopAnimating];
//                [self stopLoading];
//                
//                
//                [self enableConfirmBtn];
//                // when canceled by user, don't show the alert view again
//                if (!esptouchResult.isCancelled)
//                {
//                    [[[UIAlertView alloc] initWithTitle:@"Execute Result" message:[esptouchResult description] delegate:nil cancelButtonTitle:@"I know" otherButtonTitles: nil] show];
//                }
//            });
//        });
//    }
//    // do cancel
//    else
//    {
//        //[self._spinner stopAnimating];
//        [self stopLoading];
//        [self enableConfirmBtn];
//        NSLog(@"ESPViewController do cancel action...");
//        [self cancel];
//    }
//}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self._condition lock];
    NSString *apSsid = [CommonUtils getWifiSSID];
    NSString *apPwd = self.passwordField.textField.text;
    NSString *apBssid = [CommonUtils getWifiBssID];//self.bssid;
    int taskCount = 1;//[self._taskResultCountTextView.text intValue];默认一次
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
   // SRLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark - the example of how to use executeForResult

- (ESPTouchResult *) executeForResult
{
    [self._condition lock];
    NSString *apSsid = [CommonUtils getWifiSSID];
    
    
    
    
    NSString *apPwd = self.passwordField.textField.text;
    NSString *apBssid = [CommonUtils getWifiBssID];
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    ESPTouchResult * esptouchResult = [self._esptouchTask executeForResult];
   // SRLog(@"ESPViewController executeForResult() result is: %@",esptouchResult);
    return esptouchResult;
}


// enable confirm button
- (void)enableConfirmBtn
{
    self._isConfirmState = YES;
    [self.configureButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    
    

}

// enable cancel button
- (void)enableCancelBtn
{
    self._isConfirmState = NO;
    [self.configureButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    

    
}












- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgoundView.frame = self.view.bounds;
    
    //self.deviceIDField.frame = CGRectMake(20.f, 68.f, self.view.frame.size.width-40.f, [self.deviceIDField viewHeight]);
    self.ssidField.frame = CGRectMake(20.f, 68.f, self.view.frame.size.width-40.f, [self.ssidField viewHeight]);
    self.passwordField.frame = CGRectMake(20.f, self.ssidField.bottom, self.view.frame.size.width-40.f, [self.passwordField viewHeight]);
    CGFloat displayWidth = 48.f;
    CGFloat displayHeigth = 48.f;
    self.displayPassWordBtn.frame = (CGRect){self.passwordField.right - 1.0f - displayWidth,self.passwordField.frame.origin.y + (self.passwordField.height - displayHeigth)/2, displayWidth, displayHeigth};
    
    
   // self.QrcodeImageView.frame = (CGRect){self.deviceIDField.right - 1.0f - displayWidth,self.deviceIDField.frame.origin.y + (self.deviceIDField.height - displayHeigth)/2, 20, 20};
    
   // self.QrcodeImageView.right = self.deviceIDField.right-10;
    //self.QrcodeImageView.bottom = self.deviceIDField.bottom-10;
    self.configureButton.frame = (CGRect){30.f, self.passwordField.bottom +16.f , self.view.width - 60.0f, 44.0f};
    
    
    self.spinner.frame  = CGRectMake(0, 0, 30, 30);
    self.spinner.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  显示密码
 *
 *  @param sender
 */
- (void)displayPassWord:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    [_passwordField setSecurityInput:!button.selected];
}

- (void)displayAgainPassWord:(id)sender
{
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    //[_againPasswordField setSecurityInput:!button.selected];
}


@end
