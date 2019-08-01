//
//  GuidingPageViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/8.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "GuidingPageViewController.h"
#import "DetailsView.h"
#import "CustomTextField.h"
#import "PasswordUnlockViewController.h"
#import "HumidityViewController.h"
#import "RecordQueryViewController.h"
#import "ChangeNameViewController.h"
#import "Macros.h"
#import "SRCabinetInfo.h"
#import "UIView+Sizes.h"
#import "CommonUtils.h"
#import "LabeledActivityIndicatorView.h"
#import "SRLocalData.h"
#import "KeyIMEIArrEntity.h"
#import "SRDeviceUtils.h"

@interface GuidingPageViewController ()
@property (strong, nonatomic)  UILabel *temperatureLabel;
@property (strong, nonatomic)  UILabel *temperatureMarking;
@property (strong, nonatomic)  UILabel *humidityLabel;
@property (strong, nonatomic)  UILabel *humidityMarking;
@property (strong, nonatomic)  UIButton *alarmButton;
@property (strong, nonatomic)  UIButton *openingRecordButton;
@property (strong, nonatomic)  UIButton *closingRecordButton;
@property (nonatomic,strong)   UIImageView  *backgoundView;
@property (strong,nonatomic)  UILabel *lineLabel;
@property (nonatomic,strong)   UIImageView  *crossLineView;
@property (nonatomic,strong)   DetailsView *openCommandView;
@property (nonatomic,strong)   DetailsView *humidityControlView;
@property (nonatomic,strong)   DetailsView *deadlockCommandView;
@property (nonatomic,strong)   DetailsView *unLockCommandView;
@property (nonatomic,strong)   UILabel *lockState;


@property (nonatomic,strong)   NSString *didStr;
@property (nonatomic, strong) LabeledActivityIndicatorView *laiView;

@end

@implementation GuidingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    [self setupNavView];
    [self isOpenNotification];
    [self clearLostDevice];
    
}


-(void)clearLostDevice{
    KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];    if (keyArrEntity.emptyArr.count!=0) {
        
        
        NSArray * arr = keyArrEntity.emptyArr;
        for (NSString * str in arr) {
            [SRLocalData deleteDataByDid:str];
        }
        
        [keyArrEntity clearEmptyArr];
        
    }

    
}



-(void)viewDidAppear:(BOOL)animated{
    //判断是否存在该设备
    self.didStr  = [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!self.didStr.length) {
        
        [_laiView stopRotationWithDone];
        [_laiView setDescription:NSLocalizedString(@"Details", nil) font:nil color:nil];

        self.didStr = @"";
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    [self reloadNewData];
    
}



///如果用户未开启推送通知，则提醒用户没有推送无法进行警报推送
-(void)isOpenNotification{
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    
    if(UIUserNotificationTypeNone == setting.types) {
        
       [self showAlert:NSLocalizedString(@"Unable to push the alarm message", nil) withMessage:NSLocalizedString(@"Please go to system Settings to open the app to push", nil) cancelTitle:@"OK"];
        
    }else{
        return;
    }

    
}



#pragma mark - 加载温度湿度数据
-(void)reloadNewData{

    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject: self.didStr forKey:kDidKey];
    //[self showLoading];
  //  [self.view setUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kCabinetdataUrl parameters:dict success:^(id data){
        
       // [self.view setUserInteractionEnabled:YES];
       // [self stopLoading];
        [weakSelf.laiView stopRotationWithDone];
        [weakSelf.laiView setDescription:NSLocalizedString(@"Details", nil) font:nil color:nil];

         if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {

            id dic = [CommonUtils parserData_key:data];
             
            if (![dic isKindOfClass:[NSDictionary class]]) {
                [weakSelf resetData];
                [weakSelf showHintMessage:NSLocalizedString(@"The device is offline, please check the equipment status", nil)];
                 return;
            }
            
           weakSelf.temperatureLabel.text = [NSString stringWithFormat:@"%@°c",[dic valueForKey:kTpKey]];
           weakSelf.humidityLabel.text = [NSString stringWithFormat:@"%@%%RH",[dic valueForKey:kHmKey]];
               
           if ([[dic valueForKey:kLockKey] isKindOfClass:[NSNumber class]]) {
            weakSelf.lockState.text = ([[dic valueForKey:kLockKey]  integerValue])?NSLocalizedString(@"LockState", nil):NSLocalizedString(@"UnLockState", nil);
            }

                 
                 
            [SRCabinetInfo sharedInstance].humiditySetting = [NSString stringWithFormat:@"%@",[dic valueForKey:kShmKey]];

                 
         }else{///其他返回编码处理
             
          NSString *str = [CommonUtils parserCode_keyMessage:data];
             
        if (!str) {
            [self showHintMessage:NSLocalizedString(@"Data error", nil)];
             }else{
               [self showHintMessage:str];
             
             
         }
             
         }
        

     

        
    } failure:^(NSError *error) {
      
        //[self.view setUserInteractionEnabled:YES];
        [weakSelf.laiView stopRotationWithDone];
        [_laiView setDescription:NSLocalizedString(@"Details", nil) font:nil color:nil];
        
       // [self stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];

    
    
    
}



/**
 清除防潮柜数据
 */
-(void)resetData{
    self.temperatureLabel.text = NSLocalizedString(@"Unknown", nil);
    self.humidityLabel.text = NSLocalizedString(@"Unknown", nil);
    self.lockState.text = NSLocalizedString(@"UnknownLockState", nil);
}




/**
 开门记录
 */
-(void)openingRecordAction:(UIButton *)sender{
    
    RecordQueryViewController  *vc  = [[RecordQueryViewController alloc]initWithRecordQueryStyle:kOpenRecordQuery];
    [self.navigationController pushViewController:vc animated:YES];
}



/**
 警报记录

 */
-(void)alarmAction:(UIButton *)sender{
    
    RecordQueryViewController  *vc  = [[RecordQueryViewController alloc]initWithRecordQueryStyle:kAlarmRecordQuery];

    [self.navigationController pushViewController:vc animated:YES];
}



/**
 关门记录

 
 */
-(void)closeingRecordAction:(UIButton *)sender{
    
    RecordQueryViewController  *vc  = [[RecordQueryViewController alloc]initWithRecordQueryStyle:kCloseRecordQuery];
   
    [self.navigationController pushViewController:vc animated:YES];
    
}




/**
 远程开门

 */
-(void)openCommandAction:(UIButton *)sender{

    
    if ([self.temperatureLabel.text isEqualToString: NSLocalizedString(@"Unknown", nil)]) {
        
        [self showAlert:NSLocalizedString(@"Can not operate off-line equipment", nil) cancelTitle:@"OK"];
        return;
    }
    
    
    
    if ([self.lockState.text isEqualToString: NSLocalizedString(@"LockState", nil)]) {
        
        [self showHintMessage:NSLocalizedString(@"Please unlock the device", nil)];
        return;
    }

    
    PasswordUnlockViewController *vc =   [[PasswordUnlockViewController alloc] initWithNibName:NSStringFromClass([PasswordUnlockViewController class]) bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    


    
    
}


/**
 设置湿度

 
 */
-(void)humidityControlAction:(UIButton *)sender{
    
    
    if ([self.temperatureLabel.text isEqualToString: NSLocalizedString(@"Unknown", nil)]) {
        
    [self showAlert:NSLocalizedString(@"Can not operate off-line equipment", nil) cancelTitle:@"OK"];
        return;
    }
    
    
    HumidityViewController  * vc = [[HumidityViewController alloc]init];
    
    [self.navigationController pushViewController:vc animated:YES];
}







#pragma mark -锁死操作,防潮柜在打开门的情况下不能接受锁死指令，返回超时反馈
-(void)deadlockAction:(UIButton *)sender{
    
    
    if ([self.temperatureLabel.text isEqualToString: NSLocalizedString(@"Unknown", nil)]) {
        
       [self showAlert:NSLocalizedString(@"Can not operate off-line equipment", nil) cancelTitle:@"OK"];
        return;
    }
    
    
    
    
    ///parameters设置
   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
   [dict setObject:self.didStr forKey:kDidKey];
   [self showLoading];
   
    __weak typeof(self) weakSelf = self;
    [CommonUtils  postHttpWithUrlString:kLockitUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[CommonUtils parserData_key:data] forKey:kTmKey];
        [dict setObject:self.didStr forKey:kDidKey];
        
        
        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
        [weakSelf showLoading];

        //定时器，定时2秒再执行反馈url
        dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);
        dispatch_after(timer, dispatch_get_main_queue(), ^{
        
            
            

        [CommonUtils postHttpWithUrlString:kLockfeedbackUrl parameters:dict success:^(id data) {
            
             [weakSelf stopLoading];
     if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
         
         if ([CommonUtils parserData_key:data]) {
                        
            

             if ([[CommonUtils parserData_key:data] isEqualToString:@"600"]) {
                 weakSelf.lockState.text = NSLocalizedString(@"LockState", nil);
             
             
 
             [weakSelf showHintMessage:[CommonUtils parserData_keyMessage:data]];
             
             
                        
          }else if ([[CommonUtils parserData_key:data] isEqualToString:@"601"]){
                        
              [weakSelf showAlert:NSLocalizedString(@"The cabinet is open and can not be locked", nil) cancelTitle:@"OK"];
                        
                        
          }else{
              
              [weakSelf showHintMessage:NSLocalizedString(@"Wait for timeout", nil)];
              
              
          }
     
             
             
             
             
             
         }else{
             
             
             [weakSelf showHintMessage:NSLocalizedString(@"Wait for timeout", nil)];
             
             
         }
         
         
     }else{///其他返回编码处理
         
         
         NSString *str = [CommonUtils parserCode_keyMessage:data];
         
         if (!str) {
             [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
         }else{
             [weakSelf showHintMessage:str];
         }
         
         
     }

  
            
      } failure:^(NSError *error) {
          
                    [weakSelf stopLoading];
                        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];

                
                }];
                
            });
            
            
            
            
            
            
            
            
            
            
            
         }else{///其他返回编码处理
                 NSString *str = [CommonUtils parserCode_keyMessage:data];
             
                 if (!str) {
                     [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
                 }else{
                     [weakSelf showHintMessage:str];
                 }
        }
        
    } failure:^(NSError *error) {
        
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
   }];



}



#pragma mark - 解锁
-(void)unLockAction:(UIButton *)sender{
    
    
    if ([self.temperatureLabel.text isEqualToString: NSLocalizedString(@"Unknown", nil)]) {
        
       [self showAlert:NSLocalizedString(@"Can not operate off-line equipment", nil) cancelTitle:@"OK"];
        return;
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.didStr forKey:kDidKey];
    [self showLoading];
    
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kUnlockitUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];

        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
 
            [weakSelf showLoading];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[CommonUtils parserData_key:data] forKey:kTmKey];
            [dict setObject:self.didStr forKey:kDidKey];
            
            
            
            
            ///定时器，定时2秒再执行反馈url
            dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC);
            
      dispatch_after(timer, dispatch_get_main_queue(), ^{
                [CommonUtils postHttpWithUrlString:kUnlockfeedbackUrl parameters:dict success:^(id data) {
                    
            [weakSelf stopLoading];
          if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
              
              
              
              
              
                    if ([CommonUtils parserData_key:data]) {
                        
                        [weakSelf showHintMessage:[CommonUtils parserData_keyMessage:data]];
                       
                        
                        if ([[CommonUtils parserData_key:data] isEqualToString:@"600"]) {
                         weakSelf.lockState.text = NSLocalizedString(@"UnLockState", nil);
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }else{
                        
                    [weakSelf showHintMessage:NSLocalizedString(@"Wait for timeout", nil)];
                        
                        
                    }
                    

              
              
          }else{
              
              
              NSString *str = [CommonUtils parserCode_keyMessage:data];
              
              if (!str) {
                  [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
              }else{
                  [weakSelf showHintMessage:str];
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
                [weakSelf showHintMessage:NSLocalizedString(@"Data error", nil)];
            }else{
                [weakSelf showHintMessage:str];
            }
        }
        
    } failure:^(NSError *error) {
        
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];
    
    
}








///views
-(void)setupNavView{
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];

    
    //self.title = NSLocalizedString(@"Details", nil);

    _laiView = [LabeledActivityIndicatorView new];
    self.navigationItem.titleView = _laiView;
    
    [_laiView setDescription:NSLocalizedString(@"Loading...", nil) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
    [_laiView startRotation];
    
    
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setButton setFrame:CGRectMake(10, 0, 44, 44)];
    [setButton addTarget:self action:@selector(editVC) forControlEvents:UIControlEventTouchUpInside];
    [setButton setImage:kGetImage(@"course_evaluate_edit") forState:UIControlStateNormal];
    
    
    UIBarButtonItem  *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    
    self.navigationItem.rightBarButtonItems = @[rightBtn];
}

-(void)editVC{
    ChangeNameViewController * vc =[[ChangeNameViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}




-(void)setupSubViews{
    _backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    self.temperatureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.temperatureLabel.text = NSLocalizedString(@"Unknown", nil);
    self.temperatureLabel.textColor = kColorWhite;
    self.temperatureLabel.textAlignment = NSTextAlignmentCenter;
    self.temperatureLabel.font = [UIFont boldSystemFontOfSize:18];    [self.view addSubview:self.temperatureLabel];
    
    
    self.temperatureMarking = [[UILabel alloc]initWithFrame:CGRectZero];
    self.temperatureMarking.text = [NSString stringWithFormat:@"%@:°c",NSLocalizedString(@"Temparature", nil)];//@"温度:°c";
    self.temperatureMarking.textColor = kColorWhite;
    self.temperatureMarking.textAlignment = NSTextAlignmentCenter;
    self.temperatureMarking.font = [UIFont boldSystemFontOfSize:18];     [self.view addSubview:self.temperatureMarking];
    
    
    self.humidityLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.humidityLabel.text = NSLocalizedString(@"Unknown", nil);//@"未知";
    self.humidityLabel.textColor = kColorWhite;
    self.humidityLabel.textAlignment = NSTextAlignmentCenter;
    self.humidityLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.humidityLabel];
    
    
    self.humidityMarking = [[UILabel alloc]initWithFrame:CGRectZero];
    self.humidityMarking.text = [NSString stringWithFormat:@"%@:%%RH",NSLocalizedString(@"Humidity", nil)];//@"湿度:%RH";
    self.humidityMarking.textColor = kColorWhite;
    self.humidityMarking.textAlignment = NSTextAlignmentCenter;
    self.humidityMarking.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.humidityMarking];
    
    
    self.openingRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openingRecordButton.layer.borderWidth = 2.f;
    self.openingRecordButton.layer.borderColor = kColorWhite.CGColor;
    self.openingRecordButton.layer.cornerRadius = kMidCircleWidth/2;
    
    
    [self.openingRecordButton setTitle:NSLocalizedString(@"OpeningLog", nil) forState:UIControlStateNormal];
    [self.openingRecordButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.openingRecordButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    
    self.openingRecordButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.openingRecordButton addTarget:self
                                 action:@selector(openingRecordAction:)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openingRecordButton];
    
    
    
    self.alarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.alarmButton.layer.borderWidth = 2.f;
    self.alarmButton.layer.borderColor = kColorWhite.CGColor;
    self.alarmButton.layer.cornerRadius =  kBigCircleWidth/2;
    [self.alarmButton setTitle:NSLocalizedString(@"AlarmLog", nil) forState:UIControlStateNormal];
    
    [self.alarmButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.alarmButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    self.alarmButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.alarmButton addTarget:self
                         action:@selector(alarmAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.alarmButton];
    
    
    
    self.closingRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.closingRecordButton.layer.borderWidth = 2.f;
    self.closingRecordButton.layer.borderColor =kColorWhite.CGColor;
    self.closingRecordButton.layer.cornerRadius = kMidCircleWidth/2;
    [self.closingRecordButton setTitle:NSLocalizedString(@"ClosingLog", nil) forState:UIControlStateNormal];
    [self.closingRecordButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.closingRecordButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    self.closingRecordButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.closingRecordButton addTarget:self
                                 action:@selector(closeingRecordAction:)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closingRecordButton];
    
    
    
    self.lineLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lineLabel.backgroundColor = [UIColor yellowColor];
    self.lineLabel.alpha = 0.4;
    [self.lineLabel setShadowOffset:CGSizeMake(0, 2)];
    [self.view addSubview:self.lineLabel];
    
    _crossLineView =  kGetImageView(@"cross_line");
    [self.view addSubview:_crossLineView];
    
    
    
    self.openCommandView = [[DetailsView alloc]initWithFrame:CGRectZero];
    [self.openCommandView.headIv setImage:[UIImage imageNamed:@"guiding_open_icon"]];
    self.openCommandView.tittleLabel.text = NSLocalizedString(@"OpenCabinet", nil);
    [self.openCommandView addEditTarget:self action:@selector(openCommandAction:)];
    [self.view addSubview:self.openCommandView];
    
    
    self.humidityControlView = [[DetailsView alloc]initWithFrame:CGRectZero];
    [self.humidityControlView.headIv setImage:[UIImage imageNamed:@"guiding_humidity_icon"]];
    self.humidityControlView.tittleLabel.text = NSLocalizedString(@"SetHumidity", nil);
    [self.humidityControlView addEditTarget:self action:@selector(humidityControlAction:)];
    [self.view addSubview:self.humidityControlView];
    
    
    self.deadlockCommandView = [[DetailsView alloc]initWithFrame:CGRectZero];
    [self.deadlockCommandView.headIv setImage:[UIImage imageNamed:@"guiding_deadlock_icon"]];
    self.deadlockCommandView.tittleLabel.text = NSLocalizedString(@"Locked", nil);
    [self.deadlockCommandView addEditTarget:self action:@selector(deadlockAction:)];
    [self.view addSubview:self.deadlockCommandView];
    
    
    self.unLockCommandView = [[DetailsView alloc]initWithFrame:CGRectZero];
    [self.unLockCommandView.headIv setImage:[UIImage imageNamed:@"guiding_unlock_icon"]];
    self.unLockCommandView.tittleLabel.text = NSLocalizedString(@"Unlock", nil);
    [self.unLockCommandView addEditTarget:self action:@selector(unLockAction:)];
    [self.view addSubview:self.unLockCommandView];
    
    
    
    
    self.lockState = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lockState.text = NSLocalizedString(@"UnknownLockState", nil);
    self.lockState.textColor = kColorInchworm;//[UIColor yellowColor];
    self.lockState.textAlignment = NSTextAlignmentCenter;
    self.lockState.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:self.lockState];
    
    
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.temperatureLabel.frame = CGRectMake(0, 64, self.view.width/2, 30);
    self.temperatureMarking.frame = CGRectMake(0, 94, self.view.width/2, 30);
    self.humidityLabel.frame = CGRectMake(self.view.width/2, 64, self.view.width/2, 30);
    self.humidityMarking.frame = CGRectMake(self.view.width/2, 94, self.view.width/2, 30);
    if([SRDeviceUtils isNotchScreen])
    {
        self.temperatureLabel.frame = CGRectMake(0, 64+ 30, self.view.width/2, 30);
        self.temperatureMarking.frame = CGRectMake(0, 94 + 30, self.view.width/2, 30);
        self.humidityLabel.frame = CGRectMake(self.view.width/2, 64 + 30, self.view.width/2, 30);
        self.humidityMarking.frame = CGRectMake(self.view.width/2, 94 + 30, self.view.width/2, 30);
    }
    
    self.lockState.frame = CGRectMake(0, self.humidityMarking.bottom+10, self.view.width, 20.f);
    

    
    self.openingRecordButton.frame = CGRectMake(30, self.lockState.bottom+80, kMidCircleWidth, kMidCircleWidth);
    self.alarmButton.frame = CGRectMake(30, self.lockState.bottom+80, kBigCircleWidth, kBigCircleWidth);
    
    
    self.closingRecordButton.frame = CGRectMake(self.view.width-30-kMidCircleWidth, self.lockState.bottom+80, kMidCircleWidth, kMidCircleWidth);
    
    
    self.alarmButton.centerX = self.view.centerX;
    self.alarmButton.centerY = self.view.centerY*0.8;
    self.openingRecordButton.centerY = self.view.centerY*0.8;
    self.closingRecordButton.centerY = self.view.centerY*0.8;
    
    
    
    self.lineLabel.frame = CGRectMake(0, self.alarmButton.bottom+8, self.view.width, 0.2);
    
    self.crossLineView.frame = CGRectMake(0, self.lineLabel.bottom, self.view.width, self.view.height-self.lineLabel.bottom);

    self.openCommandView.frame = CGRectMake(0, self.lineLabel.bottom+25, self.view.width/3, self.view.width/3);
    self.openCommandView.right = self.view.width/2;
    self.openCommandView.bottom = (self.view.height-self.lineLabel.bottom)*0.5+self.lineLabel.bottom;
    
    
    self.humidityControlView.frame = CGRectMake(0, self.lineLabel.bottom+25, self.view.width/3, self.view.width/3);
    self.humidityControlView.left = self.view.width/2;
    self.humidityControlView.bottom = (self.view.height-self.lineLabel.bottom)*0.5+self.lineLabel.bottom;
    
    
    self.unLockCommandView.frame = CGRectMake(0, self.lineLabel.bottom+25, self.view.width/3, self.view.width/3);
    self.unLockCommandView.right = self.view.width/2;
    self.unLockCommandView.bottom = self.view.height;    self.deadlockCommandView.frame = CGRectMake(0, self.lineLabel.bottom+25, self.view.width/3, self.view.width/3);
    self.deadlockCommandView.left = self.view.width/2;
    self.deadlockCommandView.bottom = self.view.height;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
