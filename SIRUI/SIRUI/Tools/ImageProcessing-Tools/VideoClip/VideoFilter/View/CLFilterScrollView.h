//
//  CLFilterScrollView.h
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <UIKit/UIKit.h>

// 动画效果
static inline void scaleAnimation (UIView *view)
{
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.scale"];//同上
    anima.toValue = [NSNumber numberWithFloat:1.09f];
    anima.duration = .18f;
    [view.layer addAnimation:anima forKey:@"scaleAnimation"];
}
@protocol CLFilterScroViewDelegate <NSObject>

- (void)seletcScrollIndex:(NSInteger)index;

@end

@interface CLFilterScrollView : UIScrollView

@property (nonatomic, strong) NSMutableArray *imageArr;//CLImageView数组
@property (nonatomic, strong) NSMutableArray *rectArr; //CLImageView的frame数组

@property (nonatomic, assign) id<CLFilterScroViewDelegate>tbDelegate;


/*
 // 接口 传图片
 filterImage：图片数组
 index：默认选择第几个
 */
- (void)setFilterImages:(NSMutableArray *)filterImage titleArray:(NSArray *)titleArray index:(NSInteger)index;

@end
