//
//  UIColor+Custom.h
//  SmartTripod
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (Custom)


/**
 新颜色
 */
+ (UIColor *)getInchwormColor;



+ (UIColor *)colorFromRGB:(NSInteger)rgbValue;

+ (UIColor *)getBackgroundColor;

+ (UIColor *)getNavBlueColor;

+ (UIColor *)getBlueColor;

+ (UIColor *)getPurpleBlueColor;

+ (UIColor *)getLightBlueColor;

+ (UIColor *)getBlackColor;

+ (UIColor *)getWhiteColor;

+ (UIColor *)getGrayColor;

+ (UIColor *)getRedColor;

+ (UIColor *)getGreenColor;

+ (UIColor *)getSeparatorColor;

+ (UIColor *)getCellSelectedColor;

+ (UIColor *)getTableHeadColor;

+ (UIColor *)getLoginBackgroundColor;

+ (UIColor *)getImportantLabelColor;

+ (UIColor *)getNormalLabelColor;
@end
