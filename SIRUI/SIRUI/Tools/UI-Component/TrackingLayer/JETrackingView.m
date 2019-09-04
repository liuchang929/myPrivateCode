//
//  JETrackingView.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JETrackingView.h"

@interface JETrackingView ()

@property (nonatomic, assign) BOOL      isLost;
@property (nonatomic, strong) UILabel   *lostLB;

@end

@implementation JETrackingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.clipsToBounds = NO;
        self.lostLB = [[UILabel alloc] initWithFrame:CGRectOffset(frame, 0, 0)];
            _lostLB.clipsToBounds = NO;
            _lostLB.textColor = [UIColor redColor];
            _lostLB.text = JELocalizedString(@"Track loss", nil);
            _lostLB.hidden = YES;
            _lostLB.font = [UIFont systemFontOfSize:12];
            _lostLB.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lostLB];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIColor *color;
    
    if(_isLost){
//        [[UIColor redColor]set];
        _lostLB.textColor = [UIColor redColor];
        _lostLB.frame = CGRectMake(0, -30, self.frame.size.width, 30);
        _lostLB.hidden = NO;
        color = [UIColor grayColor];
    }else{
//        _lostLB.textColor = [UIColor greenColor];
        _lostLB.hidden = YES;
        color = MAIN_TEXT_COLOR;
//        [[UIColor greenColor] set];
    }
    //1.画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.内容
    CGContextAddRect(context, rect);
    //3.设置画笔颜色
    [color setStroke];
    //4.设置画笔宽度
    CGContextSetLineWidth(context, 2);
    //5.渲染
    CGContextDrawPath(context, kCGPathStroke);
}

-(void)setIsLost:(BOOL)isLost {
    _isLost = isLost;
    
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setNeedsDisplay];
    
}

@end
