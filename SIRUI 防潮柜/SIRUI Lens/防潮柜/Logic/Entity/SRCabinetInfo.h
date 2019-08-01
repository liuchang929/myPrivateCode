//
//  SRCabinetInfo.h
//  SR-Cabinet
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString * const kUserInfoChangeNotify;  //用户信息变更通知

@interface SRCabinetInfo : NSObject

#pragma mark －保存每一次点击所选择的设备id
@property (nonatomic, strong) NSString *deviceIMEI;//设备IMEI
@property (nonatomic, strong) NSString * humiditySetting;//设置的湿度
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *alarmId;
@property (nonatomic, strong) NSString *alarmType;
@property (nonatomic, strong) NSString *alarmTime;

@property (nonatomic, strong) NSNumber *notifyStatus; //通知状态

+ (SRCabinetInfo *)sharedInstance;




- (void)clearInfos;//清除本地数据
- (void)setDeviceIMEI:(NSString *)deviceIMEI;
- (void)setHumiditySetting:(NSString *)humiditySetting;
- (void)setDeviceName:(NSString *)deviceName;
- (void)setNotifyStatus:(NSNumber *)notifyStatus;

- (void)setAlarmId:(NSString *)alarmId;
- (void)setAlarmType:(NSString *)alarmType;
- (void)setAlarmTime:(NSString *)alarmTime;

//从本地加载数据
//- (void)loadInfo;
@end
