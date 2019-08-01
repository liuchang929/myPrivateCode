//
//  FBFootView.h
//  PhotpShow
//
//  Created by FLYang on 16/2/26.
//  Copyright © 2016年 Fynn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBMacro.h"
@protocol FBFootViewDelegate <NSObject>

@optional

- (void)buttonDidSeletedWithIndex:(NSInteger)index;

@end

@interface FBFootView : UIView

@property (nonatomic, strong) UIScrollView    *   buttonView;     //  按钮视图
@property (nonatomic, strong) NSArray         *   titleArr;       //  底部按钮标题
@property (nonatomic, strong) UILabel         *   line;           //  导航条
@property (nonatomic, strong) UIButton        *   seletedBtn;     //  保存上次点击的button

@property (nonatomic, weak) id <FBFootViewDelegate> delegate;

- (void)addFootViewButton;
- (void)showLineWithButton;

@end
