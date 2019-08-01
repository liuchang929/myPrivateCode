//
//  SRCabinetInfo.m
//  SR-Cabinet
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "SRCabinetInfo.h"
#import "SynthesizeSingleton.h"

#import "CommonUtils.h"



//NSString * const kUserInfoChangeNotify = @"UserInfoChanged";
NSString * const kLoginKeyDeviceIMEI = @"device_IMEI";
NSString * const kLoginHumiditySetting = @"device_humiditySetting";
NSString * const kLoginKeyDeviceName = @"login_deviceName";   //用户昵称
NSString * const kLoginKeyNotifyStatus = @"login_notifyStatus";


NSString * const kAlarmId = @"alarm_id";

NSString * const kAlarmType = @"alarm_type";

NSString * const kAlarmTime = @"alarm_time";
/*
 
 @property (nonatomic, strong) NSString *alarmId;
 @property (nonatomic, strong) NSString *alarmType;
 */
@interface SRCabinetInfo ()


@property (nonatomic, strong) NSMutableDictionary *changedDictionary;


@end

@implementation SRCabinetInfo
//@synthesize nickName = _nickName;
SYNTHESIZE_SINGLETON_ARC(SRCabinetInfo);

- (instancetype)init {
    self = [super init];
    if (self) {
        //[self loadInfo];
      
    
    
    }
    return self;
}












#pragma mark - Setters
//这个方法不是你直接调用的，只是用了作为内部方法写在其他方法里面调用的方法
- (void)saveString:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
      [[NSUserDefaults standardUserDefaults] synchronize];
    if (value.length > 0) {
        [userDefaults setObject:value forKey:key];
    }
    else {
        [userDefaults removeObjectForKey:key];
    }
}






//重写set方法，直接封装好了对属性的用户默认保存
-(void)setDeviceIMEI:(NSString *)deviceIMEI{
    _deviceIMEI = deviceIMEI;
    
    [self saveString:self.deviceIMEI forKey:kLoginKeyDeviceIMEI];

}



-(void)setHumiditySetting:(NSString *)humiditySetting{
    _humiditySetting = humiditySetting;
    
    [self saveString:self.deviceIMEI forKey:kLoginHumiditySetting];

}












- (void)setDeviceName:(NSString *)deviceName{
    _deviceName = deviceName;
    
    //本地化保存
    [self saveString:self.deviceName forKey:kLoginKeyDeviceName];
    
    //[self save];
   // [self sendNotify];
    
}



- (void)setNotifyStatus:(NSNumber *)notifyStatus{
    
    _notifyStatus = notifyStatus;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//        [userDefaults setObject:self.notifyStatus forKey:kLoginKeyNotifyStatus];
    
    
    
}


- (void)setAlarmId:(NSString *)alarmId{
    
    _alarmId = alarmId;
}
- (void)setAlarmType:(NSString *)alarmType{
    _alarmType = alarmType;
    
    
}


- (void)setAlarmTime:(NSString *)alarmTime{
    
    _alarmTime = alarmTime;
    
}


#pragma mark - Notify
//- (void)sendNotify {
//    //发送用户信息改变的消息，使得在某一文件中增加一个观察者来获得这个消息里面的内容
//    [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangeNotify object:nil];
//}

//本地加载数据信息，使用用户默认保存
//- (void)loadInfo {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    
//    _deviceIMEI  = [userDefaults objectForKey:kLoginKeyDeviceIMEI];
//    
//    _nickName = [userDefaults objectForKey:kLoginKeyNickName];
//    _notifyStatus = [userDefaults objectForKey:kLoginKeyNotifyStatus];
//}

- (void)clearInfos {
    
    _deviceIMEI = nil;
    
    _humiditySetting = nil;
    
    _deviceName = nil;
    
    _notifyStatus = nil;
    
    
}

@end
