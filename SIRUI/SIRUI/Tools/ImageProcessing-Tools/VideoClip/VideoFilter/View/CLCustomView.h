//
//  CLCustomView.h
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

/*
 FilterViewController 主View
 */

#import <UIKit/UIKit.h>
#import "CLFilterScrollView.h"
#import "CLButton.h"

@protocol CLCustomViewDelegate <NSObject>

/* 点击button 代理
 （返回、下一步、滤镜按钮、播放暂停）
 */
- (void)clickedButtonChooseType:(ChooseButtonType)chooseType;

@end

@interface CLCustomView : UIView

@property (nonatomic, strong) CLButton *backButton; //返回按钮
@property (nonatomic, strong) CLButton *nextButton; //下一步按钮
@property (nonatomic, strong) CLButton *filterButton;//点击出现滤镜scrollview的按钮
@property (nonatomic, strong) CLFilterScrollView *filterScrollView;// 滤镜scrollView
@property (nonatomic, strong) UIView *backgroundView;//上半部分filter下的半透明背景

@property (nonatomic, assign) id <CLCustomViewDelegate>delegate;

@end
