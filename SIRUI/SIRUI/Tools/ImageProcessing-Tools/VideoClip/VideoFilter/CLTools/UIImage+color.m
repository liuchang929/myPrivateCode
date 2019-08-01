//
//  UIImage+color.m
//  VideoProcessing
//
//  Created by ClaudeLi on 16/4/25.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "UIImage+color.h"

@implementation UIImage (color)

// 颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
