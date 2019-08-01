//
//  CustomTextField.h
//  SmartTripod
//
//  Created by sirui on 16/10/13.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTextField;

@protocol CustomTextFieldDelegate <NSObject>

//@optional
- (BOOL)customTextField:(CustomTextField *)textField isInputValid:(NSString *)text;//判断是否输入有效

@end

@interface CustomTextField : UIView

@property (nonatomic, assign) id<CustomTextFieldDelegate> validationDelegate;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *titleLb;
@property (nonatomic, strong) UILabel     *bottomLineLb;
@property (nonatomic, strong) NSString *presetText;//直接显示在输入框的text
@property (nonatomic, strong) NSString *placeholderText;


@property (nonatomic, assign) CGFloat textFieldRightMargin;


+ (CustomTextField *)getNewCustomTextField;
- (void)setBottomLine;

- (void)setBottomLineColor:(UIColor *)color;
- (void)setIconViewImage:(UIImage*)image;
- (void)setLeftTitle:(NSString*)str;
- (void)setSecurityInput:(BOOL)isSecurity;

- (NSString *)getText;

- (CGFloat)viewHeight;



@end
