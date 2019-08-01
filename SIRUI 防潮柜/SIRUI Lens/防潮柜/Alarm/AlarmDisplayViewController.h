//
//  AlarmDisplayViewController.h
//  SmartTripod
//
//  Created by sirui on 16/11/15.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "BaseViewController.h"
//typedef void(^DismissAlarmViewBlock)();
#import "CWStatusBarNotification.h"
@interface AlarmDisplayViewController : BaseViewController
//@property (nonatomic, copy) DismissAlarmViewBlock dismissAlarmViewBlock;
+(void)showAlarmDisplayView;
@property (strong, nonatomic) CWStatusBarNotification *notification;
@end
