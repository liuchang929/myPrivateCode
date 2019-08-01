//
//  JEUpdateFirmwareView.h
//  Sight
//
//  Created by fangxue on 2018/10/16.
//  Copyright © 2018年 fangxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEProgressView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^updateConfirmBlock)(void);    //升级确认键
typedef void(^updateCancelBlock)(void);     //升级取消键

@interface JEUpdateFirmwareView : UIView

@property (nonatomic, strong) UIImageView *titleView;       //固件更新标题图标
@property (nonatomic, strong) UILabel *updateTitle;         //固件更新标题
@property (nonatomic, strong) UITextView *updateTextView;   //固件更新内容
@property (nonatomic, strong) UIButton *updateConfirmBtn;   //固件更新确认按钮
@property (nonatomic, strong) UIButton *updateCancelBtn;    //固件更新取消按钮
@property (nonatomic, strong) BLEProgressView *progressView;//升级进度条

@property (nonatomic, copy) updateConfirmBlock confirmBlock;//确认键block
@property (nonatomic, copy) updateCancelBlock cancelBlock;  //取消键block

@end

NS_ASSUME_NONNULL_END
