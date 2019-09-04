//
//  JEAuxLineView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/6/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEAuxLineView.h"
#define linesWidth 0.5
#define linesColor [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00]

@implementation JEAuxLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - UI
- (void)drawRect:(CGRect)rect {
    switch (_auxLineMode) {
        case Square:
            [self linesH1:rect];
            [self linesH2:rect];
            [self linesS1:rect];
            [self linesS2:rect];
            break;
            
        case SquareDiagonal:
            [self linesH1:rect];
            [self linesH2:rect];
            [self linesS1:rect];
            [self linesS2:rect];
            [self linesT1:rect];
            [self linesT2:rect];
            break;
            
        case CenterPoint:
            [self roundR1:rect];
            [self roundR2:rect];
            break;
            
        default:
            break;
    }
}

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
    CGPathRelease(path);
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
    CGPathRelease(path);
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
    CGPathRelease(path);
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
    CGPathRelease(path);
}

- (void)linesT1:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CGPathRelease(path);
}

- (void)linesT2:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.size.width, 0);
    CGPathAddLineToPoint(path, NULL, 0, rect.size.height);
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CGPathRelease(path);
}

- (void)roundR1:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, 5, 0, 2*M_PI, 0); //添加一个圆
    [linesColor setFill];
//    CGContextAddArc(ctx, 圆心x, 圆心y, 半径, 起始角度, 终点角度, 顺时针方向)
    CGContextDrawPath(ctx, kCGPathFill);//绘制填充
}

- (void)roundR2:(CGRect)rect {
    //边框圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [linesColor setStroke];
    CGContextSetLineWidth(ctx, linesWidth);//线的宽度
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, 10, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(ctx, kCGPathStroke); //绘制路径
}

@end
