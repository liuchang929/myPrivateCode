//
//  BGUnlockController.h
//  BGUnlockControllerDemo
//
//  Created by user on 15/11/25.
//  Copyright © 2015年 BG. All rights reserved.
//
#import "BaseViewController.h"


@class PasswordUnlockViewController;

@protocol BGUnlockControllerDelegate <NSObject>
@required

/**
 *  解锁成功
 *
 *  @param controller 解锁控制器
 *  @param unlockType 解锁类型
 */
- (void)unlockSuccessController:(PasswordUnlockViewController *)controller;
/**
 *  解锁失败
 *
 *  @param controller 解锁失败
 */
- (void)unlockFailureWithUnlockController:(PasswordUnlockViewController *)controller;

@end

@interface PasswordUnlockViewController : BaseViewController


/**
 *  数字解锁码
 */
@property (nonatomic, strong) NSString *passcode;

/**
 *  数字解锁的次数，默认3次，如果达到上限，则说明解锁失败，锁定用户
 */
//@property (nonatomic, assign) NSInteger passcodeUnlockCount;


@property (nonatomic, weak) id<BGUnlockControllerDelegate> delegate;

@end
