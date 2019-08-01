//
//  JEVideoLocusTimeLapseView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/20.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEVideoLocusTimeLapseView.h"
#import "JEVideoLapseTableViewCell.h"
#import "QiSlider.h"

#define HEAD_HEIGHT 40
#define CELL_LEFT_WIDTH 5

@interface JEVideoLocusTimeLapseView () <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView                *headView;                  //顶部 view
@property (nonatomic, strong) UIVisualEffectView    *effeBackview;              //模糊背景 view
@property (nonatomic, strong) UILabel               *headLabel;                 //顶部 label
@property (nonatomic, strong) UIButton              *exitBtn;                   //退出 view
@property (nonatomic, strong) UIPickerView          *speedPickerView;           //云台速度选择器
@property (nonatomic, strong) UIPickerView          *pickerView;                //时间比例选择器
@property (nonatomic, strong) NSMutableArray        *speedPickerArray;          //云台速度数组
@property (nonatomic, strong) NSMutableArray        *pickerArray;               //时间比例数组

@end

@implementation JEVideoLocusTimeLapseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    //用于时间比例 pickerview 的旋转
    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    //模糊背景 view
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effeBackview = [[UIVisualEffectView alloc] initWithEffect:blur];
    _effeBackview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_effeBackview];
    
    //顶部视图
    _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEAD_HEIGHT)];
    _headLabel.text = NSLocalizedString(@"Path lapse settings", nil);
    _headLabel.textColor = [UIColor whiteColor];
    _headLabel.textAlignment = NSTextAlignmentCenter;
    _headLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_headLabel];
    
    //云台速度 label
    UILabel *speedPickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 100, 80, 50)];
    speedPickerLabel.text = NSLocalizedString(@"Gimbal Speed :", nil);
    speedPickerLabel.textColor = [UIColor whiteColor];
    speedPickerLabel.textAlignment = NSTextAlignmentLeft;
    speedPickerLabel.font = [UIFont systemFontOfSize:14];
//    speedPickerLabel.adjustsFontSizeToFitWidth = YES;
    speedPickerLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:speedPickerLabel];
    
    //云台速度 pickerview
    self.speedPickerView = [[UIPickerView alloc] init];
        _speedPickerView.backgroundColor = [UIColor clearColor];
        [_speedPickerView setTransform:transform];
        _speedPickerView.layer.borderColor = [UIColor clearColor].CGColor;
        _speedPickerView.frame = CGRectMake(80, self.frame.size.height - 100, self.frame.size.width - 80, 50);
        _speedPickerView.delegate = self;
        _speedPickerView.dataSource = self;
        [_speedPickerView selectRow:9 inComponent:0 animated:NO];
    [self addSubview:_speedPickerView];
    
    //时间比例 label
    UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 50, 100, 50)];
    pickerLabel.text = NSLocalizedString(@"Time scale: 1s = ", nil);
    pickerLabel.textColor = [UIColor whiteColor];
    pickerLabel.textAlignment = NSTextAlignmentLeft;
    pickerLabel.font = [UIFont systemFontOfSize:14];
//    pickerLabel.adjustsFontSizeToFitWidth = YES;
    pickerLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:pickerLabel];
    
    //时间比例 pickerview
    self.pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor clearColor];
        [_pickerView setTransform:transform];
        _pickerView.layer.borderColor = [UIColor clearColor].CGColor;
        _pickerView.frame = CGRectMake(80, self.frame.size.height - 50, self.frame.size.width - 80, 50);
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    [self addSubview:_pickerView];
    
    //延时关键点图片 tableview
    self.getPointTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headLabel.frame.size.height, 275, self.frame.size.height - _headLabel.frame.size.height - 100) style:UITableViewStylePlain];
        _getPointTableView.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height - _headLabel.frame.size.height - 100)/2 + _headLabel.frame.size.height);
        [_getPointTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _getPointTableView.backgroundColor = [UIColor clearColor];
        _getPointTableView.delegate = self;
        _getPointTableView.dataSource = self;
    [self addSubview:_getPointTableView];

}

- (void)loadData {
    
    //云台速度数组
    self.speedPickerArray = [[NSMutableArray alloc] init];
    for (int index = 1; index < 21; index ++) {
        [_speedPickerArray addObject:[NSString stringWithFormat:@"%d", index]];
    }
    
    //时间比例数组
    self.pickerArray = [[NSMutableArray alloc] init];
    for (int index = 1; index < 9; index ++) {
        [_pickerArray addObject:[NSString stringWithFormat:@"%ds", index * 15]];
    }
    self.pointPicArray = [[NSArray alloc] init];
    
    //云台速度和时间间隔 初始化
    self.deviceSpeed = 10;
    self.timeScale = 15;
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:_speedPickerView]) {
        return _speedPickerArray.count;
    }
    else {
        return _pickerArray.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

-  (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    itemLabel.backgroundColor = [UIColor clearColor];
    if ([pickerView isEqual:_speedPickerView]) {
        itemLabel.text = _speedPickerArray[row];
    }
    else {
        itemLabel.text = _pickerArray[row];
    }
    itemLabel.textColor = MAIN_TEXT_COLOR;
    itemLabel.textAlignment = NSTextAlignmentCenter;
    [itemLabel setTransform:transform];
    return itemLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:_speedPickerView]) {
        self.deviceSpeed = row+1;
        NSLog(@"云台速度: %@;", _speedPickerArray[row]);
    }
    else {
        self.timeScale = (row+1)*15;
        NSLog(@"时间比例是: %@;", _pickerArray[row]);
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pointPicArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JEVideoLapseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JEVideoLapseTableViewCell ID]];
    
    if (!cell) {
        cell = [[JEVideoLapseTableViewCell alloc] initWithFrame:CGRectMake(0, 0, 275, 100)];
    }
    
    //只有最后一行有点击事件
    if (indexPath.row == _pointPicArray.count) {
//        [cell.pointImage addTarget:self action:@selector(takePointPic) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePointPic)];
        tap.numberOfTapsRequired = 1;
        [cell.pointImage addGestureRecognizer:tap];
    }
    else {
        //将默认的图片换为拍摄的关键点照片，照片从缓存的地址去取
//        [cell.pointImage setImage:_pointPicArray[indexPath.row] forState:UIControlStateNormal];
        cell.pointImage.image = _pointPicArray[indexPath.row];
    }
    
    return cell;
}

#pragma mark - Action
- (void)takePointPic {
    NSLog(@"拍摄关键点");
    if (_pointPicArray.count > 9) {
        
        SHOW_HUD_DELAY(NSLocalizedString(@"Ten Key Shooting Points Maximum", nil), [UIApplication sharedApplication].keyWindow, 2);
        
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(takePointPicWithMotionLapse)]) {
        [self.delegate takePointPicWithMotionLapse];
    }
}

@end
