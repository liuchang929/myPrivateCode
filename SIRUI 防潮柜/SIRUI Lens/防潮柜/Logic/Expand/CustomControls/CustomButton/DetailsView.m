//
//  DetailsView.m
//  Yeelight
//
//  Created by sirui on 2017/2/15.
//  Copyright © 2017年 sirui. All rights reserved.
//

#import "DetailsView.h"
#import "Macros.h"
#import "UIView+Sizes.h"

@interface DetailsView ()
@end

@implementation DetailsView
- (instancetype)initWithStyle:(positionStyle)style{
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.style = style;
        [self customInit];
    }
    return self;
    
}
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
    _headIv =[[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_headIv];
      _tittleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tittleLabel.textAlignment= NSTextAlignmentCenter;
    _tittleLabel.textColor = kColorWhite;
    [self addSubview:_tittleLabel];
    
    
    
    
    
    _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _clickButton.backgroundColor = [UIColor clearColor];
    _clickButton.alpha = 0.05;
    [self.clickButton setTitleColor:[UIColor colorWithWhite:1.f alpha:.4f] forState:UIControlStateHighlighted];
    [self.clickButton setImage:[UIImage imageNamed:@"gray_background"] forState:UIControlStateHighlighted];
    [self addSubview:_clickButton];
    

    
    

}



-(void)SetLeftandRightStyle{
     _headIv.frame = CGRectMake(0, 0, self.width/6, self.height);
    _tittleLabel.frame = CGRectMake(self.width/6+5.0, 0, self.width*5/6, self.height);
    _tittleLabel.textAlignment = NSTextAlignmentLeft;
    _clickButton.frame = self.bounds;
    
    
}


- (void)addEditTarget:(id)target action:(SEL)action
{
    [self.clickButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.style==LRStyle) {
 
//        float tittleX = (self.width/2)- (self.width +self.height)*0.25 + self.height;
//        _tittleLabel.frame = CGRectMake(tittleX,0, self.width/2, self.height);
//        //_tittleLabel.left = self.centerX;
//        _headIv.frame = CGRectMake(0, self.height/4, self.height/2, self.height/2);
//        _headIv.right = _tittleLabel.left;
        
        _headIv.frame = CGRectMake(0, self.height/4, self.height/2, self.height/2);
        _tittleLabel.frame = CGRectMake(self.height/2,0, self.width - self.height*0.5, self.height);
        _tittleLabel.textAlignment = NSTextAlignmentCenter;
        _clickButton.frame = self.bounds;
        
        
    }else{
    _headIv.frame = CGRectMake(self.width*0.3, self.height*0.1, self.width/2.5, self.height/2.5);
    _tittleLabel.frame = CGRectMake(0, self.height/2, self.width, self.height/2);
    _clickButton.frame = self.bounds;
        
    }
    
}



@end

