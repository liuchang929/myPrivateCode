//
//  JESearchDevicesView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/2/22.
//  Copyright © 2019年 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol JESearchDevicesViewDelegate <NSObject>

- (void)searchDeviceSelect:(CBPeripheral *)per;

@end

@interface JESearchDevicesView : UIView

@property (nonatomic, weak) id<JESearchDevicesViewDelegate> delegate;

@property (nonatomic, strong) UITableView   *deviceTableView;   //搜索设备的列表
@property (nonatomic, strong) NSArray       *deviceArray;       //搜索到的设备数据

@end

NS_ASSUME_NONNULL_END
