//
//  CustomTextField.m
//  SmartTripod
//
//  Created by sirui on 16/10/13.
//  Copyright © 2016年 SIRUI. All rights reserved.
//
#import "CustomTextField.h"
#import "UIView+Sizes.h"
//#import "ViewUtils.h"
#import "Macros.h"

#define kCustomTextFieldFontSize 15
#define ktitleLbWeight    70
@interface CustomTextField ()
@property (nonatomic, strong) UIImageView *textFieldBgView;


@end

@implementation CustomTextField

+ (CustomTextField *)getNewCustomTextField {
    CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectZero];
    return textField;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _textFieldBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_textFieldBgView];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconView.hidden = YES;
    [self addSubview:_iconView];
    
    
    _titleLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLb.hidden = YES;
    [self addSubview:_titleLb];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.font = [UIFont systemFontOfSize:kCustomTextFieldFontSize];
    _textField.textColor = [UIColor blackColor];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.tintColor = kColorGray;
//    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textChangeAction:) forControlEvents:UIControlEventEditingChanged];
//    if (_presetText.length > 0) {
//        _textField.text = _presetText;
//    }
//    if (_placeholderText.length > 0) {
//        _textField.placeholder = _placeholderText;
//    }
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _textField.placeholder = @"Hello";
    _textField.backgroundColor = [UIColor clearColor];
    [self addSubview:_textField];
    
    
    
    _bottomLineLb = [[UILabel alloc]initWithFrame:CGRectZero];
    _bottomLineLb.backgroundColor = kColorBlue;
    [self addSubview:_bottomLineLb];
    _bottomLineLb.hidden = YES;
 }

- (void)layoutSubviews {
    [super layoutSubviews];
    //如果你发现，部分text显示不全，那么你不应该更改这里的sizeToFit， 而是在设置相应的text后，调用这个类的 setNeedDisplay
    self.textFieldBgView.frame = CGRectMake(0.f, 0.f, self.width, self.height);
    self.iconView.frame = (CGRect){0.f , 0.f , self.iconView.image.size.width,  self.iconView.image.size.height};
    
    self.titleLb.frame = (CGRect){0.f , 0.f , ktitleLbWeight,  self.height};
    CGFloat offsetX ;
   // CGFloat offsetX = self.iconView.hidden == self.titleLb.hidden ? 0.f : self.iconView.right;
    if (self.iconView.hidden==self.titleLb.hidden) {
        offsetX = 0.f;
    }else if (!self.iconView.hidden) {
        offsetX = self.iconView.image.size.width;
    }else{
        offsetX = self.titleLb.width;
    }
    
//    CGFloat offsetWidth;// = self.iconView.hidden == self.titleLb.hidden ? 0 : (self.iconView.image.size.width );
//    if (self.iconView.hidden==self.titleLb.hidden) {
//        offsetWidth = 0.f;
//    }else if (!self.iconView.hidden) {
//        offsetWidth = self.iconView.image.size.width;
//    }else{
//        offsetWidth = self.titleLb.width;
//    }
//    
//    if (self.precedingLabel) {
//        self.precedingLabel.frame = CGRectMake(offsetX, 14.f, 70.f, 20.f);
//        self.textField.frame = CGRectMake(92.f, 5.f, self.width - 108.f - self.textFieldRightMargin - offsetWidth, 38.f);
//    }
//    else {
    
        self.textField.frame = CGRectMake(offsetX, 2.f, self.width - offsetX - self.textFieldRightMargin, self.height-4.f);
//    }
    self.bottomLineLb.frame = CGRectMake(offsetX, self.height-2.f, self.width, 2.f);

}

//- (void)setPrecedingText:(NSString *)precedingText {
//    _precedingText = precedingText;
////    if (_precedingText.length > 0) {
////        [self addPrecedingLabel];
////        self.precedingLabel.text = _precedingText;
////    }
////    else {
////        [self removePrecedingLabel];
////    }
//}

//- (void)addPrecedingLabel {
//    if (nil != self.precedingLabel) {
//        return;
//    }
//    self.precedingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    self.precedingLabel.textColor = [UIColor blackColor];
//    self.precedingLabel.font = [UIFont systemFontOfSize:kCustomTextFieldFontSize];
//    [self addSubview:self.precedingLabel];
//}

//- (void)removePrecedingLabel {
//    if (self.precedingLabel) {
//        [self.precedingLabel removeFromSuperview];
//        self.precedingLabel = nil;
//    }
//}
- (void)setBottomLine{
    _bottomLineLb.hidden = NO;
}

- (void)setBottomLineColor:(UIColor *)color;{
    _bottomLineLb.hidden = NO;
    _bottomLineLb.backgroundColor = color;
    
}

- (void)setIconViewImage:(UIImage*)image
{
    _iconView.hidden = NO;
    _iconView.image = image;
    _titleLb.hidden=YES;
    [self setNeedsLayout];
}

- (void)setLeftTitle:(NSString*)str
{
    
    _titleLb.hidden=NO;
    _titleLb.text=str;
    _iconView.hidden=YES;
     [self setNeedsLayout];
}

- (void)setPresetText:(NSString *)presetText {
    _presetText = presetText;
    self.textField.text = _presetText;
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;
//    self.textField.placeholder = placeholderText;
    UIColor *color = [UIColor colorFromRGB:0xC0C0C0];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName : color}];
}

//- (void)setTipText:(NSString *)tipText {
//    _tipText = tipText;
//    self.tipLabel.text = _tipText;
//    self.tipLabel.hidden = NO;
//}

//- (void)setErrorTipText:(NSString *)errorTipText {
//    _errorTipText = errorTipText;
//    if (errorTipText == nil || [errorTipText isEqualToString:@""]) {
//        self.tipLabel.hidden = YES;
//    }
//    else{
//        self.tipLabel.hidden = NO;
//    }
//}

- (void)setSecurityInput:(BOOL)isSecure {
    self.textField.secureTextEntry = isSecure;
    //清除密码明文切换时留有的空格
    if ([self.textField isFirstResponder]) {
        [self.textField becomeFirstResponder];
    }
}

- (NSString *)getText {
    return self.textField.text;
}

- (CGFloat)viewHeight {
//    if (self.tipText.length + self.errorTipText.length > 0) {
//        return 48.f + 30.f;
//    }
    return 48.f;
}
-(void)textChangeAction:(id)sender{
    
        NSString *text = [(UITextField *)sender text];
       if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(customTextField:isInputValid:)]) {
            BOOL valid = [self.validationDelegate customTextField:self isInputValid:text];
          // NSLog(@"%d",valid);
       }
    
}
//- (void)textChangeAction:(NSString *)text {
//- (void)textChangeAction:(id)sender {
//    NSString *text = [(UITextField *)sender text];
//   if (self.validationDelegate && [self.validationDelegate respondsToSelector:@selector(customTextField:isInputValid:)]) {
//        BOOL valid = [self.validationDelegate customTextField:self isInputValid:text];
////        if (valid) {
////            self.tipLabel.text = self.tipText;
////            self.tipLabel.textColor = kColorGray;
////        }
////        else {
////            if (self.errorTipText.length) {
////                self.tipLabel.text = self.errorTipText;
////                self.tipLabel.textColor = kColorRed;
////            }
////        }
////        [self.tipLabel setNeedsDisplay];
//   }
//}

//- (void)setUpperSeparatorHidden:(BOOL)hidden {
//    self.topSeparator.hidden = hidden;
//}
//
//- (void)setBottomSeparatorHidden:(BOOL)hidden {
//    self.bottomSeparator.hidden = hidden;
//}
//
//- (void)setTipLabelBgColor:(UIColor *)color
//{
//    _tipLabel.backgroundColor = color;
//}

@end
