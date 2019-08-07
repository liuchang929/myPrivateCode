//
//  JEGyroCalibrationViewController.m
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/8/6.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEGyroCalibrationViewController.h"
#import "XFStepView.h"
#import "SDRotationLoopProgressView.h"

@interface JEGyroCalibrationViewController ()

//base
@property (nonatomic, strong) UIView *titleView;    //顶部 view
@property (nonatomic, strong) UIView *contentView;  //内容 view

//icon
@property (nonatomic, strong) UIButton      *backBtn;       //返回键
@property (nonatomic, strong) UILabel       *titleLabel;    //标题栏
@property (nonatomic, strong) XFStepView    *stepView;     //步骤指示条
@property (nonatomic, strong) UIButton      *nextBtn;       //下一步按钮
@property (nonatomic, strong) UIView        *hintView;      //提示内容
@property (nonatomic, strong) SDRotationLoopProgressView *progressView; //进度循环圈
@property (nonatomic, strong) UILabel       *step1Label;
@property (nonatomic, strong) UIImageView   *step2View;
@property (nonatomic, strong) UILabel       *step2Label;
@property (nonatomic, strong) UILabel       *step2Label2;
@property (nonatomic, strong) UILabel       *step3Label;
@property (nonatomic, strong) UIImageView   *step4View;
@property (nonatomic, strong) UILabel       *step4Label;

@end

@implementation JEGyroCalibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupUI];
}

- (void)setupUI {
    //顶部
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SAFE_AREA_TOP_HEIGHT)];
    _titleView.backgroundColor = MAIN_TABBAR_COLOR;
    [self.view addSubview:self.titleView];
    
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, SAFE_AREA_TOP_HEIGHT - 50, 50, 50)];
    [_backBtn setImage:[UIImage imageNamed:@"icon_cameraSetting_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.backBtn];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _titleLabel.text = NSLocalizedString(@"Pan-Tilt Calibration", nil);
    _titleLabel.textColor = MAIN_TEXT_COLOR;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.center = CGPointMake(self.titleView.center.x, self.backBtn.center.y);
    [self.titleView addSubview:self.titleLabel];
    
    //内容
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SAFE_AREA_TOP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - SAFE_AREA_TOP_HEIGHT)];
    self.contentView.backgroundColor = MAIN_BACKGROUND_COLOR;
    [self.view addSubview:self.contentView];
    
    self.stepView = [[XFStepView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 60) Titles:[NSArray arrayWithObjects:NSLocalizedString(@"Step 1", nil), NSLocalizedString(@"Step 2", nil), NSLocalizedString(@"Step 3", nil), NSLocalizedString(@"Step 4", nil), nil]];
    [self.contentView addSubview:self.stepView];
    
    self.hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, self.view.frame.size.width, self.view.frame.size.width)];
    [self.contentView addSubview:self.hintView];
    
    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    _nextBtn.center = CGPointMake(self.view.center.x, _hintView.frame.origin.y + self.view.frame.size.width + 50);
    [_nextBtn setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [_nextBtn setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [_nextBtn setBackgroundColor:MAIN_BLUE_COLOR];
    _nextBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _nextBtn.layer.cornerRadius = 25;
    [_nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.nextBtn];
    
    [self setupStep1];
    
}

- (void)setupStep1 {
    self.step1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width, 100)];
    _step1Label.adjustsFontSizeToFitWidth = YES;
    _step1Label.center = CGPointMake(_hintView.frame.size.width/2, _hintView.frame.size.width/2);
    _step1Label.textAlignment = NSTextAlignmentCenter;
    _step1Label.numberOfLines = 2;
    _step1Label.text = NSLocalizedString(@"The cradle head motor has been turned off. Please remove the mobile phone \nand click \"Next\" to start calibration", nil);
    _step1Label.textColor = MAIN_TEXT_COLOR;
    [self.hintView addSubview:self.step1Label];
}

- (void)setupStep2 {
    if (_step1Label) {
        [self.step1Label removeFromSuperview];
    }
    
    self.step2View = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width - 100, _hintView.frame.size.width - 100)];
    _step2View.center = CGPointMake(_hintView.frame.size.width/2, (_hintView.frame.size.width - 100)/2);
    _step2View.image = [UIImage imageNamed:@"image_gyro_step2"];
    _step2View.contentMode = UIViewContentModeScaleAspectFit;
    [self.hintView addSubview:self.step2View];
    
    self.step2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width, 50)];
    _step2Label.adjustsFontSizeToFitWidth = YES;
    _step2Label.center = CGPointMake(_hintView.frame.size.width/2, _hintView.frame.size.height - 100);
    _step2Label.textAlignment = NSTextAlignmentCenter;
    _step2Label.numberOfLines = 2;
    _step2Label.text = NSLocalizedString(@"Place the cradle head as shown in the picture, \nand click \"Start calibration\".", nil);
    _step2Label.textColor = MAIN_TEXT_COLOR;
    [self.hintView addSubview:_step2Label];
    
    self.step2Label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width, 50)];
    _step2Label2.adjustsFontSizeToFitWidth = YES;
    _step2Label2.center = CGPointMake(_hintView.frame.size.width/2, _hintView.frame.size.height - 50);
    _step2Label2.textAlignment = NSTextAlignmentCenter;
    _step2Label2.numberOfLines = 2;
    _step2Label2.text = NSLocalizedString(@"Attention: the cradle head calibration needs to be placed on an absolutely stable plane. \nIt is recommended to place it on the ground for calibration", nil);
    _step2Label2.textColor = [UIColor redColor];
    [self.hintView addSubview:_step2Label2];
}

- (void)setupStep3 {
    if (_step2View) {
        [self.step2View removeFromSuperview];
    }
    if (_step2Label) {
        [self.step2Label removeFromSuperview];
    }
    if (_step2Label2) {
        [self.step2Label2 removeFromSuperview];
    }
    
    self.progressView = [[SDRotationLoopProgressView alloc] initWithFrame:CGRectMake((_hintView.frame.size.width-200)/2, (_hintView.frame.size.height-200)/2, 200, 200)];
    _progressView.backgroundColor = [UIColor lightGrayColor];
    [self.hintView addSubview:self.progressView];
    
    self.step3Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width, 100)];
    _step3Label.adjustsFontSizeToFitWidth = YES;
    _step3Label.center = CGPointMake(_hintView.frame.size.width/2, _hintView.frame.size.height - 50);
    _step3Label.textAlignment = NSTextAlignmentCenter;
    _step3Label.numberOfLines = 1;
    _step3Label.text = NSLocalizedString(@"Do not move the device during calibration", nil);
    _step3Label.textColor = MAIN_TEXT_COLOR;
    [self.hintView addSubview:self.step3Label];
}

- (void)setupStep4 {
    if (_progressView) {
        [self.progressView removeFromSuperview];
    }
    
    if (_step3Label) {
        [self.step3Label removeFromSuperview];
    }
    
    self.step4View = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width - 200, _hintView.frame.size.width - 100)];
    _step4View.center = CGPointMake(_hintView.frame.size.width/2, (_hintView.frame.size.width - 100)/2);
    _step4View.image = [UIImage imageNamed:@"view_gyro_success"];
    _step4View.contentMode = UIViewContentModeScaleAspectFit;
    [self.hintView addSubview:_step4View];
    
    self.step4Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hintView.frame.size.width, 100)];
    _step4Label.center = CGPointMake(_hintView.frame.size.width/2, _hintView.frame.size.height - 50);
    _step4Label.textAlignment = NSTextAlignmentCenter;
    _step4Label.numberOfLines = 2;
    _step4Label.adjustsFontSizeToFitWidth = YES;
    _step4Label.text = NSLocalizedString(@"The calibration is successful. Please put the phone back on the cradle head and click \"Complete calibration\".", nil);
    _step4Label.textColor = MAIN_TEXT_COLOR;
    [self.hintView addSubview:_step4Label];
    
}

#pragma mark - Action
- (void)backBtnAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)nextBtnAction {
    NSLog(@"下一步 = %d", _stepView.stepIndex);
    if (_stepView) {
        switch (_stepView.stepIndex) {
            case 0:
            {
                //准备校准
                [self setupStep2];
                [_nextBtn setTitle:NSLocalizedString(@"Start calibration", nil) forState:UIControlStateNormal];
            }
                break;
                
            case 1:
            {
                //开始校准
                [self setupStep3];
                _nextBtn.hidden = YES;
                [[JEBluetoothManager shareBLESingleton] BPGyroscopeCalibration];    //开始校准
            }
                break;
                
            case 2:
            {
                //校准中
                [self setupStep4];
                _nextBtn.hidden = NO;
                [_nextBtn setTitle:NSLocalizedString(@"Complete calibration", nil) forState:UIControlStateNormal];
            }
                break;
                
            case 3:
            {
                //结束校准
                [[JEBluetoothManager shareBLESingleton] BPQuitCalibrationMode];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
                break;
                
            default:
                break;
        }
        [_stepView setStepIndex:_stepView.stepIndex + 1 Animation:YES];
    }
}

- (void)accelerationSuccess {
    //校准完成
    [self nextBtnAction];
}

@end
