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
+(NSString *) deviceVersion {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])        return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])        return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])        return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]
        || [deviceString isEqualToString:@"iPhone3,2"]
        || [deviceString isEqualToString:@"iPhone3,3"])     return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])        return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"]
        || [deviceString isEqualToString:@"iPhone5,2"])     return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"]
        || [deviceString isEqualToString:@"iPhone5,4"])     return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"]
        || [deviceString isEqualToString:@"iPhone6,2"])     return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])        return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])        return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])        return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])        return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])        return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"]
        || [deviceString isEqualToString:@"iPhone9,3"])     return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"]
        || [deviceString isEqualToString:@"iPhone9,4"])     return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"]
        || [deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"]
        || [deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"]
        || [deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])       return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])       return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])       return @"iPhone XS Max";
    
    return deviceString;
}

@end
