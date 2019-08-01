//
//  IconTextTextCell.h
//  SmartTripod
//
//  Created by sirui on 16/10/13.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

// Note:
// this cell is used for cells that have:
// 1, icon + text + text
// 2, icon + text
// 3, text + text
// 4, text

#import <UIKit/UIKit.h>
//#import "RedDotView.h"

#define kIconTextTextCellHeight kCommonCellHeight

#define kIconTextTextCellLeftMarginWithIcon 43.f

#define kIconTextTextCellLeftMargin 10.f

extern NSString * const kIconTextTextCellReuser;

typedef enum : NSInteger {
    kIconTextTextCellStyleAll,
    kIconTextTextCellStyleIconTextText,
    kIconTextTextCellStyleIconTextTextNoArrow,
    kIconTextTextCellStyleIconTextColor,
    kIconTextTextCellStyleIconTextColorNoArrow,
    kIconTextTextCellStyleIconText,
    kIconTextTextCellStyleTextText,
    kIconTextTextCellStyleTextColor,
    kIconTextTextCellStyleText,
    kIconTextTextCellStyleTextTextNoArrow,
    kIconTextTextCellStyleTextNoArrow,
} IconTextTextCellStyle;

@interface IconTextTextCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *iconView;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *secondLabel;
@property (nonatomic) IBOutlet UIImageView *seperaterView;
@property (nonatomic) IBOutlet UIImageView *arrowView;

@property (nonatomic, assign) CGFloat iconLeftMargin;
// bottom separator's left margin
@property (nonatomic, assign) CGFloat separatorLeftMargin;
@property (nonatomic, assign) CGFloat titleLeftMargin;
@property (nonatomic, assign) CGFloat secondLabelLeftMargin;
@property (nonatomic, assign) CGFloat titleLabelWidth;
@property (nonatomic, assign) CGFloat secondLabelWidth;
@property (nonatomic, assign) BOOL showArrowView;
@property (nonatomic, assign) BOOL showReddotView;
@property (nonatomic, assign) BOOL hiddenMaskView;
@property (nonatomic, assign) NSInteger messageCount;

+ (IconTextTextCell *)getCellFromTableView:(UITableView *)tableView;

- (void)setSpecialStyle:(IconTextTextCellStyle)style;

- (void)setSecondText:(NSString *)text;

- (void)setTopSeparatorHidden:(BOOL)hidden;

- (void)setBottomSeparatorHidden:(BOOL)hidden;


@end
