//
//  UIColor+Custom.m
//  SmartTripod
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//
#import "UIColor+Custom.h"

@implementation UIColor (Custom)

+ (UIColor *)colorFromRGB:(NSInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.f
                           green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.f
                            blue:((float)(rgbValue & 0x0000FF)) / 255.f alpha:1.f];
}


+ (UIColor *)getInchwormColor{
    return [UIColor colorFromRGB:0xB2EC5D];
    
}


+ (UIColor *)getBackgroundColor {
    return [UIColor colorFromRGB:0xF4F4F4];
}

+ (UIColor *)getNavBlueColor {
    return [UIColor colorFromRGB:0x0099FF];
}

+ (UIColor *)getNormalLabelColor {
    return [UIColor colorFromRGB:0x707070];
}

+ (UIColor *)getImportantLabelColor {
    return [UIColor colorFromRGB:0x131313];
}

+ (UIColor *)getBlueColor {
    return [UIColor colorFromRGB:0xBBFFFF];
}


+ (UIColor *)getPurpleBlueColor {
    return [UIColor colorFromRGB:0x97FFFF];
}


+ (UIColor *)getLightBlueColor {
    return [UIColor colorFromRGB:0x3fb6ff];
}

+ (UIColor *)getBlackColor {
    return [UIColor blackColor];
}

+ (UIColor *)getWhiteColor {
    return [UIColor whiteColor];
}

+ (UIColor *)getGrayColor {
    return [UIColor colorFromRGB:0xCCCCCC];
}

+ (UIColor *)getRedColor {
    return [UIColor colorFromRGB:0xee2737];
}

+ (UIColor *)getGreenColor {
    return [UIColor greenColor];
}

+ (UIColor *)getSeparatorColor {
    return [UIColor colorFromRGB:0xE8E8E8];

}

+ (UIColor *)getCellSelectedColor {
    return [UIColor colorFromRGB:0xebebeb];
}

+ (UIColor *)getTableHeadColor {
    return [UIColor colorFromRGB:0xf7f7f7];
}

+ (UIColor *)getLoginBackgroundColor {
    return [self getWhiteColor];
}

@end
