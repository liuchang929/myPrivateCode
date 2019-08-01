//
//  JEAuxLinesView.m
//  Sight
//
//  Created by fangxue on 2018/12/13.
//  Copyright © 2018年 fangxue. All rights reserved.
//

#import "JEAuxLinesView.h"
#define linesWidth 0.5
#define linesColor [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00]

@implementation JEAuxLinesView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Action
- (void)drawViewWithMode:(AuxLinesMode)mode {
    switch (mode) {
        case Square:
        {
            [self linesH1:self.frame];
            [self linesH2:self.frame];
            [self linesS1:self.frame];
            [self linesS2:self.frame];
        }
            break;
         
        case SquareDiagonal:
        {
            [self linesH1:self.frame];
            [self linesH2:self.frame];
            [self linesS1:self.frame];
            [self linesS2:self.frame];
            [self linesD1:self.frame];
            [self linesD2:self.frame];
        }
            break;
            
        case CenterPoint:
        {
            [self pointCenter:self.frame];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Lines
- (void)linesH1:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, (rect.size.width/3), 0);
    CGPathAddLineToPoint(path, NULL, (rect.size.width/3), rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)linesH2:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, (2 * rect.size.width/3), 0);
    CGPathAddLineToPoint(path, NULL, (2 * rect.size.width/3), rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)linesS1:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, (rect.size.height/3));
    CGPathAddLineToPoint(path, NULL, rect.size.width, (rect.size.height/3));
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)linesS2:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, (2 * rect.size.height/3));
    CGPathAddLineToPoint(path, NULL, rect.size.width, (2 * rect.size.height/3));
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)linesD1:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)linesD2:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.size.width, 0);
    CGPathAddLineToPoint(path, NULL, 0, rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

- (void)pointCenter:(CGRect)rect {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    imageView.image = [UIImage imageNamed:@"icon_auxLines_centerPoint"];
    imageView.center = CGPointMake(rect.origin.x / 2, rect.origin.y / 2);
    [self addSubview:imageView];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
    CGAffineTransform transform = CGAffineTransformMakeTranslation(50, 50);
    CGPathAddEllipseInRect(path, &transform, CGRectMake(rect.origin.x/2 - 10, rect.origin.y/2 - 10, 20, 20));
    CGPathAddEllipseInRect(path, &transform, CGRectMake(rect.origin.x/2 - 2.5, rect.origin.y/2 - 2.5, 5, 5));
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);    //缺角
    CGContextSetLineCap(ctx, kCGLineCapButt);   //无端点
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
}

@end
