//
//  JEGetDeviceVersion.h
//  JEPro
//
//  Created by fangxue on 2018/9/14.
//  Copyright © 2018年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum deviceType {
    unknown = 0,
    iPhone_1G,
    iPhone_3G,
    iPhone_3GS,
    iPhone_4,
    iPhone_4S,
    iPhone_5,
    iPhone_5C,
    iPhone_5S,
    iPhone_6Plus,
    iPhone_6,
    iPhone_6S,
    iPhone_6S_Plus,
    iPhone_SE,
    iPhone_7,
    iPhone_7Plus,
    iPhone_8,
    iPhone_8Plus,
    iPhone_X,
    iPhone_XR,
    iPhone_XS,
    iPhone_XS_MAX
}DeviceType;

@interface JEGetDeviceVersion : NSObject

@property (nonatomic, assign) DeviceType devicetype;

+ (DeviceType)deviceVersion;

@end
