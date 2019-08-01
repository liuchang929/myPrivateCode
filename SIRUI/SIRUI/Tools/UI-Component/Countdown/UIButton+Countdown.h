//
//  UIButton+Countdown.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/11.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Countdown)

//倒计时
- (void)startWithTime:(NSInteger)timeLine mainColor:(UIColor *)mColor countColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
