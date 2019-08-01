//
//  RecordQueryViewController.h
//  SR-Cabinet
//
//  Created by sirui on 2017/3/13.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSInteger {
    kAlarmRecordQuery,
    kOpenRecordQuery,
    kCloseRecordQuery,
} RecordQueryStyle;

@interface RecordQueryViewController : BaseViewController
- (instancetype)initWithRecordQueryStyle:(RecordQueryStyle)style;
@property (nonatomic,assign)RecordQueryStyle style;


@end
