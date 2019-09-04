//
//  JEHitchcockSettingView.m
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/8/29.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEHitchcockSettingView.h"

#define HEAD_HEIGHT 40
#define Text_Font 16
#define Space_Left 5
#define Icon_Height 50

@interface JEHitchcockSettingView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView                *headView;          //顶部 View
@property (nonatomic, strong) UIVisualEffectView    *effeBackview;      //模糊背景 View
@property (nonatomic, strong) UILabel               *headLabel;         //顶部 label
@property (nonatomic, strong) UIPickerView          *timePickerView;    //拍摄时长 pickerview
@property (nonatomic, strong) UIPickerView          *orientationPickerView; //变焦方向 pickerview
@property (nonatomic, strong) NSMutableArray        *timeArray;         //拍摄时长 array
@property (nonatomic, strong) NSArray               *orientationArray;  //变焦方向 array

@end

@implementation JEHitchcockSettingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        [self setupUI];
    }
    return self;
}

- (void)loadData {
    //拍摄时长数组
    self.timeArray = [[NSMutableArray alloc] init];
    for (int index = 0; index < 15; index++) {
        [_timeArray addObject:[NSString stringWithFormat:@"%.1f", index*0.5 + 3]];
    }
    self.shootTimeLength = 3.0;
    
    //变焦方向数组
    self.orientationArray = @[JELocalizedString(@"Zoom up", nil), JELocalizedString(@"Zoom down", nil)];
    self.shootOrientation = 0;

}

- (void)setupUI {
    //用于 pickerview 的旋转
    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    //模糊背景 view
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effeBackview = [[UIVisualEffectView alloc] initWithEffect:blur];
    _effeBackview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_effeBackview];
    
    //顶部视图
    _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEAD_HEIGHT)];
    _headLabel.text = JELocalizedString(@"Hitchcock Settings", nil);
    _headLabel.textColor = [UIColor whiteColor];
    _headLabel.textAlignment = NSTextAlignmentCenter;
    _headLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_headLabel];
    
    //拍摄时长 label
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(Space_Left, 70, self.frame.size.width - 10, Icon_Height)];
    timeLabel.text = JELocalizedString(@"Shoot length(s)", nil);
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont systemFontOfSize:Text_Font];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:timeLabel];
    
    //拍摄时长 pickerview
    self.timePickerView = [[UIPickerView alloc] init];
        _timePickerView.backgroundColor = [UIColor clearColor];
        [_timePickerView setTransform:transform];
        _timePickerView.layer.borderColor = [UIColor clearColor].CGColor;
        _timePickerView.frame = CGRectMake(Space_Left, 120, self.frame.size.width - 10, Icon_Height);
        _timePickerView.delegate = self;
        _timePickerView.dataSource = self;
    [self addSubview:_timePickerView];
    
    //变焦方向 label
    UILabel *orientationLabel = [[UILabel alloc] initWithFrame:CGRectMake(Space_Left, 180, self.frame.size.width - 10, Icon_Height)];
    orientationLabel.text = JELocalizedString(@"Zoom direction", nil);
    orientationLabel.textColor = [UIColor whiteColor];
    orientationLabel.textAlignment = NSTextAlignmentLeft;
    orientationLabel.font = [UIFont systemFontOfSize:Text_Font];
    orientationLabel.adjustsFontSizeToFitWidth = YES;
    orientationLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:orientationLabel];
    
    //变焦方向 pickerview
    self.orientationPickerView = [[UIPickerView alloc] init];
        _orientationPickerView.backgroundColor = [UIColor clearColor];
        [_orientationPickerView setTransform:transform];
        _orientationPickerView.layer.borderColor = [UIColor clearColor].CGColor;
        _orientationPickerView.frame = CGRectMake(Space_Left, 220, self.frame.size.width - 10, Icon_Height);
        _orientationPickerView.delegate = self;
        _orientationPickerView.dataSource = self;
    [self addSubview:_orientationPickerView];
    
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:_timePickerView]) {
        return _timeArray.count;
    }
    else {
        return _orientationArray.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    if ([pickerView isEqual:_timePickerView]) {
        return 60;
    }
    else {
        return 100;
    }
}

-  (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    
    UILabel *itemLabel = [[UILabel alloc] init];
    [itemLabel setTransform:transform];
    itemLabel.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    itemLabel.backgroundColor = [UIColor clearColor];
    if ([pickerView isEqual:_timePickerView]) {
        itemLabel.text = _timeArray[row];
    }
    else {
        itemLabel.text = _orientationArray[row];
    }
    itemLabel.textColor = MAIN_TEXT_COLOR;
    itemLabel.textAlignment = NSTextAlignmentCenter;
    return itemLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:_timePickerView]) {
        NSLog(@"云台速度: %@;", _timeArray[row]);
        self.shootTimeLength = [_timeArray[row] floatValue];
    }
    else {
        NSLog(@"时间比例是: %@;", _orientationArray[row]);
        self.shootOrientation = row;
    }
}

@end
