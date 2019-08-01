//
//  FBPictureViewController.h
//  PhotpShow
//
//  Created by FLYang on 16/2/26.
//  Copyright © 2016年 Fynn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBMacro.h"

@interface FBPictureViewController : UIViewController

@property (nonatomic, strong) UIView              *   navView;        //  顶部滚动栏
@property (nonatomic, strong) UILabel             *   navTitle;       //  顶部标题

@property (nonatomic, strong) UIButton            *   backBtn;        //  返回按钮
@property (nonatomic, strong) UIButton            *   doneBtn;        //  完成发布按钮

@property (nonatomic, strong) UIButton            *   nextBtn;        //  继续按钮
@property (nonatomic, strong) UIButton            *   cropBack;       //  "裁剪"返回
@property (nonatomic,assign)BOOL isMusic;
//  导航视图
- (void)addNavViewTitle:(NSString *)title;

//  继续按钮
- (void)addNextButton;

//  返回按钮
- (void)addBackButton;

//  发布按钮
- (void)addDoneButton;


@end
