//
//  DatePickerViewController.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/15.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "DatePickerViewController.h"
#import "CustomTextField.h"
#import "SRTimeInfo.h"
#import "CommonUtils.h"
#import "Macros.h"
#import "SRCabinetInfo.h"
#import "UIView+Sizes.h"
#import "KeyIMEIArrEntity.h"

@interface DatePickerViewController () <UIAlertViewDelegate>
@property (nonatomic,strong) UIImageView  *backgoundView;
@property (nonatomic, strong) CustomTextField *startDateField;
@property (nonatomic, strong) CustomTextField *endDateField;
@property (nonatomic, strong) UIDatePicker     *startDatePicker;
@property (nonatomic, strong) UIDatePicker     *endDatePicker;
@property (nonatomic, strong) UIButton *sureBtn;
//model
@property (nonatomic, strong) NSString  *startTimerStr;
@property (nonatomic, strong) NSDate  *startTimerDate;
@property (nonatomic, strong) NSString  *endTimerStr;
@property (nonatomic, strong) NSDate  *endTimerDate;


@property (nonatomic,assign) int type;

@end
@implementation DatePickerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}





-(void)saveType:(int)type{
    
    _type = type;
    
    
}

#pragma mark - 点击确认
-(void)sureAction{
    
    //输入有效的时间
    if (self.startTimerStr.length==0||self.endTimerStr.length==0) {
        [self showHintMessage:NSLocalizedString(@"Please enter the time", nil)];
        return;
    }
    
    
    
    //判断开始时间必须大于结束时间
    int  temp = [CommonUtils compareDate:_startTimerStr withDate:_endTimerStr];

        if (temp!=1) {
            [self showAlert:NSLocalizedString(@"TimeCue", nil) cancelTitle:@"OK"];
            return;
        }
    
    
    
    //判断查询的类型(警报记录，开门记录，关门记录)
    NSString  *urlStr = @"";//判断查询的类型对应的请求url
    NSString * typeStr = @"";//判断查询的类型是开门记录还是关门记录type
    
    switch (self.type) {
        case 0:
            urlStr = kAlarmrecodeUrl;
            break;
            
        case 1:
            urlStr = kDoorrecodeUrl;
            break;
        case 2:
            urlStr = kDoorrecodeUrl;
            break;
        default:
            break;
    }
    
    
    
    switch (self.type) {
        case 0:
            typeStr = @"";
            break;
            
        case 1:
            typeStr = kClosedoorType;
            break;
        case 2:
            typeStr = kOpendoorType;
            break;
        default:
            break;
    }
    

    
    
    NSString *startStr = [NSString stringWithFormat:@"%0.f",[_startTimerDate timeIntervalSince1970]*1000];
    NSString *endStr = [NSString stringWithFormat:@"%0.f",[_endTimerDate timeIntervalSince1970]*1000];
    
    
    [SRTimeInfo sharedInstance].startTimeIntervalStr = startStr;
    [SRTimeInfo sharedInstance].endTimeIntervalStr = endStr;
    
    NSString *didStr =  [SRCabinetInfo sharedInstance].deviceIMEI;
    if (!didStr.length) {
        [self showHintMessage:NSLocalizedString(@"Get device ID error", nil)];
        return;
    }
    
    
    //配置传入参数:did,page,stime,etime,type(type用于判断时开门记录还是关门记录)

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (typeStr.length) {
        [dict setObject:typeStr forKey:kTypeKey];
    }
    [dict setObject:didStr forKey:kDidKey];
    [dict setObject:startStr forKey:kStimeKey];
    [dict setObject:endStr forKey:kEtimeKey];
    
    
    
    
  
    
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [CommonUtils postHttpWithUrlString:urlStr parameters:dict success:^(id data) {
        
        [weakSelf stopLoading];
              
//        NSDictionary  *jsondic;
//        jsondic=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
//         SRLog(@"选择日期对应的%@",jsondic) ;
        if ([[CommonUtils parserCode_key:data] isEqualToString:kCode0]) {
            id temp = [CommonUtils parserData_key:data];
            
            if (![temp isKindOfClass:[NSDictionary class]]) {
                [self showHintMessage:NSLocalizedString(@"Data error", nil)];
                return;
            }
            
            
            NSArray  *arr =[temp valueForKey:@"rows"];
           // NSLog(@"=====%li",arr.count);
            if (arr.count) {
                //单例保存数据
                KeyIMEIArrEntity  *keyArrEntity =[KeyIMEIArrEntity sharedInstance];
                [keyArrEntity.recordArr removeAllObjects];
                for (NSDictionary * time in arr) {
                    [keyArrEntity.recordArr addObject:time];
                }
                
                [SRTimeInfo sharedInstance].startTimeStr = _startTimerStr;
                [SRTimeInfo sharedInstance].endTimeStr = _endTimerStr;
                [SRTimeInfo sharedInstance].recordtotal = [temp valueForKey:@"total"];
                

                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            }else{

                [weakSelf showAlert:NSLocalizedString(@"This time period is not recorded", nil) cancelTitle:@"OK"];
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
        
        NSLog(@"===%@",error);
        [weakSelf stopLoading];
        [weakSelf showHintMessage:NSLocalizedString(@"AbnormalNetwork", nil)];
        
        
    }];

    
    
    
}


























-(void)setupSubViews{
    self.title = NSLocalizedString(@"Please select date", nil);
    self.view.backgroundColor = kColorBlack;
    _backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self.view addSubview:_backgoundView];
    
    
    //开始时间输入框
    self.startDateField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    [self.startDateField setPlaceholderText:NSLocalizedString(@"Click to select the start time", nil)];
    [self.startDateField.textField setValue:[UIColor whiteColor]forKeyPath:@"_placeholderLabel.textColor"];
    self.startDateField.textField.textColor = kColorWhite;
    [self.startDateField setBottomLine];
    [self.view addSubview:self.startDateField];
    
    
    
    _startDatePicker=[[UIDatePicker alloc]init];
    [_startDatePicker setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
    _startDatePicker.datePickerMode=UIDatePickerModeDate;
    self.startDateField.textField.inputView=_startDatePicker;

    //创建工具条
    UIToolbar *startToolbar=[[UIToolbar alloc]init];
    //设置工具条的颜色
    startToolbar.barTintColor=[UIColor whiteColor];
    //设置工具条的frame
    startToolbar.frame=CGRectMake(0, 0, 320, 44);
    
    UIBarButtonItem *startItem=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(startDateEvent)];
    
    startToolbar.items = @[startItem];
    //设置文本输入框键盘的辅助视图
    self.startDateField.textField.inputAccessoryView=startToolbar;
    
    
    
    
    
    //结束时间输入框
    _endDatePicker=[[UIDatePicker alloc]init];
    [_endDatePicker setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
    
    _endDatePicker.datePickerMode=UIDatePickerModeDate;
    self.endDateField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    
    [self.endDateField setPlaceholderText:NSLocalizedString(@"Click to select the end time", nil)];
    [self.endDateField.textField setValue:[UIColor whiteColor]forKeyPath:@"_placeholderLabel.textColor"];
    [self.endDateField setBottomLine];
    [self.view addSubview:self.endDateField];
    self.endDateField.textField.inputView=_endDatePicker;
    self.endDateField.textField.textColor = kColorWhite;

    //创建工具条
    UIToolbar *endToolbar=[[UIToolbar alloc]init];
    //设置工具条的颜色
    endToolbar.barTintColor=[UIColor whiteColor];
    //设置工具条的frame
    endToolbar.frame=CGRectMake(0, 0, 320, 44);
    
    UIBarButtonItem *endItem=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(endDateEvent)];
    
    endToolbar.items = @[endItem];
    //设置文本输入框键盘的辅助视图
    self.endDateField.textField.inputAccessoryView=endToolbar;
    
    
    
    
    //确定按钮
    self.sureBtn = [[UIButton alloc]init];
    [self.sureBtn setTitle:NSLocalizedString(@"Sure", nil) forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.sureBtn setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateDisabled];
    
    
    [self.sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.enabled = YES;
    
    self.sureBtn.layer.borderWidth = 1.f;
    self.sureBtn.layer.borderColor = kColorBlue.CGColor;
    self.sureBtn.layer.cornerRadius = 15.0f;
    [self.view addSubview:self.sureBtn];
    
    [self addTapGesture];
    

}


-(void)startDateEvent{
    
    [self.startDateField.textField resignFirstResponder];
    NSDateFormatter * dateF = [[NSDateFormatter alloc]init];//格式化
    
    [dateF setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString* temp = [dateF stringFromDate:_startDatePicker.date];
    _startTimerDate =_startDatePicker.date;
   // NSLog(@" s1s1s1s%@",temp);
    self.startTimerStr = temp;
    self.startDateField.textField.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Starting time", nil),temp];
    
}

-(void)endDateEvent{
    
    [self.endDateField.textField resignFirstResponder];
    NSDateFormatter * dateF = [[NSDateFormatter alloc]init];//格式化
    
    [dateF setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString* temp = [dateF stringFromDate:_endDatePicker.date];
    _endTimerDate = _endDatePicker.date;
    self.endTimerStr = temp;
    self.endDateField.textField.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"End time", nil),temp];
    
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgoundView.frame = self.view.bounds;
    CGFloat fieldHeight = [self.startDateField viewHeight];
    self.startDateField.frame = CGRectMake(20.f, 64.f, self.view.width-40.f, fieldHeight);
    self.endDateField.frame = CGRectMake(20.f, self.startDateField.bottom, self.view.width-40.f, fieldHeight);

    
    self.sureBtn.frame = CGRectMake(15.f, self.endDateField.bottom + 30.f, self.view.width - 30.f, 44.f);
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}



@end

