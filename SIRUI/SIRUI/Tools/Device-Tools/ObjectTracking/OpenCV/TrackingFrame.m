//
//  TrackingFrame.m
//  SiRuiIOT
//
//  Created by SIRUI on 2018/1/12.
//

#import "TrackingFrame.h"

@interface TrackingFrame()

@end

@implementation TrackingFrame

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        self.clipsToBounds = NO;
        _lb = [[UILabel alloc]initWithFrame:CGRectOffset(frame, 0, 0)];
        _lb.clipsToBounds = NO;
        _lb.textColor = [UIColor redColor];
        _lb.text = NSLocalizedString(@"Track loss", nil);
        _lb.hidden = YES;
        _lb.font = [UIFont systemFontOfSize:12];
        _lb.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lb];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    /*
    CGFloat minW = fmin(self.frame.size.height, self.frame.size.width);
    CGFloat ww = minW*0.1;
    */
    UIColor *color;
    
    if(_isLost){
        [[UIColor redColor]set];
        _lb.textColor = [UIColor redColor];
        _lb.frame = CGRectMake(0, -30, self.frame.size.width, 30);
        _lb.hidden = NO;
        color = [UIColor redColor];
    }else{
        _lb.textColor = [UIColor greenColor];
        _lb.hidden = YES;
        color = [UIColor greenColor];
        [[UIColor greenColor] set];
    }
    //1.画布
    CGContextRef context =
    UIGraphicsGetCurrentContext();
    //2.内容
    CGContextAddRect(context, rect);
    //3.设置画笔颜色
    [color setStroke];
    //4.设置画笔宽度
    CGContextSetLineWidth(context, 2);
    //5.渲染
    CGContextDrawPath(context, kCGPathStroke);
    /*
    // 创建弧线路径对象
    UIBezierPath* path1 = [UIBezierPath bezierPath];
    
    [path1 moveToPoint:CGPointMake(0, ww)];
    [path1 addLineToPoint:CGPointMake(0, 0)];
    [path1 addLineToPoint:CGPointMake(ww, 0)];
    
    path1.lineWidth     = 2.0f;
    path1.lineCapStyle  = kCGLineCapRound;
    path1.lineJoinStyle = kCGLineCapRound;
    
    [path1 stroke];
    
    UIBezierPath* path2 = [UIBezierPath bezierPath];
    
    [path2 moveToPoint:CGPointMake(self.frame.size.width-ww, 0)];
    [path2 addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    [path2 addLineToPoint:CGPointMake(self.frame.size.width, ww)];
    
    path2.lineWidth     = 2.0f;
    path2.lineCapStyle  = kCGLineCapRound;
    path2.lineJoinStyle = kCGLineCapRound;
    
    [path2 stroke];
    
    UIBezierPath* path3 = [UIBezierPath bezierPath];
    
    [path3 moveToPoint:CGPointMake(self.frame.size.width, self.frame.size.height-ww)];
    [path3 addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path3 addLineToPoint:CGPointMake(self.frame.size.width-ww, self.frame.size.height)];
    
    path3.lineWidth     = 2.0f;
    path3.lineCapStyle  = kCGLineCapRound;
    path3.lineJoinStyle = kCGLineCapRound;
    
    [path3 stroke];
    
    UIBezierPath* path4 = [UIBezierPath bezierPath];
    
    [path4 moveToPoint:CGPointMake(ww, self.frame.size.height)];
    [path4 addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path4 addLineToPoint:CGPointMake(0, self.frame.size.height-ww)];
    
    path4.lineWidth     = 2.0f;
    path4.lineCapStyle  = kCGLineCapRound;
    path4.lineJoinStyle = kCGLineCapRound;
    
    [path4 stroke];
     */
}
-(void)setIsLost:(BOOL)isLost
{
    _isLost = isLost;
    
    [self setNeedsDisplay];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setNeedsDisplay];
    
}

@end

