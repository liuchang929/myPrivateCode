//
//  JEGetDeviceVersion.m
//  JEPro
//
//  Created by fangxue on 2018/9/14.
//  Copyright © 2018年 Jenny. All rights reserved.
//

#import "JEGetDeviceVersion.h"
#import "sys/utsname.h"

@implementation JEGetDeviceVersion

//获取设备版本
+ (DeviceType)deviceVersion {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])        return iPhone_1G;
    if ([deviceString isEqualToString:@"iPhone1,2"])        return iPhone_3G;
    if ([deviceString isEqualToString:@"iPhone2,1"])        return iPhone_3GS;
    if ([deviceString isEqualToString:@"iPhone3,1"]
        || [deviceString isEqualToString:@"iPhone3,2"]
        || [deviceString isEqualToString:@"iPhone3,3"])     return iPhone_4;
    if ([deviceString isEqualToString:@"iPhone4,1"])        return iPhone_4S;
    if ([deviceString isEqualToString:@"iPhone5,1"]
        || [deviceString isEqualToString:@"iPhone5,2"])     return iPhone_5;
    if ([deviceString isEqualToString:@"iPhone5,3"]
        || [deviceString isEqualToString:@"iPhone5,4"])     return iPhone_5C;
    if ([deviceString isEqualToString:@"iPhone6,1"]
        || [deviceString isEqualToString:@"iPhone6,2"])     return iPhone_5S;
    if ([deviceString isEqualToString:@"iPhone7,1"])        return iPhone_6Plus;
    if ([deviceString isEqualToString:@"iPhone7,2"])        return iPhone_6;
    if ([deviceString isEqualToString:@"iPhone8,1"])        return iPhone_6S;
    if ([deviceString isEqualToString:@"iPhone8,2"])        return iPhone_6S_Plus;
    if ([deviceString isEqualToString:@"iPhone8,4"])        return iPhone_SE;
    if ([deviceString isEqualToString:@"iPhone9,1"]
        || [deviceString isEqualToString:@"iPhone9,3"])     return iPhone_7;
    if ([deviceString isEqualToString:@"iPhone9,2"]
        || [deviceString isEqualToString:@"iPhone9,4"])     return iPhone_7Plus;
    if ([deviceString isEqualToString:@"iPhone10,1"]
        || [deviceString isEqualToString:@"iPhone10,4"])    return iPhone_8;
    if ([deviceString isEqualToString:@"iPhone10,2"]
        || [deviceString isEqualToString:@"iPhone10,5"])    return iPhone_8Plus;
    if ([deviceString isEqualToString:@"iPhone10,3"]
        || [deviceString isEqualToString:@"iPhone10,6"])    return iPhone_X;
    if ([deviceString isEqualToString:@"iPhone11,8"])       return iPhone_XR;
    if ([deviceString isEqualToString:@"iPhone11,2"])       return iPhone_XS;
    if ([deviceString isEqualToString:@"iPhone11,6"])       return iPhone_XS_MAX;
    
    return unknown;
}

@end
