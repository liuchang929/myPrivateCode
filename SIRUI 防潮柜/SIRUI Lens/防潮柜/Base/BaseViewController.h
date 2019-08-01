//
//  IoTBaseViewController.h
//  IoTLogin
//
//  Created by sirui on 2017/3/3.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseViewController : UIViewController

//是否隐藏导航
@property (nonatomic, assign) BOOL preferNavigationHidden;



- (void)addTapGesture;

- (void)removeTapGesture;


//Alert
- (void)showAlert:(NSString *)title cancelTitle:(NSString *)cancelTitle;
- (void)showAlert:(NSString *)title withMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle;



- (void)showHintMessage:(NSString *)message;



//load..
- (BOOL)isShowingLoading;
- (void)showLoading;
- (void)showLoading:(NSString *)msg;
- (void)stopLoading;


-(void)showDelayedLoading:(NSString *)msg;



@end
