//
//  BSOrderStatusView.h
//  SR-Cabinet
//
//  Created by sirui on 2017/3/13.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRStatusViewDelegate <NSObject>

- (void)statusViewSelectIndex:(NSInteger)index;

@end


@interface SRStatusView : UIView

@property (nonatomic,strong)NSMutableArray *buttonArray;

@property (nonatomic,assign) id <SRStatusViewDelegate>delegate;

//横线
@property (nonatomic,strong) UIView *lineView;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isScroll;
//界面初始化 titleArray状态值,normalColor正常标题颜色，selectedColor选中的颜色，lineColor下面线条颜色如果等于nil就没有线条
- (void)setUpStatusButtonWithTitlt:(NSArray *)titleArray NormalColor:(UIColor *)normalColor SelectedColor:(UIColor *)selectedColor LineColor:(UIColor *)lineColor;

//随着滚动视图移动改变
-(void)changeTag:(int)tag;



@end
