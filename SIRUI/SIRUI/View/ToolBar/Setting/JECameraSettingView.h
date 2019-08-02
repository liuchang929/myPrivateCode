//
//  JECameraSettingView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JECameraSettingTableView.h"
#import "JECameraSettingOptionsView.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum settingMode {
    cameraSetting,
    deviceSetting
}SettingMode;

@protocol JECameraSettingDelegate <NSObject>

- (void)tableViewPushVC:(UIViewController *)pushVC;
- (void)deviceSettingMode:(NSInteger)mode;
- (void)setCameraFlashMode:(NSInteger)mode;
- (void)setCameraAuxLineMode:(NSInteger)mode;
- (void)setCameraVideoResMode:(NSInteger)mode;
- (void)deviceUpdateAction;
- (void)appUpdateAction;
- (void)filmCameraAction:(BOOL)on;

@end

@interface JECameraSettingView : UIView

@property (nonatomic, weak) id<JECameraSettingDelegate> delegate;

@property (nonatomic, assign) SettingMode settingMode;      //设置模式
@property (nonatomic, strong) NSArray *settingArray;        //设置列表内的数据
@property (nonatomic, strong) JECameraSettingTableView  *tableView;     //设置列表
@property (nonatomic, strong) JECameraSettingOptionsView *optionsView;  //选项 view
@property (nonatomic, strong) UIPickerView              *hPushSpeedPicker;  //航向轴
@property (nonatomic, strong) UIPickerView              *fPushSpeedPicker;  //俯仰轴
@property (nonatomic, strong) NSArray *videoResolutionArray;    //视频分辨率
@property (nonatomic, strong) UIButton *updateVersionButton;    //更新版本按钮
@property (nonatomic, strong) UIButton *appVersionButton;       //app 版本按钮

- (void)resetUISize:(CGSize)size;
- (void)cleanCameraSettingOption;
- (void)setUpdateButtonHidden:(BOOL)hide;

@end

NS_ASSUME_NONNULL_END
