//
//  JECameraSettingView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraSettingView.h"
#import "JECameraSettingTableViewCell.h"
//#import "JESettingPickerView.h"

//顶部视图的高度
#define HEAD_HEIGHT 40
//tableview cell 的高度
#define CELL_HEIGHT 45
//cell icon 的高度和宽度
#define CELL_ICON_HEIGHT 30
#define CELL_ICON_TOPLEFT_WIDTH 7.5
#define CELL_ICON_RIGHT_WIDTH 35
//动画时长
#define ANIMATE_TIME 0.4

@interface JECameraSettingView () <UITableViewDelegate, UITableViewDataSource, JECameraSettingOptionsViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView                    *headView;      //顶部 View
@property (nonatomic, strong) UIView                    *backView;      //背景 View
@property (nonatomic, strong) UIVisualEffectView        *effeView;      //模糊 View
@property (nonatomic, strong) UILabel                   *headLabel;     //顶部 Label

@property (nonatomic, strong) NSArray *auxiliaryLinesArray;     //辅助线
@property (nonatomic, strong) NSArray *flashArray;              //闪光灯

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation JECameraSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        
        //背景视图
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effeView = [[UIVisualEffectView alloc]initWithEffect:blur];
        _effeView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_backView addSubview:_effeView];
        [self addSubview:_backView];
        
        //顶部视图
        self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, HEAD_HEIGHT)];
        _headView.backgroundColor = [UIColor blackColor];
        _headView.alpha = 0.5;
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _headView.frame.size.width, _headView.frame.size.height)];
        _headLabel.textColor = [UIColor whiteColor];
        _headLabel.textAlignment = NSTextAlignmentCenter;
        _headLabel.backgroundColor = [UIColor blackColor];
        _headLabel.alpha = 0.5;
        [_headView addSubview:_headLabel];
        [self addSubview:_headView];
        
        //设置列表
        self.tableView = [[JECameraSettingTableView alloc] initWithFrame:CGRectMake(0, HEAD_HEIGHT, frame.size.width, frame.size.height - HEAD_HEIGHT)];
        [self cellLineMoveLeft];
        _tableView.separatorColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    
    }
    return self;
}

- (void)resetUISize:(CGSize)size {
    self.backView.frame = CGRectMake(0, 0, size.width, size.height);
    self.effeView.frame = CGRectMake(0, 0, size.width, size.height);
    self.headView.frame = CGRectMake(0, 0, size.width, HEAD_HEIGHT);
    self.headLabel.frame = CGRectMake(0, 0, size.width, HEAD_HEIGHT);
    self.tableView.frame = CGRectMake(0, HEAD_HEIGHT, size.width, size.height - HEAD_HEIGHT);
    
    if (_optionsView.isHidden == NO) {
        _optionsView.frame = CGRectMake(0, 0, size.width, size.height);
        [_optionsView resetUISize:CGSizeMake(size.width, size.height)];
    }
}

#pragma mark - Action
- (void)loadData {
    //辅助线
    self.auxiliaryLinesArray = @[@{@"option":@"None", @"image":@"icon_cameraSetting_auxiliaryLine_none"},
                                 @{@"option":@"Grid", @"image":@"icon_cameraSetting_auxiliaryLine_square"},
                                 @{@"option":@"Grid+Diagonal", @"image":@"icon_cameraSetting_auxiliaryLine_squareDiagonal"},
                                 @{@"option":@"Center point", @"image":@"icon_cameraSetting_auxiliaryLine_centerPoint"}];
    
    //闪光灯
    self.flashArray = @[@{@"option":@"Off", @"image":@"icon_cameraSetting_flash_off"},
                        @{@"option":@"On", @"image":@"icon_cameraSetting_flash_on"},
                        @{@"option":@"Auto", @"image":@"icon_cameraSetting_flash_auto"}];
    
    _array = [[NSMutableArray alloc] init];
    for (int index = 1; 5 * index < 101; index ++) {
        [_array addObject:[NSString stringWithFormat:@"%d",5*index]];
    }
}

- (void)hiddenAllBase {
    if (_backView.hidden == YES) {
        _backView.hidden = NO;
        _headView.hidden = NO;
        _tableView.hidden = NO;
        [_tableView reloadData];
    }
    else {
        _backView.hidden = YES;
        _headView.hidden = YES;
        _tableView.hidden = YES;
    }
}

- (void)cleanCameraSettingOption {
    _optionsView.hidden = YES;
    
    _backView.hidden = NO;
    _headView.hidden = NO;
    _tableView.hidden = NO;
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSLog(@"slider.value = %f", slider.value);
}

- (void)switchChanged:(UISwitch *)swi {
    
    NSLog(@"swi.tag = %ld", swi.tag);
    if (swi.tag == 292) {
        //电影镜头
        
        USER_SET_SaveFilmCameraState_BOOL(swi.on);
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(filmCameraAction:)]) {
            [self.delegate filmCameraAction:USER_GET_SaveFilmCameraState_BOOL];
        }
        
        [_tableView reloadData];
        return;
    }
    
    if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
        if (swi.tag == 293) {
            //充电使用设备
            USER_SET_SaveChargingSwitchState_BOOL(!swi.on);
            [[JEBluetoothManager shareBLESingleton] BPChangeChargingState:(!USER_GET_SaveChargingSwitchState_BOOL)];
            
        }
        if (swi.tag == 294) {
            //俯仰反向
            USER_SET_SavePitchOrientationOpposite_BOOL(swi.on);
            [[JEBluetoothManager shareBLESingleton] BPSendPitchOrientationOpposite];
        }
        [_tableView reloadData];
    }
    else {
        SHOW_HUD_DELAY(NSLocalizedString(@"Please connect the device", nil), [UIApplication sharedApplication].keyWindow, 1.5);
    }
}

- (void)setUpdateButtonHidden:(BOOL)hide {
    self.updateVersionButton.hidden = hide;
    NSLog(@"按钮隐藏 = %d", _updateVersionButton.isHidden);
}

- (void)updateVerAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceUpdateAction)]) {
        [self.delegate deviceUpdateAction];
    }
}

- (void)updateAppAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appUpdateAction)]) {
        [self.delegate appUpdateAction];
    }
}
#pragma mark - UITableViewDelegate&&UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _settingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JECameraSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JECameraSettingTableViewCell ID]];
    if (!cell) {
        cell = [[JECameraSettingTableViewCell alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, CELL_HEIGHT)];
    }
    
    //左侧的文字
    cell.cellName.text = NSLocalizedString([_settingArray[indexPath.row] valueForKey:@"name"], nil);
    
    //右侧的小箭头
    if ([[_settingArray[indexPath.row] valueForKey:@"type"] isEqualToString:@"yes"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //右侧的提示图标
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(cell.cellView.frame.size.width - CELL_ICON_HEIGHT - CELL_ICON_RIGHT_WIDTH, CELL_ICON_TOPLEFT_WIDTH, CELL_ICON_HEIGHT, CELL_ICON_HEIGHT)];
    switch (_settingMode) {
        case cameraSetting: {
            //相机设置
            _headLabel.text = NSLocalizedString(@"Camera Settings", nil);
            
            switch (indexPath.row) {
                case 0: {
                    //辅助线
                    [icon setImage:[UIImage imageNamed:[_auxiliaryLinesArray[USER_GET_SaveAuxLines_Integer] valueForKey:@"image"]]];
                    [cell.cellView addSubview:icon];
                }
                    break;
                    
                case 1: {
                    //闪光灯
                    [icon setImage:[UIImage imageNamed:[_flashArray[USER_GET_SaveFlashMode_Integer] valueForKey:@"image"]]];
                    [cell.cellView addSubview:icon];
                }
                    break;
                    
                case 2: {
                    //视频分辨率
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH, CELL_ICON_HEIGHT)];
                    label.text = [_videoResolutionArray[USER_GET_SaveVideoResolution_Integer] valueForKey:@"option"];
                    label.textAlignment = NSTextAlignmentRight;
                    label.textColor = [UIColor whiteColor];
                    [cell.cellView addSubview:label];
                }
                    break;
                    
                case 3: {
                    //电影镜头
                    UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(cell.cellView.frame.size.width - 3*CELL_ICON_HEIGHT, 7.5, CELL_ICON_HEIGHT, CELL_ICON_HEIGHT)];
                    swi.tag = 292;
                    [swi setOnTintColor:MAIN_BLUE_COLOR];
                    [swi setTintColor:[UIColor whiteColor]];
                    [swi setOn:USER_GET_SaveFilmCameraState_BOOL];
                    [swi addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                    
                    [cell.cellView addSubview:swi];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
         
        case deviceSetting: {
            //设备设置
            _headLabel.text = NSLocalizedString(@"Device Settings", nil);
            switch (indexPath.row) {
                case 0: {
                    //设备充电状态
                    UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(cell.cellView.frame.size.width - 3*CELL_ICON_HEIGHT, 7.5, CELL_ICON_HEIGHT, CELL_ICON_HEIGHT)];
                    swi.tag = 293;
                    [swi setOnTintColor:MAIN_BLUE_COLOR];
                    [swi setTintColor:[UIColor whiteColor]];
                    [swi setOn:USER_GET_SaveChargingSwitchState_BOOL];
                    [swi addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                    
                    [cell.cellView addSubview:swi];
                }
                    break;
                    
                case 1: {
                    //俯仰轴推动反向
                    UISwitch *swi = [[UISwitch alloc] initWithFrame:CGRectMake(cell.cellView.frame.size.width - 3*CELL_ICON_HEIGHT, 7.5, CELL_ICON_HEIGHT, CELL_ICON_HEIGHT)];
                    swi.tag = 294;
                    [swi setOnTintColor:MAIN_BLUE_COLOR];
                    [swi setTintColor:[UIColor whiteColor]];
                    [swi setOn:USER_GET_SavePitchOrientationOpposite_BOOL];
                    [swi addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
                    [cell.cellView addSubview:swi];
                }
                    break;
                    
                case 2: {
                    //加速度校准
                }
                    break;
                    
                case 3: {
                    //当前固件版本
                    self.updateVersionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH * 3, CELL_ICON_HEIGHT)];
                    [_updateVersionButton setTitle:NSLocalizedString(@"Firmware Update", nil) forState:UIControlStateNormal];
                    [_updateVersionButton setTitleColor:MAIN_BLUE_COLOR forState:UIControlStateNormal];
                    _updateVersionButton.layer.borderWidth = 1;
                    _updateVersionButton.layer.borderColor = [UIColor whiteColor].CGColor;
                    [_updateVersionButton.layer setMasksToBounds:YES];
                    [_updateVersionButton.layer setCornerRadius:10];
                    _updateVersionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    [_updateVersionButton addTarget:self action:@selector(updateVerAction) forControlEvents:UIControlEventTouchUpInside];
                    [cell.cellView addSubview:_updateVersionButton];
                    
                    if ([[JEBluetoothManager shareBLESingleton] getBLEState] == Connect) {
                        if (USER_GET_SaveVersionFirmware_NSString == NULL || ([USER_GET_SaveVersionNewFirmware_NSString compare:USER_GET_SaveVersionFirmware_NSString] == NSOrderedDescending)) {
                            self.updateVersionButton.hidden = NO;
                        }
                        else {
                            self.updateVersionButton.hidden = YES;
                        }
                    }
                    else {
                        self.updateVersionButton.hidden = YES;
                    }
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH, CELL_ICON_HEIGHT)];
                    label.text = USER_GET_SaveVersionFirmware_NSString;
                    label.textAlignment = NSTextAlignmentRight;
                    label.textColor = [UIColor whiteColor];
                    [cell.cellView addSubview:label];
                }
                    break;
                    
                case 4: {
                    //当前硬件版本
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH, CELL_ICON_HEIGHT)];
                    label.text = USER_GET_SaveVersionHardware_NSString;
                    label.textAlignment = NSTextAlignmentRight;
                    label.textColor = [UIColor whiteColor];
                    [cell.cellView addSubview:label];
                }
                    break;
                    
                case 5: {
                    //蓝牙固件版本
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH, CELL_ICON_HEIGHT)];
                    label.text = USER_GET_SaveVersionBluetooth_NSString;
                    label.textAlignment = NSTextAlignmentRight;
                    label.textColor = [UIColor whiteColor];
                    [cell.cellView addSubview:label];
                }
                    break;
                    
                case 6: {
                    //当前 app 版本
                    self.appVersionButton = [[UIButton alloc] initWithFrame:CGRectMake(-20, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH * 3, CELL_ICON_HEIGHT)];
                    [_appVersionButton setTitle:NSLocalizedString(@"Version update", nil) forState:UIControlStateNormal];
                    [_appVersionButton setTitleColor:MAIN_BLUE_COLOR forState:UIControlStateNormal];
                    _appVersionButton.layer.borderWidth = 1;
                    _appVersionButton.layer.borderColor = [UIColor whiteColor].CGColor;
                    [_appVersionButton.layer setMasksToBounds:YES];
                    [_appVersionButton.layer setCornerRadius:10];
                    _appVersionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    [_appVersionButton addTarget:self action:@selector(updateAppAction) forControlEvents:UIControlEventTouchUpInside];
                    [cell.cellView addSubview:_appVersionButton];
                    
                    if ([USER_GET_SaveVersionNewAPP_NSString compare:USER_GET_SaveVersionAPP_NSString] == NSOrderedDescending) {
                        self.appVersionButton.hidden = NO;
                    }
                    else {
                        self.appVersionButton.hidden = YES;
                    }
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_ICON_TOPLEFT_WIDTH/2, _backView.frame.size.width/2 - CELL_ICON_RIGHT_WIDTH, CELL_ICON_HEIGHT)];
                    label.text = APP_VERSION;
                    label.textAlignment = NSTextAlignmentRight;
                    label.textColor = [UIColor whiteColor];
                    [cell.cellView addSubview:label];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_settingMode) {
        case cameraSetting: {
            if (indexPath.row == 3) {
                return;
            }
            if (!_optionsView) {
                if (_backView.frame.size.width > _backView.frame.size.height) {
                    //竖屏
                    self.optionsView = [[JECameraSettingOptionsView alloc] initWithFrame:CGRectMake(_backView.frame.size.width, 0, _backView.frame.size.width, _backView.frame.size.height)];
                }
                else {
                    self.optionsView = [[JECameraSettingOptionsView alloc] initWithFrame:CGRectMake(0, - _backView.frame.size.height, _backView.frame.size.width, _backView.frame.size.height)];
                }
                _optionsView.headLabel.text = NSLocalizedString([_settingArray[indexPath.row] valueForKey:@"name"], nil);
                switch (indexPath.row) {
                    case 0: {
                        _optionsView.cellArray = self.auxiliaryLinesArray;
                        _optionsView.cameraSettingMode = auxiliaryLine;
                    }
                        break;
                        
                    case 1: {
                        _optionsView.cellArray = self.flashArray;
                        _optionsView.cameraSettingMode = flash;
                    }
                        break;
                        
                    case 2: {
                        NSLog(@"_videoResolutionArray1 = %@", _videoResolutionArray);
                        _optionsView.cellArray = self.videoResolutionArray;
                        _optionsView.cameraSettingMode = resolution;
                    }
                        break;
                        
                    default:
                        break;
                }
                _optionsView.delegate = self;
                [self addSubview:_optionsView];
                _optionsView.hidden = YES;
            }
            if (_optionsView.isHidden == YES) {
                if (_backView.frame.size.width > _backView.frame.size.height) {
                    _optionsView.frame = CGRectMake(_backView.frame.size.width, 0, _backView.frame.size.width, _backView.frame.size.height);
                }
                else {
                    _optionsView.frame = CGRectMake(0, - _backView.frame.size.height, _backView.frame.size.width, _backView.frame.size.height);
                }
                [_optionsView resetUISize:CGSizeMake(_backView.frame.size.width, _backView.frame.size.height)];
                _optionsView.headLabel.text = NSLocalizedString([_settingArray[indexPath.row] valueForKey:@"name"], nil);
                switch (indexPath.row) {
                    case 0: {
                        _optionsView.cellArray = self.auxiliaryLinesArray;
                        _optionsView.cameraSettingMode = auxiliaryLine;
                    }
                        break;
                        
                    case 1: {
                        _optionsView.cellArray = self.flashArray;
                        _optionsView.cameraSettingMode = flash;
                    }
                        break;
                        
                    case 2: {
                        _optionsView.cellArray = self.videoResolutionArray;
                        _optionsView.cameraSettingMode = resolution;
                    }
                        break;
                        
                    default:
                        break;
                }
                [_optionsView.tableView reloadData];
                _optionsView.hidden = NO;
                [UIView animateWithDuration:ANIMATE_TIME animations:^{
                    _optionsView.frame = CGRectMake(0, 0, _backView.frame.size.width, _backView.frame.size.height);
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATE_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self hiddenAllBase];
                });
            }
        }
            break;
            
        case deviceSetting: {
            switch (indexPath.row) {
                    
                case 2: {
                    //加速度校准
                    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceSettingMode:)]) {
                        [self.delegate deviceSettingMode:2];
                    }
                }
                    break;
                    
                case 3: {
                    //固件升级
                    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceSettingMode:)]) {
                        [self.delegate deviceSettingMode:3];
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - JECameraSettingOptionsViewDelegate
- (void)hideOptionsView {
    if (_optionsView) {
        [UIView animateWithDuration:ANIMATE_TIME animations:^{
            [self hiddenAllBase];
            if (_backView.frame.size.width > _backView.frame.size.height) {
                _optionsView.frame = CGRectMake(_backView.frame.size.width, 0, _backView.frame.size.width, _backView.frame.size.height);
            }
            else {
                _optionsView.frame = CGRectMake(0, - _backView.frame.size.height, _backView.frame.size.width, _backView.frame.size.height);
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATE_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _optionsView.hidden = YES;
        });
    }
}

- (void)setCameraFlashMode:(NSInteger)mode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraFlashMode:)]) {
        [self.delegate setCameraFlashMode:mode];
    }
}

- (void)setCameraAuxLineMode:(NSInteger)mode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraAuxLineMode:)]) {
        [self.delegate setCameraAuxLineMode:mode];
    }
}

- (void)setCameraVideoResolution:(NSInteger)mode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCameraVideoResMode:)]) {
        [self.delegate setCameraVideoResMode:mode];
    }
}

#pragma mark - JESettingPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _array.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (pickerView ==_hPushSpeedPicker) {
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _hPushSpeedPicker.frame.size.height, _hPushSpeedPicker.frame.size.height)];
        itemLabel.text = _array[row];
        itemLabel.textColor = [UIColor whiteColor];
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [itemLabel setTransform:transform];
        
        return itemLabel;
    }
    else {
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _fPushSpeedPicker.frame.size.height, _fPushSpeedPicker.frame.size.height)];
        itemLabel.backgroundColor = [UIColor clearColor];
        itemLabel.text = _array[row];
        itemLabel.textColor = [UIColor whiteColor];
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [itemLabel setTransform:transform];
        
        return itemLabel;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"pickerView选中的行数 = %ld", (long)row);
    /*
    if (pickerView == _hPushSpeedPicker) {
        USER_SET_SaveAxisPushSpeed_Interger(row);
    }
    else {
        USER_SET_SavePitchPushSpeed_Interger(row);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceSettingMode:)]) {
        [self.delegate deviceSettingMode:0];
    }
    NSLog(@"选中：%ld；%ld", USER_GET_SaveAxisPushSpeed_Interger, USER_GET_SavePitchPushSpeed_Interger);
     */
}

#pragma mark - Tools
//tableView 分割线左移15个像素
- (void)cellLineMoveLeft {
    
    //cell分割线向左移动15像素
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

//16进制字符串转10进制字符串
- (NSString *)numberHexString:(NSString *)aHexString
{
    //为空,直接返回.
    if (nil == aHexString)
    {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    
    unsigned long long longlongValue;
    
    [scanner scanHexLongLong:&longlongValue];
    
    NSString *str = [NSString stringWithFormat:@"%llu",longlongValue];
    
    return str;
}

@end
