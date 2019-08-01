//
//  ViewUtils.m
//  SmartTripod
//
//  Created by sirui on 16/10/19.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "ViewUtils.h"
#import "SynthesizeSingleton.h"
#import <CoreText/CoreText.h>
#import "Macros.h"

@interface ViewUtils ()

@property (nonatomic, strong) UIImage *separatorImage;

@end

@implementation ViewUtils

SYNTHESIZE_SINGLETON_ARC(ViewUtils);

- (UIImage *)separatorImage {
    if (nil == _separatorImage) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat width = 3.f * scale;
        CGFloat height = 1.f * scale;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.f);
        CGContextSetStrokeColorWithColor(context, kColorGray.CGColor);
        CGContextMoveToPoint(context, 0.f, height / 2.f);
        CGContextAddLineToPoint(context, width, height / 2.f);
        CGContextStrokePath(context);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
//        image.scale = scale;
        NSData *data = UIImagePNGRepresentation(image);
        _separatorImage = [[UIImage alloc] initWithData:data scale:scale];
        _separatorImage = [_separatorImage stretchableImageWithLeftCapWidth:2.f topCapHeight:0.f];
    }
    return _separatorImage;
}

+ (UILabel *)getBlackBigLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForCellTitle;
    label.textColor = kColorBlack;
    return label;
}

+ (UILabel *)getBlackLabel17 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:17.f];
    label.textColor = kColorBlack;
    return label;
}

+ (UILabel *)getBlackMiddleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForInput;
    label.textColor = kColorBlack;
    return label;
}

+ (UILabel *)getBlackLabel14 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textColor = kColorBlack;
    return label;
}

+ (UILabel *)getGrayMiddleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForInput;
    label.textColor = kColorGray;
    return label;
}

+ (UILabel *)getGraySmallLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForTip;
    label.textColor = kColorGray;
    return label;
}

+ (UILabel *)getWhiteSmallLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForSmall;
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getWhiteLabel13 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForSmall;
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getWhiteLabel12 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:12.f];
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getWhiteLabel14 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getWhiteLabel18 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:18.f];
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getWhiteLabel17 {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:17.f];
    label.textColor = kColorWhite;
    return label;
}

+ (UILabel *)getBlueBigLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForBig;
    label.textColor = kColorBlue;
    return label;
}

+ (UILabel *)getBlueMiddleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForInput;
    label.textColor = kColorBlue;
    return label;
}

+ (UILabel *)getBlueSmallLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontForTip;
    label.textColor = kColorBlue;
    return label;
}

+ (UILabel *)getStudyCountLabel33
{
    return [self getStudyCountLabelWithFontSize:33.f color:[UIColor colorFromRGB:0x526373]];
}

+ (UILabel *)getStudyCountLabel22
{
    return [self getStudyCountLabelWithFontSize:22.f color:[UIColor blackColor]];
}

+ (UILabel *)getStudyCountLabelWithFontSize:(CGFloat)fontSize color:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.2f) {
        label.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
    }
    else {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UILabel *)getStudyBriefTipLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11.f];
    label.textColor = [UIColor colorFromRGB:0x999999];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UILabel *)getStudyTipLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.f];
    label.textColor = [UIColor colorFromRGB:0x999999];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UIImageView *)getTabGraySeparator
{
    return [self getSeparatorWithColor:[UIColor colorFromRGB:0xDFDFDF]];
}

+ (UIImageView *)getGraySeparator
{
    return [self getSeparatorWithColor:[UIColor colorFromRGB:0xE8E8E8]];
}

+ (UIImageView *)getSeparatorWithColor:(UIColor *)color
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.backgroundColor = color;
    return imageView;
}


+ (UIImageView *)getPlayView {
    UIImageView *playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playview"]];
    return playView;
    
}

+ (void)setButtonWithWhiteBGImage:(UIButton *)button {
    UIImage *image = [UIImage imageNamed:@"buttonbar_action"];
    image = [image stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"buttonbar_action"];
    image = [image stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setBackgroundImage:image forState:UIControlStateSelected];
}

+ (UIView *)getView:(NSUInteger)aHeight color:(UIColor *)aColor
{
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, aHeight)];
    v.backgroundColor = aColor;
    return v;
}

+ (UIImageView *)lineForWidth:(NSUInteger)aWidth
{
    UIImageView *s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    s.frame = CGRectMake(0, 0, aWidth, s.frame.size.height);
    return s;
}

+ (UIView *)getCellSelectedView:(CGRect)aRect
{
    UIImageView *v = [[UIImageView alloc] initWithFrame:aRect];
    v.backgroundColor = kColorCellSelected;
    return v;
}

+ (UIImage *)navigationBackground
{
    UIImage *navbg = [UIImage imageNamed:@"btn_blue"];
    navbg = [navbg stretchableImageWithLeftCapWidth:4.f topCapHeight:3.f];
    return navbg;
}


+ (NSUInteger)statusBarHeight
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (UIButton *)getButton
{
    UIImage *image = [UIImage imageNamed:@"btn_white"];
    image = [image stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    UIImage *imagePress = [UIImage imageNamed:@"btn_white_hl"];
    imagePress = [imagePress stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    return btn;
}

+ (UIButton *)getBlueBGButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:kColorBlack forState:UIControlStateNormal];
    [btn setTitleColor:kColorBlack forState:UIControlStateHighlighted];
    [btn setTitleColor:kColorBlack forState:UIControlStateDisabled];
    
    // set the login button's background image
    UIImage *image = [UIImage imageNamed:@"buttonbar_action"];
    image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:5];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    image = [UIImage imageNamed:@"buttonbar_edit"];
    image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:5];
    [btn setBackgroundImage:image forState:UIControlStateHighlighted];
    return btn;
}

+ (CAAnimation *)collectScaleAnimation
{
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.duration = 0.4f;
    k.values = @[@(1.f), @(1.6f), @(0.75f), @(1)];
    k.keyTimes = @[@(0.0f), @(0.4f), @(0.8f), @(1.0f)];
    k.calculationMode = kCAAnimationLinear;
    return k;
}

+ (CAAnimation *)scaleAnimation
{
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.duration = 0.4f;
    k.values = @[@(1.f), @(2.f), @(0.75f), @(1)];
    k.keyTimes = @[@(0.0f), @(0.4f), @(0.8f), @(1.0f)];
    k.calculationMode = kCAAnimationLinear;
    return k;
}

#pragma mark Custom Views
// type: 1, for teacher; 2, for subject representive,
// other will return nil
+ (UIView *)roleViewWithType:(NSInteger)type {
    return [self roleViewWithType:type fontSize:8];
}

+ (UIView *)roleViewWithType:(NSInteger)type fontSize:(NSInteger)size {
    return [self roleViewWithText:nil type:type fontSize:size];
}

+ (UIView *)representativeRoleViewWithText:(NSString *)text
{
    return [self roleViewWithText:text type:2 fontSize:8.f];
}

+ (UIView *)roleViewWithText:(NSString *)text type:(NSInteger)type fontSize:(NSInteger)size {
    if (1 != type && 2 != type) {
        return nil;
    }
    
    UIImageView *view = [[UIImageView alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    if (text) {
        label.text = text;
        if (8 == size) {
            view.frame = CGRectMake(0.f, 0.f, 8.f * text.length + 7.f, 12.f);
        }
        UIImage *image = [UIImage imageNamed:@"label_chatroom_classrepresentative"];
        image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        view.image = image;
    }
    else if (1 == type) {
        label.text = @"老师";
        view.frame = CGRectMake(0.f, 0.f, 21.f, 12.f);
        UIImage *image = [UIImage imageNamed:@"label_chatroom_teacher"];
        image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        view.image = image;
    }
    else {
        label.text = @"课代表";
        if (8 == size) {
            view.frame = CGRectMake(0.f, 0.f, 31.f, 12.f);
        }
        else if (10 == size) {
            view.frame = CGRectMake(0.f, 0.f, 35.f, 14.f);
        }
        UIImage *image = [UIImage imageNamed:@"label_chatroom_classrepresentative"];
        image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        view.image = image;
    }
    label.frame = view.bounds;
    label.tag = kViewUtilRoleViewLabelTag;
    return view;
}

/**
 *  获取label每行文字
 *
 *  @return
 */
+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label
{
    NSString *text = [label text] ? : @"";
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return (NSArray *)linesArray;
}

+ (UIImage *)placeHolderImageForURL:(NSString *)url sex:(NSNumber *)sex {
    UIImage *image = [UIImage imageNamed:@"noavatar"];
    if (url.length == 0) {
        image =[UIImage imageNamed:@"defaultavatar_xiaoming.png"];
        if (sex.integerValue == 1) {
            image = [UIImage imageNamed:@"defaultavatar_girl_xiaoming.png"];
        }
    }
    return image;
}

@end
