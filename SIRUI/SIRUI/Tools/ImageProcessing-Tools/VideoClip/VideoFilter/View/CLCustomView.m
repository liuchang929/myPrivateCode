//
//  CLCustomView.m
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "CLCustomView.h"
#define TopGroundHight 132.0f // 滤镜背景高度
#define CustomViewWidth self.frame.size.width
#define CustomViewHeight self.frame.size.height

@implementation CLCustomView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
         self.userInteractionEnabled = YES;
        
         self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
        //self.backgroundColor = [UIColor orangeColor];
        //点击手势 播放/暂停
    
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TopGroundHight)];
        self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.filterScrollView = [[CLFilterScrollView alloc] initWithFrame:CGRectMake(0, self.backgroundView.frame.size.height - FilterScrollHight, self.backgroundView.frame.size.width, FilterScrollHight)];
        [self.backgroundView addSubview:self.filterScrollView];
        [self addSubview:self.backgroundView];
        
        int heightSpace = 20;
        if (ITS_X_SERIES) {
            heightSpace = 40;
        }
       
        self.backButton = [[CLButton alloc]initWithFrame:CGRectMake(0, heightSpace, 50, 50)];
        _backButton.chooseType = BackGoOutButton;
        [_backButton setTitle:NSLocalizedString(@"Back",nil) forState:0];
        [_backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_backButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        self.nextButton = [[CLButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 60), heightSpace, 50, 50)];
        _nextButton.chooseType = NextGoInButton;
        [_nextButton setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
        [_nextButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_nextButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        self.filterButton = [[CLButton alloc]initWithFrame:CGRectMake(50, heightSpace, (SCREEN_WIDTH - 100), 50)];
        self.filterButton.chooseType = FilterShowButton;
        self.filterButton.center = CGPointMake(self.center.x, 52.5/2 + 10);
        [self.filterButton setTitle:NSLocalizedString(@"Video filters",nil) forState:0];
        [self.filterButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_filterButton addTarget:self action:@selector(clickedButtonType:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_filterButton];
        
    }
    return self;
}
// button 点击事件
- (void)clickedButtonType:(CLButton *)sender
{
    scaleAnimation(sender);
    if ([self.delegate respondsToSelector:@selector(clickedButtonChooseType:)]) {
        [self.delegate clickedButtonChooseType:sender.chooseType];
    }
}

@end
