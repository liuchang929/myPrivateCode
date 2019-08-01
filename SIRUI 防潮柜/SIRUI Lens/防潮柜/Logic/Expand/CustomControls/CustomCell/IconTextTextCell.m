//
//  IconTextTextCell.m
//  SmartTripod
//
//  Created by sirui on 16/10/13.
//  Copyright © 2016年 SIRUI. All rights reserved.
///

#import "IconTextTextCell.h"
//#import "UIView+Sizes.h"
#import "ViewUtils.h"
#import "Macros.h"
#import "UIView+Sizes.h"

NSString * const kIconTextTextCellReuser = @"ITTReuser";

@interface IconTextTextCell ()

@property (nonatomic, assign) IconTextTextCellStyle style;

@property (nonatomic, strong) UIImageView *topSeparator;

@property (nonatomic, strong) UIImageView *bottomSeparator;

@property (nonatomic, strong) UIImageView *maskView;

@end

@implementation IconTextTextCell

+ (IconTextTextCell *)getNewCell {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"IconTextTextCell" owner:nil options:nil];
    IconTextTextCell *cell = [array firstObject];
    return cell;
}

+ (IconTextTextCell *)getCellFromTableView:(UITableView *)tableView {
    IconTextTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kIconTextTextCellReuser];
    if (nil == cell) {
        cell = [self getNewCell];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectedBackgroundView = [ViewUtils getCellSelectedView:self.bounds];
    
    _iconLeftMargin = 21.f;
    _titleLabelWidth = 150.f;
    _secondLabelWidth = 120.f;
    _style = kIconTextTextCellStyleAll;
    _showArrowView = YES;
    _showReddotView = NO;
    self.secondLabel.textColor = [UIColor colorFromRGB:0x6A6A6A];
    self.seperaterView.backgroundColor = kColorSeparator;

    self.topSeparator = [ViewUtils getGraySeparator];
    [self addSubview:self.topSeparator];
    
    self.bottomSeparator = [ViewUtils getGraySeparator];
    self.bottomSeparator.hidden = YES;
    self.bottomSeparator.backgroundColor = kColorSeparator;
    [self addSubview:_bottomSeparator];
    
//    _reddotView = [[RedDotView alloc] initWithFrame:CGRectZero];
//    [self addSubview:_reddotView];
    
    _maskView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.5f;
    _maskView.hidden = YES;
    [self.contentView addSubview:_maskView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    BOOL flag = self.maskView.hidden;
//    [super setSelected:selected animated:animated];
    self.maskView.hidden = !selected;
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
//    BOOL flag = self.maskView.hidden;
    [super setHighlighted:highlighted animated:animated];
    if (_hiddenMaskView) {
        self.maskView.hidden = YES;
    }else{
        self.maskView.hidden = !highlighted;
    }
}

- (void)setSpecialStyle:(IconTextTextCellStyle)style {
    if (style == self.style) {
        return;
    }
    
    // for IconView
    if (kIconTextTextCellStyleTextText == style ||
        kIconTextTextCellStyleTextColor == style ||
        kIconTextTextCellStyleText == style ||
        kIconTextTextCellStyleTextTextNoArrow == style ||
        kIconTextTextCellStyleTextNoArrow == style) {
        self.iconView.hidden = YES;
    }
    else {
        self.iconView.hidden = NO;
    }
    
    // no change for title
    
    // for second Label
    if (kIconTextTextCellStyleIconText == style ||
        kIconTextTextCellStyleText == style ||
        kIconTextTextCellStyleTextNoArrow == style) {
        self.secondLabel.hidden = YES;
    }
    else {
        self.secondLabel.hidden = NO;
    }
    
    if (kIconTextTextCellStyleIconTextColor == style ||
        kIconTextTextCellStyleTextColor == style) {
        self.secondLabel.textColor = [UIColor colorFromRGB:0xFF6511];
    }
    else {
        self.secondLabel.textColor = [UIColor colorFromRGB:0x6A6A6A];
    }
    
    if (kIconTextTextCellStyleIconTextTextNoArrow == style ||
        kIconTextTextCellStyleIconTextColorNoArrow == style) {
        self.showArrowView = NO;
    }
    
    if (kIconTextTextCellStyleTextTextNoArrow == style ||
        kIconTextTextCellStyleTextNoArrow == style) {
        self.showArrowView = NO;
    }
    else {
        self.showArrowView = YES;
    }
    
    self.style = style;
}

- (void)setSecondText:(NSString *)text {
    self.secondLabel.text = text;
    [self.secondLabel setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_arrowView sizeToFit];
    _arrowView.right = self.width - 16;
    _arrowView.centerY = self.height/2;
    _arrowView.hidden = !_showArrowView;
    CGSize imageSize = [self.iconView.image size];
    if (imageSize.width > 35.f) {
        imageSize.width = 28.f;
        imageSize.height = 28.f;
    }
    self.iconView.frame = CGRectMake(self.iconLeftMargin, (self.height - imageSize.width) / 2.f, imageSize.width , imageSize.height);
    
    if (!self.iconView.hidden) { //显示icon
        self.titleLabel.frame = CGRectMake(_titleLeftMargin + 43.f, 10.f, self.titleLabelWidth, 20.f);
    }
    else {
        self.titleLabel.frame = CGRectMake(_titleLeftMargin + 10.f, 10.f, self.titleLabelWidth, 20.f);
    }
    self.titleLabel.centerY = ceil(self.height / 2.f);
    
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.height / 2);
    self.secondLabel.frame = CGRectMake(self.width - 120.f - 30.f, 10.f, self.secondLabelWidth, 20.f);
    _secondLabel.centerY = _secondLabel.superview.height/2;

    if (_secondLabelLeftMargin) {
        //_secondLabelLeftMargin仅用于充值cell的判断
        _secondLabel.left = _secondLabelLeftMargin;
    }else{
        _secondLabel.right = _arrowView.left - 10;
    }
    
    if (!self.showArrowView)
    {
        _secondLabel.right = self.width - 16.f;
    }
    
    self.topSeparator.frame = CGRectMake(0.f,
                                         0.f,
                                         self.width,
                                         kViewSeparatorHeight);
    self.seperaterView.frame = CGRectMake(self.separatorLeftMargin,
                                          self.height - kViewSeparatorHeight,
                                          self.width - self.separatorLeftMargin,
                                          kViewSeparatorHeight);
    self.bottomSeparator.frame = CGRectMake(0.f,
                                            self.height - kViewSeparatorHeight,
                                            self.width,
                                            kViewSeparatorHeight);
    
//    if (self.showReddotView)
//    {
//        CGFloat redWidth = [self.reddotView viewHeight];
//        self.reddotView.frame = CGRectMake(self.width - 50, 0, redWidth, redWidth);
//        self.reddotView.center = CGPointMake(self.reddotView.center.x, self.height/2);
//    }
    
    self.maskView.frame = self.bounds;
}

- (void)setTopSeparatorHidden:(BOOL)hidden {
    self.topSeparator.hidden = hidden;
}

- (void)setBottomSeparatorHidden:(BOOL)hidden
{
    self.bottomSeparator.hidden = hidden;
    self.seperaterView.hidden = !hidden;
}

- (void)setMessageCount:(NSInteger)messageCount {
    _messageCount = messageCount;
//    if (self.showReddotView)
//    {
//        self.reddotView.hidden = _messageCount <= 0;
//        self.reddotView.number = messageCount;
//    }
}

- (void)setSecondLabelLeftMargin:(CGFloat)secondLabelLeftMargin
{
    _secondLabelLeftMargin = secondLabelLeftMargin;
    [self setNeedsLayout];
}
@end
