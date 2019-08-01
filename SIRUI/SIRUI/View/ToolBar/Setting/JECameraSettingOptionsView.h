//
//  JECameraSettingOptionsView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//设置模式
typedef enum cameraSettingMode {
    cameraSettingModeUnknown = 0,
    auxiliaryLine,
    flash,
    resolution
}CameraSettingMode;

@protocol JECameraSettingOptionsViewDelegate <NSObject>

- (void)hideOptionsView;
- (void)setCameraFlashMode:(NSInteger)mode;
- (void)setCameraAuxLineMode:(NSInteger)mode;
- (void)setCameraVideoResolution:(NSInteger)mode;

@end

@interface JECameraSettingOptionsView : UIView

@property (nonatomic, weak) id<JECameraSettingOptionsViewDelegate> delegate;

@property (nonatomic, strong) UILabel       *headLabel;     //顶部 Label
@property (nonatomic, strong) UITableView   *tableView;     //设置列表

@property (nonatomic, assign) CameraSettingMode cameraSettingMode;  //设置模式
@property (nonatomic, strong) NSArray       *cellArray;    //选项

- (void)resetUISize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
