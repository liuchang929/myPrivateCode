//
//  LabeledActivityIndicatorView.h
//  Activityindicatorview
//
//  Created by Camoufleur on 08/02/2017.
//  Copyright © 2017 Camoufleur. All rights reserved.
//
//  主要针对有需要在NavigationItem上和UIButton上添加小菊花来表示某些状态的情况

#import <UIKit/UIKit.h>

@interface LabeledActivityIndicatorView : UIView

/**
 指定activityIndicatorView的style的初始化方式，也可直接[LabeledActivityIndicatorView new]创建

 @param style 只有 UIActivityIndicatorViewStyleWhite 或者
              UIActivityIndicatorViewStyleGray 可选，默认为UIActivityIndicatorViewStyleGray
 */
- (instancetype)initWithActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)style;

/**
 设置小菊花后边的文字

 @param description 需要显示的文字
 @param font 字体大小样式（为nil时默认为第一次设置的大小，未设置过则为默认的17号字体）
 @param color 字体颜色（为nil时默认为第一次设置的颜色，未设置过则为黑色）
 */
- (void)setDescription:(NSString *)description font:(UIFont *)font color:(UIColor *)color;

/**
 开始旋转
 */
- (void)startRotation;

/**
 停止旋转并隐藏小菊花
 */
- (void)stopRotation;

/**
 停止旋转，隐藏小菊花并显示完成图标“success.png”
 */
- (void)stopRotationWithDone;

/**
 将该view移除，如果父视图为button，则自动恢复button的原title
 */
- (void)stopRotationWithFaild;

@end
