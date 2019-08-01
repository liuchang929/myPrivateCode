//
//  SRTimeInfo.h
//  SR-Cabinet
//
//  Created by sirui on 2017/4/6.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRTimeInfo : NSObject
@property (nonatomic, strong) NSString *startTimeStr;
@property (nonatomic, strong) NSString *endTimeStr;
@property (nonatomic, strong) NSNumber *recordtotal;
@property (nonatomic, strong) NSString *startTimeIntervalStr;
@property (nonatomic, strong) NSString *endTimeIntervalStr;



+ (SRTimeInfo *)sharedInstance;
-(void)clearAllInfo;
@end
