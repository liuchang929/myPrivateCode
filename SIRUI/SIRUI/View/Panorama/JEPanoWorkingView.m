//
//  JEPanoWorkingView.m
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/8/9.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JEPanoWorkingView.h"
//#import "SDRotationLoopProgressView.h"

@implementation JEPanoWorkingView
{
    CGFloat _angleInterval;
    CGFloat _angleInterval2;
    NSInteger _angle;
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame withAngle:(NSInteger)angle
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(changeAngle) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _imageView.center = self.center;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _angle = angle;

    }
    return self;
}

- (void)changeAngle
{
    _angleInterval += M_PI * 0.08;
    if (_angleInterval >= M_PI * 2) _angleInterval = 0;
    
    _angleInterval2 -= M_PI * 0.08;
    if (_angleInterval2 >= M_PI * 2) _angleInterval2 = 0;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];

    CGContextSetLineWidth(ctx, 2);
    CGFloat to = - M_PI * 0.06 + _angleInterval; // 初始值0.05
    CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - 10;
    CGContextAddArc(ctx, xCenter, yCenter, radius, _angleInterval, to, 0);
    CGContextStrokePath(ctx);
    
    CGContextRef ctx2 = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    
    CGContextSetLineWidth(ctx2, 2);
    CGFloat from = - M_PI * 0.06 + _angleInterval2; // 初始值0.05
    CGFloat radius2 = MIN(rect.size.width, rect.size.height) * 0.5 - 20;
    CGContextAddArc(ctx2, xCenter, yCenter, radius2, _angleInterval2, from, 0);
    CGContextStrokePath(ctx2);
    
    if (_angle == 90) {
        [_imageView setImage:[UIImage imageNamed:@"icon_sub_pano_90d"]];
    }
    else if (_angle == 180) {
        [_imageView setImage:[UIImage imageNamed:@"icon_sub_pano_180d"]];
    }
    else if (_angle == 360) {
        [_imageView setImage:[UIImage imageNamed:@"icon_sub_pano_360d"]];
    }
    else if (_angle == 270) {
        [_imageView setImage:[UIImage imageNamed:@"icon_sub_pano_3x3"]];
    }

}

@end
