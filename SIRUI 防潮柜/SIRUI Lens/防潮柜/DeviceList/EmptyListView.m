//
//  EmptyListView.m
//  SR-Cabinet
//
//  Created by sirui on 2017/3/9.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "EmptyListView.h"
#import "Macros.h"
#import "UIView+Sizes.h"

@interface EmptyListView ()

@property (nonatomic,strong) UIImageView  *backgoundView;



@end

@implementation EmptyListView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    self.backgoundView =  kGetImageViewWithContentsOfFile(@"cabinet_background",@"png");
    [self addSubview:_backgoundView];
    
    
    _headIv =[[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_headIv];
    
    
    _tittleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tittleLabel.textAlignment= NSTextAlignmentCenter;
    _tittleLabel.textColor = kColorWhite;
    _tittleLabel.numberOfLines = 3;
    [self addSubview:_tittleLabel];
 
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgoundView.frame = self.bounds;
    _headIv.frame = CGRectMake(0, self.height/3, 60.f, 60.f);
    _headIv.centerX = self.centerX;
    //.centerX = self.centerX;
    _tittleLabel.frame = CGRectMake(0, self.headIv.bottom, self.width, 80.f);
   // _clickButton.frame = self.bounds;
    
}



@end
