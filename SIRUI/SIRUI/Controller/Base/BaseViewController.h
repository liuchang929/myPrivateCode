//
//  BaseViewController.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/3/16.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

//  level            view            frame
//  ---------------------------------------------------------------
//
//  highest          windowView      0 x             0 x width x height
//
//  higher           topView         0 x             0 x width x 64
//
//  higher           bottomView      0 x (height - 64) x width x 64
//
//  normal           contentView     0 x            64 x width x (height - 64)
//

@property (nonatomic, strong) UIView *windowView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *contentView;

@end

NS_ASSUME_NONNULL_END
