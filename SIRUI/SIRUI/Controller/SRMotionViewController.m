//
//  YY_MotionViewController.m
//  Sight
//
//  Created by fangxue on 2017/6/26.
//  Copyright © 2017年 fangxue. All rights reserved.
//   

#import "SRMotionViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "UIButton+countDown.h"
#import "MotionOrientation.h"
static int flag = 0;
#define kUpdateInterval (1.f / 100.f) // 更新频率高一点
@interface SRMotionViewController ()

@property (nonatomic, strong) CMMotionManager  *motionManager;
@property (nonatomic, strong) NSOperationQueue *quene;
@property (nonatomic, strong) UILabel          *label;
@property (nonatomic, strong) UILabel          *fixedLabelP;
@property (nonatomic, strong) UILabel          *fixedLabelH;
@property (nonatomic, strong) UILabel          *textLabel;
@property (nonatomic, strong) UILabel          *showInfoLabel;
@property (nonatomic, strong) UILabel          *portLabel;
@property (nonatomic, strong) UIButton         *backBtn;
@property (nonatomic, strong) UIButton         *secondBtn;
@property (nonatomic, assign) int               holdTimes;

@end

@implementation SRMotionViewController

- (BOOL)shouldAutorotate {
    
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}
- (UIButton *)secondBtn{
    
    if (!_secondBtn) {
        
        _secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _secondBtn.frame = CGRectMake(0, 0, 250, 250);
        
        _secondBtn.center = self.view.center;
        
        _secondBtn.enabled = NO;
        
        _secondBtn.backgroundColor = [UIColor clearColor];
        
        _secondBtn.userInteractionEnabled = NO;
        
        _secondBtn.alpha = 1.0;
        
        _secondBtn.titleLabel.font = [UIFont systemFontOfSize:200.0f];
        
    }
    return _secondBtn;
}
- (UIButton *)backBtn {
    
    if (!_backBtn) {
         _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        [_backBtn setTitle:NSLocalizedString(@"Back",nil) forState:(UIControlStateNormal)];
        [_backBtn setTitleColor:[UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1.00] forState:0];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    return _backBtn;
}
- (void)backBtnClick{
  
    [self dismissViewControllerAnimated:YES completion:^{
        [[JEBluetoothManager shareBLESingleton] BPQuitCalibrationMode];
    }];
}
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-150, 50, 150, 150)];
        _textLabel.font = [UIFont systemFontOfSize:17];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor redColor];
        _textLabel.numberOfLines = 2;
    }
    return _textLabel;
}
- (UILabel *)showInfoLabel {
    
    if (!_showInfoLabel) {
        
        _showInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-150, kScreenHeight-180, 150, 150)];
        _showInfoLabel.text = NSLocalizedString(@"Please adjust the angle to overlap the two grid lines",nil);
        _showInfoLabel.numberOfLines = 0;
        [_showInfoLabel sizeToFit];
        _showInfoLabel.textColor = [UIColor redColor];
    }
    return _showInfoLabel;
}
- (UILabel *)fixedLabelH{
    
    if (!_fixedLabelH) {
        
        _fixedLabelH = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-5)/2,kScreenHeight/4,5, kScreenHeight/2)];
        _fixedLabelH.backgroundColor = [UIColor greenColor];
    }
    return _fixedLabelH;
}
- (UILabel *)fixedLabelP{
    
    if (!_fixedLabelP) {
        
        _fixedLabelP = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/4,(kScreenHeight-5)/2 , kScreenWidth/2, 5)];
        
        _fixedLabelP.backgroundColor = [UIColor greenColor];
    }
    return _fixedLabelP;
}
- (UILabel *)label{
    
    if (!_label) {
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0,(kScreenHeight-5)/2 , kScreenWidth, 5)];
        _label.backgroundColor = [UIColor orangeColor];
    }
    return _label;
}
- (UILabel *)portLabel{
    
    if (!_portLabel) {
        
        _portLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-5)/2,0, 5, kScreenHeight)];
        _portLabel.backgroundColor = [UIColor orangeColor];
    }
    return _portLabel;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[JEBluetoothManager shareBLESingleton] BPEnterCalibrationMode];
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.motionManager stopDeviceMotionUpdates];//停止获取设备motion数据
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)accelerationSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Information",nil) message:NSLocalizedString(@"Calibrated", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    alertC.view.hidden = YES;
    
    [self presentViewController:alertC animated:YES completion:^{
        
        alertC.view.transform = [MotionOrientation sharedInstance].affineTransform;
        
        alertC.view.hidden = NO;
        
    }];
}

- (void)infoNotification:(NSNotification *)notification{
    
    BOOL isSuccess = notification.userInfo[@"SuccessAcceleration"];
    
    if (isSuccess==YES) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Information",nil) message:NSLocalizedString(@"Calibrated", nil) preferredStyle:UIAlertControllerStyleAlert];
            
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
        }]];
            
        alertC.view.hidden = YES;
            
        [self presentViewController:alertC animated:YES completion:^{
                
                alertC.view.transform = [MotionOrientation sharedInstance].affineTransform;
                
                alertC.view.hidden = NO;
                
        }];
     
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoNotification:) name:@"SuccessAcceleration" object:nil];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.label];
    [self.view addSubview:self.fixedLabelP];
    [self.view addSubview:self.fixedLabelH];
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.showInfoLabel];
    [self.view addSubview:self.portLabel];
    [self.view addSubview:self.secondBtn];
    self.motionManager = [[CMMotionManager alloc]init];
    self.quene = [[NSOperationQueue alloc] init];
    self.motionManager.deviceMotionUpdateInterval = kUpdateInterval;
    [self.motionManager startDeviceMotionUpdatesToQueue:_quene withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        /*
         //1. Accelerometer 获取手机加速度数据
         motion.userAcceleration.x
         motion.userAcceleration.y
         motion.userAcceleration.z
         CMAccelerometerData *newestAccel = self.motionManager.accelerometerData;
         double accelerationX = newestAccel.acceleration.x;
         double accelerationY = newestAccel.acceleration.y;
         double accelerationZ = newestAccel.acceleration.z;
         //2.Gravity 获取手机的重力值在各个方向上的分量 根据这个就可以获得手机的空间位置倾斜角度等
         double gravityX = motion.gravity.x;
         double gravityY = motion.gravity.y;
         double gravityZ = motion.gravity.z;
         double zTheta = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY)) / M_PI * 180.0;
         double xyTheta = atan2(gravityX, gravityY) / M_PI * 180.0;
         NSLog(@"手机与水平面的夹角 --- %.0f, 手机绕自身旋转的角度为 --- %.0f", zTheta, xyTheta);
         //3. DeviceMotion 获取陀螺仪的数据 包括角速度，空间位置等
         //旋转角速度
         double rotationX = motion.rotationRate.x;
         double rotationY = motion.rotationRate.y;
         double rotationZ = motion.rotationRate.z;
         //空间位置的欧拉角（通过欧拉角可以算得手机两个时刻之间的夹角，比用角速度计算精确地多）
         double roll = motion.attitude.roll;
         double pitch= motion.attitude.pitch;
         double yaw  = motion.attitude.yaw;
         //空间位置的四元数（与欧拉角类似，但解决了万向结死锁问题）
         double w =  motion.attitude.quaternion.w;
         double wx = motion.attitude.quaternion.x;
         double wy = motion.attitude.quaternion.y;
         double wz = motion.attitude.quaternion.z;
         */
        double gravityX = motion.gravity.x;
        double gravityY = motion.gravity.y;
        double gravityZ = motion.gravity.z;
        double zTheta = atan2(gravityZ,sqrtf(gravityX * gravityX + gravityY * gravityY)) / M_PI * 180.0;
        double xyTheta = atan2(gravityX, gravityY) / M_PI * 180.0;
        double rotation =  atan2(motion.gravity.x, motion.gravity.y) - M_PI;
        double rotation1 =  atan2(motion.gravity.x, motion.gravity.z);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Tilting:%.0f°\n Rolling:%.0f°",nil),zTheta,xyTheta];
            double x1 = motion.gravity.x;
            double y1 = motion.gravity.y;
            if (fabs(y1) >= fabs(x1))
            {
                if (y1 >= 0){
                    // UIDeviceOrientationPortraitUpsideDown;
                }
                else{
                    // UIDeviceOrientationPortrait;
                    self.backBtn.transform = CGAffineTransformMakeRotation(rotation);
                    self.textLabel.transform = CGAffineTransformMakeRotation(rotation);
                    self.portLabel.transform = CGAffineTransformMakeRotation(zTheta*M_PI/180);
                    self.label.transform = CGAffineTransformMakeRotation(rotation);
                    self.showInfoLabel.transform = CGAffineTransformMakeRotation(rotation);
                    self.secondBtn.transform = CGAffineTransformMakeRotation(rotation);
                }
            }
            else
            {
                self.backBtn.transform = CGAffineTransformMakeRotation(rotation);
                // UIDeviceOrientationLandscapeRight;
                self.textLabel.transform = CGAffineTransformMakeRotation(rotation);
                self.portLabel.transform = CGAffineTransformMakeRotation(rotation1);
                self.label.transform = CGAffineTransformMakeRotation(rotation);
                self.showInfoLabel.transform = CGAffineTransformMakeRotation(rotation);
                self.secondBtn.transform = CGAffineTransformMakeRotation(rotation);
            }
            NSInteger z = [[NSString stringWithFormat:@"%.0f",zTheta] integerValue];
            NSInteger y = [[NSString stringWithFormat:@"%.0f",xyTheta] integerValue];
            if (((z==0)&&(y==-90))||((z==0)&&(y==-180))) {
                self.textLabel.textColor = [UIColor greenColor];
                self.showInfoLabel.textColor = [UIColor greenColor];
                flag = 1;
            }else{
                self.textLabel.textColor = [UIColor whiteColor];
                self.showInfoLabel.textColor = [UIColor whiteColor];
                [self cleanHoldTimes];
            }
            if (flag==1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        flag=0;
                        if ((z==0)&&(y==-90))
                        {
                            [self holdTimesAdd];
                        }
                        if ((z==0)&&(y==-180))
                        {
                            [self holdTimesAdd];
                        }
                });
            }
        }];
    }];
}

//增加保持时间
- (void)holdTimesAdd {
    _holdTimes = _holdTimes+1;
    NSLog(@"times = %d", _holdTimes);
    if (_holdTimes > 160) {
        //约两秒
        [self holdTimesUp];
    }
}

//清空保持时间
- (void)cleanHoldTimes {
    _holdTimes = 0;
}

//到达保持时间
- (void)holdTimesUp {
    _holdTimes = 0;
    [self startAccelerationCalibration];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)startAccelerationCalibration{
 
    [[JEBluetoothManager shareBLESingleton] BPAccelerationCalibration];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SuccessAcceleration" object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
