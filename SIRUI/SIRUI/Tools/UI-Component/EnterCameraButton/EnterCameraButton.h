//
//  EnterCameraButton.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/3/14.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EnterCameraButton;

@protocol EnterCameraButtonDelegate <NSObject>

@required

- (void)finishedEventByEnterCameraButton:(EnterCameraButton *)button;

@end

@interface EnterCameraButton : UIView

@property (nonatomic, weak)   id<EnterCameraButtonDelegate>  delegate;

@property (nonatomic, strong) UIFont   *font;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UIColor  *normalTextColor;
@property (nonatomic, strong) UIColor  *highlightTextColor;
@property (nonatomic, strong) UIColor  *animationColor;

/**
 *  Animation's width.
 */
@property (nonatomic)         CGFloat   animationWidth;

/**
 *  动画结束 + 恢复正常的时间
 */
@property (nonatomic)         CGFloat toEndDuration;
@property (nonatomic)         CGFloat toNormalDuration;

@end

NS_ASSUME_NONNULL_END
