//
//  BGUnlockController.m
//  BGUnlockControllerDemo
//
//  Created by user on 15/11/25.
//  Copyright © 2015年 BG. All rights reserved.
//

#import "PasswordUnlockViewController.h"
#import "Macros.h"
#import "SRCabinetInfo.h"
#import "CommonUtils.h"

int count = 0;

static UIImage *ImageWithColor(UIColor * color, CGSize size){
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
}









@interface PasswordUnlockViewController ()
{
    
    int timeFlag;
    
}
@property (weak, nonatomic) IBOutlet UILabel *passwordNumLabel;


/**
 *  按钮数组的父视图
 */
@property (weak, nonatomic) IBOutlet UIView *buttonsSuperView;
/**
 *  按钮数组
 */
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArr;
/**
 *  圆点数组
 */
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *topDotViewArr;
@property (weak, nonatomic) IBOutlet UIView *topDotSuperView;

/**
 *  提醒文本
 */
@property (weak, nonatomic) IBOutlet UILabel *topTipLabel;

/**
 *  圆点底部距离按钮父视图的距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dotBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDotSuperViewCenterXLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgoundView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic,strong)dispatch_source_t timer;





- (IBAction)SureAction:(id)sender;

- (IBAction)DeleteAction:(id)sender;

/**
 *  结果解锁的数字密码
 */
@property (nonatomic, strong) NSString *resultPassCode;

/**
 *  解锁的次数
 */
@property (nonatomic, assign) NSInteger unlockCount;


/**
 *  输入的数字个数
 */
@property (nonatomic, assign) NSInteger inputNumCount;
@end

@implementation PasswordUnlockViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.backgoundView = nil;
       // self.passcodeUnlockCount = 3;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self setupValues];
    [self setupViews];
    self.unlockCount = 0;
    self.resultPassCode = @"";
   // [self usePasscodeUnlock];

    
    
    [_backgoundView setImage:[UIImage imageNamed:@"cabinet_background"]];

    self.inputNumCount = 0;
    
    //_inputNumCount默认为0
    //NSLog(@"_inputNumCount:%ld",(long)_inputNumCount);
    
    
    
    
    
}


- (void)setupViews {
    //屏幕宽度
    CGFloat mainScrrenWidth = [UIScreen mainScreen].bounds.size.width;
    //设置按钮的宽和高
    CGFloat height = (NSInteger)(mainScrrenWidth-320)*0.1+70.0f;
    self.buttonHeightLayoutConstraint.constant = height;
    //设置按钮
    for (UIButton *button in self.buttonArr) {
        button.exclusiveTouch = YES;
        button.layer.cornerRadius = height/2.0;
        button.layer.borderWidth = 1.0f;
        button.layer.borderColor =kColorBlue.CGColor;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor clearColor];
        [button setBackgroundImage:ImageWithColor([UIColor clearColor], CGSizeMake(height, height)) forState:UIControlStateNormal];
        [button setBackgroundImage:ImageWithColor(kColorBlue, CGSizeMake(height, height)) forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    //圆点
    for (UIView *dotView in self.topDotViewArr) {
        dotView.layer.cornerRadius = 5.0f;
        dotView.layer.borderWidth = 1.0f;
        dotView.layer.borderColor = [UIColor clearColor].CGColor;
        dotView.backgroundColor = [UIColor clearColor];
        dotView.layer.masksToBounds = YES;
    }
    
    //顶部提醒文字
    self.topTipLabel.text = NSLocalizedString(@"EnterSafePassword", nil);
    
    [self.sureButton setTitle:NSLocalizedString(@"Sure", nil) forState:UIControlStateNormal];
    //self.sureButton.titleLabel.text = NSLocalizedString(@"Sure", nil);
}





#pragma mark - 加密算法
-(NSString *)encryPassword:(NSString *)password andtimeStr:(NSString *)timeStr{
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    
    int j ;
    int _xor;
    char  e_Pw[13];
    //NSLog(@"password.length===%lu",password.length);
    for (int i = 0; i < password.length; i++)
        
       
    {
        j = 12-(i%4);
        _xor = [didStr characterAtIndex:i] +[timeStr characterAtIndex:j];
        _xor &= 0x0f;

        int add = (([password characterAtIndex:i] - '0') ^ _xor);
        
//        if(add <10){
//            
//            
//            add+= '0';
//            
//            
//        }else{
//            
//            
//            
//            add -=10;
//            add +='a';
//            
//            
//        }
        
        
        e_Pw[i] = add;
        
        e_Pw[i+1] = 0;
        //itoa(e_Pw+i, e_Pw[i], 16);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    for (int i = 0; i < password.length; i++) {
        e_Pw[i] += e_Pw[password.length-1-i];
        e_Pw[i]&= 0x0f;
        //int add;
//                if(e_Pw[i] <10){
//        
//        
//                    e_Pw[i]+= '0';
//        
//        
//                }else{
//        
//        
//        
//                    e_Pw[i] -=10;
//                    e_Pw[i] +='A';
//                    
//                    
//                }
        
    }
    
    for (int i = 0; i < password.length; i++) {
//        e_Pw[i] += e_Pw[password.length-1-i];
//        e_Pw[i]&= 0x0f;
//        //int add;
        if(e_Pw[i] <10){
            
            
            e_Pw[i]+= '0';
            
            
        }else{
            
            
            
            e_Pw[i] -=10;
            e_Pw[i] +='A';
            
            
        }
        
    }
    
    

    return [[NSString stringWithCString:e_Pw encoding:NSUTF8StringEncoding] uppercaseString];

}









- (void)hideContentView {
    self.topDotSuperView.hidden = YES;
    self.buttonsSuperView.hidden = YES;
    self.topTipLabel.hidden = YES;
}

- (void)showContentView {
    self.topDotSuperView.hidden = YES;
    self.buttonsSuperView.hidden = YES;
    self.topTipLabel.hidden = YES;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - action
- (void)buttonAction:(UIButton *)button {
    //设置圆点为实心
  //  UIView *dotView = self.topDotViewArr[self.inputNumCount];
  //  dotView.backgroundColor = kColorBlue;
  //  NSLog(@"inputNumCount = %zd, color:%@", self.inputNumCount, dotView.backgroundColor);
    
    NSMutableString  *str = [NSMutableString string];

   
    for (int i = 0; i<=self.inputNumCount;i++ ) {
        [str appendString:@"*"];
        
    }
    self.passwordNumLabel.text = str;
    
//    for (UIView *view in self.topDotViewArr) {
//        //SLog(@"%@", view.backgroundColor);
//    }
    
    
    
    if(++self.inputNumCount > 12) {
        self.inputNumCount = 12;
        self.passwordNumLabel.text = @"************";

         SRLog(@"self.resultPassCode:%@",self.resultPassCode);
        [self showAlert:NSLocalizedString(@"PasswordLengthInfo", nil) cancelTitle:@"OK"];
        return;
        //比较输入的数字码正确与否
        //        if([self.resultPassCode isEqualToString:self.passcode]) {
        //            [self unlockSuccess];
        //        }else {
        //
        //            //自增
        //            self.unlockCount ++;
        //         //   NSLog(@"====%ld",(long)self.unlockCount);
        //            // 如果已经超过数字解锁码的上限，则调用失败的方法
        ////            if(self.unlockCount >= self.passcodeUnlockCount) {
        ////                [self unlockFailure];
        ////
        ////                [self showHintMessage:NSLocalizedString(@"ThreeInputError", nil)];
        ////                 self.buttonsSuperView.userInteractionEnabled = NO;
        ////                return;
        ////            }
        //
        //
        //            //屏蔽点击
        //          //  self.buttonsSuperView.userInteractionEnabled = NO;
        ////            [self shakePassCodeView:^{
        ////             //   [self clearPassCodeView];
        ////                self.buttonsSuperView.userInteractionEnabled = YES;
        ////
        ////            }];
        //   
        //        }
    }
    
    
    //存储数字解锁密码
    NSInteger codeValue = [self.buttonArr indexOfObject:button];
    self.resultPassCode = [NSString stringWithFormat:@"%@%zd", self.resultPassCode, codeValue];
    SRLog(@"self.resultPassCode:%@",self.resultPassCode);

}


#pragma makr - public method
- (void)shakePassCodeView: (void (^)())block {
    self.topDotSuperViewCenterXLayoutConstraint.constant = 50;
    [self.view layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        weakSelf.topDotSuperViewCenterXLayoutConstraint.constant = 0;
        
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if(finished) {
            [weakSelf.view layoutIfNeeded];
            block();
        }
    }];
}


//- (void)setPasscodeUnlockCount:(NSInteger)passcodeUnlockCount {
//    _passcodeUnlockCount = passcodeUnlockCount;
//}


#pragma mark - response delete method
- (void)unlockSuccess {
    [self.delegate unlockSuccessController:self];
}

- (void)unlockFailure {
    [self.delegate unlockFailureWithUnlockController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - 点击执行远程开门
- (IBAction)SureAction:(id)sender {
    
    timeFlag = 0;
 


    
    if (self.resultPassCode.length<1) {
        [self showHintMessage:NSLocalizedString(@"EnterPassword", nil)];
        return;
    }
    
    
    
//    if (![CommonUtils isValidPassword:self.resultPassCode]) {
//       // [self showHintMessage:NSLocalizedString(@"EnterValidPassword", nil)];
//        [self showAlert:NSLocalizedString(@"EnterValidPassword", nil) cancelTitle:@"OK"];
//        return;
//    }
//    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!didStr.length) {
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    [dict setValue:didStr forKey:kDidKey];
    
    NSDate *nowDate = [NSDate date];
    //@"1234567890123";
    NSString * timeStr = [NSString stringWithFormat:@"%0.f",[nowDate timeIntervalSince1970]*1000];
    [dict setValue:timeStr forKey:kTmKey];
    
    NSString  * passwordStr = [self encryPassword:self.resultPassCode andtimeStr:timeStr];
    [dict setValue:passwordStr forKey:kPwdKey];
    
    SRLog(@"======%@",self.resultPassCode);
    [self showLoading];
    
    
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:kOpendoorUrl parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];
        
        
        //NSDictionary  *jsondic;
        //jsondic=(NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
        //  SRLog(@"开门数据jsondic==%@",jsondic);
        
        
        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {

              [weakSelf showLoading];
            
            

            //获取之前选中的设备id
            NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
            if (!didStr.length) {
                [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
                [self stopLoading];
                return;
            }
            
            
            //设置parameters
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:didStr forKey:kDidKey];
            [dict setValue:[CommonUtils parserData_key:data] forKey:@"tm"];
            
            
            //获得队列
            dispatch_queue_t queue = dispatch_get_main_queue();//dispatch_get_global_queue(0, 0);
            //创建一个定时器
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            
            //设置开始时间
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0*NSEC_PER_SEC));
            
            //设置时间间隔
            uint64_t interval = (uint64_t)(2.0 * NSEC_PER_SEC);
            
            //设置定时器
            dispatch_source_set_timer(self.timer, start, interval, 0);
            
            
            //设置回调
            
            dispatch_source_set_event_handler(self.timer, ^{
                
          
                timeFlag++;
                
                
               // NSLog(@"count:%d",flag);
//                if (flag==3) {
//                    NSLog(@"结束时线程：%@",[NSThread currentThread]);
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self stopLoading];
//                        [self showHintMessage:@"请求已经超时了"];                    });
//                    count =0;
//                    
//                
//                    dispatch_cancel(self.timer);
//                }
                
                
    
    [CommonUtils postHttpWithUrlString:kOpendoorfeedbackUrl parameters:dict success:^(id data) {
     
   
    NSDictionary  *jsondic;
    jsondic=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];

    //NSLog(@"开门反馈：%@",jsondic);
                    
     id str =[CommonUtils parserData_key:data];
        
        
        
        //定时器取消条件
        //1.请求3次同时没有返回成功指令，取消请求
        if (timeFlag==3&&![str isEqualToString:kCode600]) {
        NSLog(@"timeFlag：%d",timeFlag);
           dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoading];
            [self showHintMessage:NSLocalizedString(@"The request timeout", nil)];                    });
          count =0;
        
        
        dispatch_cancel(self.timer);//取消定时器
        }
    
        
    //2.一旦返回成功指令，取消请求
    if ([str isEqualToString:kCode600]) {
        
                        
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopLoading];
        [self showHintMessage:NSLocalizedString(@"Successfully open the door", nil)];
    });
                    
    dispatch_cancel(self.timer);
    
  return ;
 }

                    
                    

    } failure:^(NSError *error) {
                    
        
          dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoading];
            [self showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
                    });
                    
             dispatch_cancel(self.timer);
                    return ;
                }];
                
                
                
            });
            
            
           
            
            dispatch_resume(self.timer);

        }
        
    } failure:^(NSError *error) {
        
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];
    
    
    
       
    
}

- (IBAction)DeleteAction:(id)sender {
    
    //SRLog(@"====%ld",(long)self.inputNumCount);
    if (self.inputNumCount>0) {
        --self.inputNumCount;
        NSMutableString  *str = [NSMutableString string];
        for (int i = 0; i<self.inputNumCount;i++ ) {
            [str appendString:@"*"];
            
        }
        self.passwordNumLabel.text = str;
        
      //  NSInteger codeValue = [self.buttonArr ];
        NSMutableString  * nuStr = [NSMutableString stringWithString:self.resultPassCode];
        self.resultPassCode = [nuStr substringToIndex:self.inputNumCount];
        
        
    }

   
    
    
    
}
@end
