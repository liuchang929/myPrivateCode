//
//  SRGradientbackground.m
//  SiRuiIOT
//
//  Created by SIRUI on 2017/7/19.
//
//

#import "SRGradientbackground.h"
#import "POP.h"

@interface SRGradientbackground()
{
    CAGradientLayer *layer;
    CGRect oriFrame;
}

@end

@implementation SRGradientbackground

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        oriFrame = self.frame;
        self.clipsToBounds = NO;
        _isTop = YES;
        [self updateBackground:self.frame];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame andTop:(BOOL)top
{
    self = [super initWithFrame:frame];
    
    if(self){
        oriFrame = frame;
        self.clipsToBounds = NO;
        _isTop = top;
        [self updateBackground:frame];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)updateBackground:(CGRect)frame
{
    [layer removeFromSuperlayer];
    
    layer = [CAGradientLayer layer];
    layer.frame =  CGRectMake(0, self.frame.size.height - frame.size.height, frame.size.width, frame.size.height);
    
    layer.startPoint = CGPointMake(0.5, 0);
    layer.endPoint = CGPointMake(0.5, 1);
    
    if(_isTop){
        
        layer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:1.0].CGColor,
                         (__bridge id)[UIColor clearColor].CGColor
                         ];
        layer.locations = @[@(0.0f), @(1.0f)];
        
    }else{
        layer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                         (__bridge id)[UIColor colorWithWhite:0 alpha:1.0*(frame.size.height/self.frame.size.height)].CGColor];
        layer.locations = @[@(0.0f), @(1.0f)];
        
    }
    
    [self.layer insertSublayer:layer atIndex:0];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
