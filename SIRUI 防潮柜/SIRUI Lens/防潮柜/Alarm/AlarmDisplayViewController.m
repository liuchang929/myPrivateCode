//
//  AlarmDisplayViewController.m
//  SmartTripod
//
//  Created by sirui on 16/11/15.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "AlarmDisplayViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordQueryViewController.h"
#import "SRCabinetInfo.h"
#import "Macros.h"
#import "CommonUtils.h"
#import "UIView+Sizes.h"
#import "Macros.h"

@interface AlarmDisplayViewController ()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *alarmImageView;
@property (nonatomic, strong) UILabel     *currentDeviceLabel;
@property (nonatomic, strong) UILabel     *overRangeLabel;
@property (nonatomic, strong) UILabel     *timeLabel;
@property (nonatomic, strong) UIButton *sureBtn;


@end
@implementation AlarmDisplayViewController


+(void)showAlarmDisplayView{
    UIViewController *rootVC = [(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *presentedVC = rootVC;
    while (presentedVC.presentedViewController) {
        presentedVC = presentedVC.presentedViewController;
    }
    
        UINavigationController *nav = (UINavigationController *)presentedVC;
        UIViewController *navVC = [nav.viewControllers firstObject];
        if ([navVC isKindOfClass:[AlarmDisplayViewController class]]) {
            return;
        }
    
    
//        if ([presentedVC isKindOfClass:[BaseViewController class]]) {
//            NSLog(@"YES");
//        }
    
    AlarmDisplayViewController *alarmDisplayViewController = [[AlarmDisplayViewController alloc] init];
    
 [presentedVC presentViewController:alarmDisplayViewController animated:YES completion:nil];
    
    
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //震动及振动回调
//    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
//    
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    
    
    [self setupSubViews];
    [self getDeviceName];
   


}






-(void)setupSubViews{
    
    
    
    self.bgImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cabinet_alarm"]];
    [self.view addSubview:self.bgImageView];
    
    
    
    self.alarmImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"warning_mark_icon"]];
    [self.view addSubview:self.alarmImageView];
    
    
    
    
    self.currentDeviceLabel = [[UILabel alloc]init];
    self.currentDeviceLabel.numberOfLines = 3;
    self.currentDeviceLabel.text = NSLocalizedString(@"SIRUI-Cabinet", nil);//默认
    self.currentDeviceLabel.font =kSystemFontOfSize(20);
    self.currentDeviceLabel.textColor =kColorWhite;
    self.currentDeviceLabel.textAlignment= NSTextAlignmentCenter;
    [self.view addSubview:self.currentDeviceLabel];
    
    
    
    self.overRangeLabel = [[UILabel alloc]init];
    self.overRangeLabel.text = NSLocalizedString(@"Warning message", nil);//默认
    self.overRangeLabel.numberOfLines = 4;
    if ([SRCabinetInfo sharedInstance].alarmType.length) {
        switch ([[SRCabinetInfo sharedInstance].alarmType intValue]) {
            case 1:
                self.overRangeLabel.text = NSLocalizedString(@"Alert! The password for the Moisture Proof ark is entered incorrectly", nil);
                break;
            case 2:
                self.overRangeLabel.text = NSLocalizedString(@"Alert! The Moisture Proof ark is being moved", nil);
                break;
            case 3:
                self.overRangeLabel.text = NSLocalizedString(@"Alert! The Moisture Proof ark is being vibrated", nil);
                break;
            default:
                break;
        }
        
    }
    self.overRangeLabel.font =kSystemFontOfSize(15);
    self.overRangeLabel.textColor =kColorWhite;
    self.overRangeLabel.textAlignment= NSTextAlignmentCenter;
    [self.view addSubview:self.overRangeLabel];
    
    
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.font =kSystemFontOfSize(18);
    self.timeLabel.textColor =kColorWhite;
    self.timeLabel.textAlignment= NSTextAlignmentCenter;
    
    if ([SRCabinetInfo sharedInstance].alarmTime.length){
        
        self.timeLabel.text = [SRCabinetInfo sharedInstance].alarmTime;
        
        
    }
    [self.view addSubview:self.timeLabel];
    
    
    self.sureBtn = [[UIButton alloc]init];
    
    [self.view addSubview:self.sureBtn];
    
    
    
    self.sureBtn.backgroundColor =kColorRed;//[UIColor yellowColor];
    self.sureBtn.layer.borderWidth = 1.0;
    [self.sureBtn setTitle:NSLocalizedString(@"Iknow", nil) forState:UIControlStateNormal];
    self.sureBtn.layer.borderColor =[UIColor clearColor].CGColor;
    self.sureBtn.clipsToBounds = TRUE;//去除边界
    [self.sureBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];

    
    
}



#pragma  mark - 获取当前设备名字
-(void)getDeviceName{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([SRCabinetInfo sharedInstance].alarmId.length==0) {
        return;
    }
    
    NSString * idStr =[SRCabinetInfo sharedInstance].alarmId;
    NSMutableArray *arr =[NSMutableArray array];
    [arr addObject:idStr];
    
    [dict setObject:arr forKey:kDidsKey];
    
    __weak typeof(self) weakSelf = self;
    [CommonUtils postJsonWithUrlString:kDeviceNameUrlbyJson parameters:dict success:^(id data) {
        
        
        SRLog(@"警报时防潮柜的名字:%@",data);
        //判断解析出来的data属于字典类型
        if (![data isKindOfClass:[NSDictionary class]]) {
            return ;
        }

        
        
        if ([[data valueForKey:kCodeKey] isEqualToString:kCode0]) {
            
            
            NSDictionary  *dic = [data valueForKey:kDataKey];
            weakSelf.currentDeviceLabel.text = [NSString stringWithFormat:@"%@ %@",[dic valueForKey:idStr],NSLocalizedString(@"issue an alert", nil)];
       
        
        }else{//其他错误码提示
            
            NSString *str = [CommonUtils parserCode_keyMessageWithDic:data];
            
            if (!str) {
                [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [weakSelf showHintMessage:str];
            }
            
        }
        
    } failure:^(NSError *error) {
       
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
    }];
}

//void systemAudioCallback()
//
//{
//    
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    
//}


-(void)tapAction:(UIButton *)sender{
     //AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    //[self stopAlertSoundWithSoundID:sound];
    //[UIApplication sharedApplication].applicationIconBadgeNumber=0;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}








- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.view.frame = self.view.bounds;
    
    
    self.bgImageView.frame = self.view.bounds;
    
    self.alarmImageView.frame = CGRectMake(0, 60, 100, 100);
    self.alarmImageView.centerX = self.view.centerX;
    
    
    self.currentDeviceLabel.frame = CGRectMake(30, self.alarmImageView.bottom, self.view.width-60.f, 60);
    self.overRangeLabel.frame = CGRectMake(30, self.currentDeviceLabel.bottom, self.view.width-60.f, 80);
    
    self.timeLabel.frame = CGRectMake(0, self.overRangeLabel.bottom, self.view.width, 30);
    
    self.sureBtn.frame = CGRectMake((self.view.width/2)-50,self.view.height - 120, 100, 100);
    
    self.sureBtn.layer.cornerRadius = self.sureBtn.width/2;

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
@end
