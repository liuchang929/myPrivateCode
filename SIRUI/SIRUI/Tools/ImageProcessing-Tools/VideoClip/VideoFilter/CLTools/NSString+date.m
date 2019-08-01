//
//  NSString+date.m
//  VideoProcessing
//
//  Created by ClaudeLi on 16/4/25.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "NSString+date.h"

@implementation NSString (date)

+ (NSString *)vidoTempPath
{
    NSDate *date = [NSDate date];
    
    NSString *string = [NSString stringWithFormat:@"%ld.mov",(unsigned long)(date.timeIntervalSince1970 * 1000)];
    
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:string];
    
    return cachePath;
}


@end
