//
//  SRTimeInfo.m
//  SR-Cabinet
//
//  Created by sirui on 2017/4/6.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "SRTimeInfo.h"
#import "SynthesizeSingleton.h"
@implementation SRTimeInfo
SYNTHESIZE_SINGLETON_ARC(SRTimeInfo);
-(void)clearAllInfo{
    _startTimeStr = nil;
    _endTimeStr = nil;
    _recordtotal = nil;
    
    
    
}

- (void)setStartTimeStr:(NSString *)startTimeStr{
    
    _startTimeStr = startTimeStr;
}

- (void)setEndTimeStr:(NSString *)endTimeStr{
    
    _endTimeStr = endTimeStr;
}


- (void)setRecordtotal:(NSNumber *)recordtotal{
    
    _recordtotal = recordtotal;
}



/*
 @property (nonatomic, strong) NSString *startTimeIntervalStr;
 @property (nonatomic, strong) NSString *endTimeIntervalStr;
 */
- (void)setStartTimeIntervalStr:(NSString *)startTimeIntervalStr{
    
    _startTimeIntervalStr = startTimeIntervalStr;
}

- (void)setEndTimeIntervalStr:(NSString *)endTimeIntervalStr{
    
    _endTimeIntervalStr = endTimeIntervalStr;
}



@end
