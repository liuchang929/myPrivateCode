//
//  HumidityViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/13.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "HumidityViewController.h"
#import "XLCircleProgress.h"
#import "SRCabinetInfo.h"
#import "Macros.h"
#import "UIView+Sizes.h"
#import "CommonUtils.h"
#import "SRDeviceUtils.h"

@interface HumidityViewController ()
{
    XLCircleProgress *_circle;
}
@property (nonatomic,strong) UIImageView  *backgoundView;
@property (nonatomic,strong) UILabel      *tipTextLabel;
@property (nonatomic,strong) UILabel      *textLabel;
@property (nonatomic, strong) UIButton *sureButton;
@end
@implementation HumidityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];

}

-(void)setupSubViews{
    
    self.view.backgroundColor = kColorBlack;
    _backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    
    
    self.tipTextLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.tipTextLabel.text = NSLocalizedString(@"HumiditySettingRange", nil);
    self.tipTextLabel.textColor = kColorWhite;
    self.tipTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.tipTextLabel];
    
    
    self.textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.textLabel.text = @"25%RH～65%RH";
    self.textLabel.textColor = kColorWhite;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textLabel];
 
    
    
    //addCircle
    CGFloat margin = 45.0f;
    CGFloat circleWidth = [UIScreen mainScreen].bounds.size.width - 2*margin;
    _circle = [[XLCircleProgress alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    _circle.center = self.view.center;
    
    
    
    //SRCabinetInfo保存之前设置好的湿度设置
    _circle.progress = 0.25;
    NSString * str = [SRCabinetInfo sharedInstance].humiditySetting;
   float f = [str floatValue];
   NSString  * shm = [NSString stringWithFormat:@"%0.2f",f/100];
    float temp = [shm floatValue];

    if (temp>0.25&&temp<0.65) {
        _circle.progress = temp;
    }

    [self.view addSubview:_circle];
    
    
    
    
    
    
    
    
    //slider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(_circle.frame) + 50, self.view.bounds.size.width - 2*50, 30)];
    [slider addTarget:self action:@selector(sliderMethod:) forControlEvents:UIControlEventValueChanged];
    if (temp>0.25&&temp<0.65) {
        [slider setValue:temp];
    }
    
    [slider setMaximumValue:0.65];
    [slider setMinimumValue:0.25];
    [slider setMinimumTrackTintColor:[UIColor colorWithRed:255.0f/255.0f green:151.0f/255.0f blue:0/255.0f alpha:1]];
    [self.view addSubview:slider];
    
    
    self.sureButton = [[UIButton alloc]init];
    [self.sureButton setTitle:NSLocalizedString(@"SaveSettings", nil) forState:UIControlStateNormal];
    [self.sureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.sureButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    [self.sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sureButton];
    

}


#pragma mark - 保存湿度设置
-(void)sureAction{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!didStr.length) {
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    

    
    
    
    [dict setObject:didStr forKey:kDidKey];
     NSString  *hmStr = [NSString stringWithFormat:@"%0.0f",_circle.progress*100];//上传整数的湿度
    [dict setObject:hmStr forKey:kHmKey];
    ///SRLog(@"上传的湿度是：%@",hmStr);
    
    
    
    [self showLoading];
    
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kCtrlhumidityUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];

        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
            
            [weakSelf showLoading];
            [dict setObject:didStr forKey:kDidKey];
            [dict setObject:[CommonUtils parserData_key:data] forKey:kTmKey];
            
            
            
            
            
            //延时2s再请求湿度数据的反馈，因为防潮柜的数据发给服务器在再转发给app存在时间差
            dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);
            
            dispatch_after(timer, dispatch_get_main_queue(), ^{
                
                [CommonUtils postHttpWithUrlString:kCtrlhumidityfeedbackUrl parameters:dict success:^(id data) {
                    
                    [weakSelf stopLoading];

                    
                    
       if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
                    if ([CommonUtils parserData_key:data]) {
                        [self showHintMessage:[CommonUtils parserData_keyMessage:data]];
               }else{
                        
                  [self showHintMessage:NSLocalizedString(@"Wait for timeout", nil)];
                        
                        
                    }
           
           
       }else{
           
           
           NSString *str = [CommonUtils parserCode_keyMessage:data];
           
           if (!str) {
               [self showHintMessage:NSLocalizedString(@"Data error", nil)];
           }else{
               [self showHintMessage:str];
           }
           
           
       }
           
           
           
 
                    
                    
                } failure:^(NSError *error) {
                    
                    [weakSelf stopLoading];
                    [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
                }];
            });
            
            
          }else{
            
            NSString *str = [CommonUtils parserCode_keyMessage:data];
            
            if (!str) {
                [self showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [self showHintMessage:str];
            }
        }
        
    } failure:^(NSError *error) {
        
        [weakSelf stopLoading];
        SRLog("%@",error);
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];
    
    
    
    
    
    

   
    
}

-(void)sliderMethod:(UISlider*)slider
{
    _circle.progress = slider.value;
    //SRLog(@"====%0.2f",slider.value);
}


- (void)viewDidLayoutSubviews {
    
    
    self.backgoundView.frame = self.view.bounds;
    self.tipTextLabel.frame = CGRectMake(0, 64, self.view.width, 30);
    if([SRDeviceUtils isNotchScreen])
    {
        self.tipTextLabel.frame = CGRectMake(0, 64 + 30, self.view.width, 30);
    }
    
    self.textLabel.frame = CGRectMake(0, self.tipTextLabel.bottom, self.view.width, 30);
    
    
    self.sureButton.frame = (CGRect){30.f,
        self.view.height - 60.f, self.view.width - 60.0f, 44.0f};

 
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
