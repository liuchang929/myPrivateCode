//
//  JEVideoTimeLapseView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/25.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEVideoTimeLapseView.h"

//顶部视图的高度
#define HEAD_HEIGHT 50

@interface JEVideoTimeLapseView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView                *backView;          //背景 view
@property (nonatomic, strong) UIVisualEffectView    *effeView;          //模糊 view
@property (nonatomic, strong) UIPickerView          *timeLapsePicker;   //延时比例 picker

@property (nonatomic, strong) NSMutableArray        *timeLapseArray;    //延时比例数组

@end

@implementation JEVideoTimeLapseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        [self setupUI];
        
    }
    return self;
}

- (void)setupUI {
    //背景视图
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _backView.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _effeView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _effeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [_backView addSubview:_effeView];
    [self addSubview:_backView];
    
    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 110, 25)];
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Time scale: 1s = ", nil)];
    NSRange selfRange = NSMakeRange(5, 5);
    speedLabel.textColor = [UIColor whiteColor];
    speedLabel.alpha  = 0.7;
    speedLabel.font = [UIFont systemFontOfSize:14];
    [noteStr addAttribute:NSForegroundColorAttributeName value:MAIN_TEXT_COLOR range:selfRange];
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:selfRange];
    [speedLabel setAttributedText:noteStr];
    speedLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:speedLabel];
    
    self.timeLapsePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(120, 27, self.frame.size.width - 150, 50)];
    _timeLapsePicker.backgroundColor = [UIColor clearColor];
    _timeLapsePicker.layer.borderColor = [UIColor clearColor].CGColor;
    _timeLapsePicker.delegate = self;
    _timeLapsePicker.dataSource = self;
    [_timeLapsePicker selectRow:USER_GET_SaveTimelapseProportion_Interger inComponent:0 animated:NO];
    [self addSubview:_timeLapsePicker];
    
    UILabel *ls = [[UILabel alloc] initWithFrame:CGRectMake(_timeLapsePicker.frame.origin.x + _timeLapsePicker.frame.size.width + 10, 40, 10, 25)];
    ls.textColor = MAIN_TEXT_COLOR;
    ls.font = [UIFont systemFontOfSize:14];
    ls.text = @"s";
    ls.alpha = 0.7;
    [self addSubview:ls];
}

- (void)loadData {
    self.timeLapseArray = [[NSMutableArray alloc] init];
    for (int index = 1; index < 9; index++) {
        [self.timeLapseArray addObject:[NSString stringWithFormat:@"%d", index * 15]];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timeLapseArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    cellLabel.text = _timeLapseArray[row];
    cellLabel.textAlignment = NSTextAlignmentCenter;
    cellLabel.textColor = MAIN_TEXT_COLOR;
    return cellLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED {
    NSLog(@"选择了 %ld 行", (long)row);
    USER_SET_SaveTimelapseProportion_Integer(row + 1);
}


@end
