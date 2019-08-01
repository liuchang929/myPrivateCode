//
//  LabeledActivityIndicatorView.m
//  Activityindicatorview
//
//  Created by Camoufleur on 08/02/2017.
//  Copyright © 2017 Camoufleur. All rights reserved.
//

#import "LabeledActivityIndicatorView.h"

@interface LabeledActivityIndicatorView()

@property (nonatomic, strong) UIActivityIndicatorView *aiView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGFloat labelWidth;

@property (nonatomic, weak) UIImageView *suc;

@property (nonatomic, strong) NSString *buttonTitle;

@end

@implementation LabeledActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubViewsWithStyle:UIActivityIndicatorViewStyleWhite];
    }
    return self;
}

- (instancetype)initWithActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)style {
    if (self = [super init]) {
        [self addSubViewsWithStyle:style];
    }
    return self;
}

- (void)addSubViewsWithStyle:(UIActivityIndicatorViewStyle)style {
    
    self.userInteractionEnabled = NO;
    if (style == UIActivityIndicatorViewStyleWhiteLarge) style = UIActivityIndicatorViewStyleGray;
    _aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    _aiView.frame = CGRectMake(0, 0, 20, 20);
    _aiView.hidesWhenStopped = YES;
    [self addSubview:_aiView];
    
    _label = [UILabel new];
    _label.backgroundColor = [UIColor clearColor];
    [self addSubview:_label];
}

- (void)setDescription:(NSString *)description font:(UIFont *)font color:(UIColor *)color {
    if ([self.superview isKindOfClass:[UIButton class]]) {
        self.buttonTitle = [((UIButton *)(self.superview)).titleLabel.text copy];
        [((UIButton *)(self.superview)) setTitle:nil forState:UIControlStateNormal];
    }
//    else if ([self.superview isKindOfClass:[UINavigationBar class]]) {
//        self.buttonTitle = ((UINavigationBar *)(self.superview)).items.firstObject.title;
//    } // 暂时不适配导航栏 需要手动回复title
    _label.text = description;
    if (font) _label.font = font;
    if (color) _label.textColor = color;
    [self updateLayout];
}

- (void)updateLayout{
    CGFloat superViewWidth = self.superview.frame.size.width;
    CGRect rect = self.frame;
    rect.size.height = _aiView.frame.size.height;
    CGFloat aiViewWidth = _aiView.hidden ? 0 : _aiView.frame.size.width + 3;
    CGFloat sucWidth = _suc ? 23 : 0;
    rect.size.width = aiViewWidth + self.labelWidth + sucWidth;
    if (rect.size.width > superViewWidth && superViewWidth > 0) {
        rect.size.width = superViewWidth;
    }
    self.frame = rect;
    self.center = CGPointMake(superViewWidth * 0.5, self.superview.frame.size.height * 0.5);
    _label.frame = CGRectMake(aiViewWidth + sucWidth, 0, rect.size.width - aiViewWidth - sucWidth, _aiView.frame.size.height);
    [self setNeedsLayout];
}

- (CGFloat)labelWidth {
    NSString *str = _label.text;
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = _label.font;
    CGFloat width =  [str boundingRectWithSize:CGSizeMake(0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width;
    return width;
}

- (void)startRotation {
    _aiView.hidden = NO;
    [_suc removeFromSuperview];
    _suc = nil;
    [self.aiView startAnimating];
    [self updateLayout];
}

- (void)stopRotation {
    [_aiView stopAnimating];
    [self updateLayout];
}

- (void)stopRotationWithDone {
    [_suc removeFromSuperview];
    UIImageView *suc = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    suc.image = [UIImage imageNamed:@"success.png"];
    self.aiView.hidden = YES;
    [self addSubview:suc];
    _suc = suc;
    [self updateLayout];
}

- (void)stopRotationWithFaild {
    if ([self.superview isKindOfClass:[UIButton class]]) {
        [(UIButton *)self.superview setTitle:self.buttonTitle forState:UIControlStateNormal];
    }
//    else if ([self.superview isKindOfClass:[UINavigationBar class]]) {
//        ((UINavigationBar *)(self.superview)).items.firstObject.title = self.buttonTitle;
//    } // 暂时不适配导航栏
    [self removeFromSuperview];
}

@end
