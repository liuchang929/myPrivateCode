//
//  AppDelegate.m
//  Sight
//
//  Created by fangxue on 17/3/1.
//  Copyright © 2017年 fangxue. All rights reserved.


#import "YFXCustomFlowTextField.h"

@interface YFXCustomFlowTextField()

//是否移动
@property (nonatomic,assign) BOOL isMoved;

@end

@implementation YFXCustomFlowTextField

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    
    //本次触摸点
    CGPoint current = [touch locationInView:self];
    
    //上次触摸点
    CGPoint previous = [touch previousLocationInView:self];
    
    CGPoint center = self.center;
    
    //中心点移动触摸移动的距离
    center.x += current.x - previous.x;
    center.y += current.y - previous.y;
    
    //限制移动范围
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat xMin = self.frame.size.width  * 0.5f;
    CGFloat xMax = screenWidth  - xMin;
    
    CGFloat yMin = self.frame.size.height * 0.5f;
    CGFloat yMax = screenHeight - self.frame.size.height * 0.5f;
   
    if (center.x > xMax) center.x = xMax;
    if (center.x < xMin) center.x = xMin;
    
    if (center.y > yMax) center.y = yMax;
    if (center.y < yMin) center.y = yMin;
    
    self.center = center;
    
    //移动距离大于0.5才判断为移动了
    if (current.x-previous.x>=0.5 || current.y - previous.y>=0.5) {
        
        self.isMoved = YES;
        
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.isMoved = NO;
}

@end
