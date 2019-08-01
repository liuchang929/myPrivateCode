//
//  DetailsView.h
//  Yeelight
//
//  Created by sirui on 2017/2/15.
//  Copyright © 2017年 sirui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    TBStyle,
    LRStyle,
    
} positionStyle;

@interface DetailsView : UIView
@property (nonatomic, strong) UIImageView      *headIv;
@property (nonatomic, strong) UILabel          *tittleLabel;
@property (nonatomic, strong)UIButton          *clickButton;
@property (nonatomic, assign)positionStyle     style;
- (instancetype)initWithStyle:(positionStyle)style;
- (void)addEditTarget:(id)target action:(SEL)action;

-(void)setHeadIv:(UIImageView *)headIv;

@end
