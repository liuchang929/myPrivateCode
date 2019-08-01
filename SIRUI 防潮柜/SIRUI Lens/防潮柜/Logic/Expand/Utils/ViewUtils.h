//
//  ViewUtils.h
//  SmartTripod
//
//  Created by sirui on 16/10/19.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ViewUtils : NSObject//视图工具，快速的返回一个视图对象

+ (ViewUtils *)sharedInstance;


#define kViewSeparatorHeight (1.f / [UIScreen mainScreen].scale)
// separator used within view, NOT in tab/bar etc
+ (UIImageView *)getGraySeparator;
// separator used in Tab/NavBar etc
+ (UIImageView *)getTabGraySeparator;

#define kViewCoinViewHeight 12.f

#define kViewPlayViewHeight 12.f
+ (UIImageView *)getPlayView;

// set the bg image btn_white/btn_white_hl for UIButton's backgroundImage
+ (void)setButtonWithWhiteBGImage:(UIButton *)button;

//返回一个屏幕宽度view，高度和颜色由参数指定
+ (UIView *)getView:(NSUInteger)aHeight color:(UIColor *)aColor;
+ (UIImageView *)lineForWidth:(NSUInteger)aWidth;

+ (UIView *)getCellSelectedView:(CGRect)aRect;

+ (UIImage *)navigationBackground;

+ (NSUInteger )statusBarHeight;

+ (UIButton *)getButton;

// a button with bg image btn_blue
+ (UIButton *)getBlueBGButton;

+ (CAAnimation *)collectScaleAnimation;
+ (CAAnimation *)scaleAnimation;

#pragma mark Custom Views
#define kViewUtilRoleViewLabelTag 10053
 //type: 1, for teacher; 2, for subject representive,
// other will return nil
+ (UIView *)roleViewWithType:(NSInteger)type;
+ (UIView *)roleViewWithType:(NSInteger)type fontSize:(NSInteger)size;
+ (UIView *)representativeRoleViewWithText:(NSString *)text;

+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label;

+ (UIImage *)placeHolderImageForURL:(NSString *)url sex:(NSNumber *)sex;

@end
