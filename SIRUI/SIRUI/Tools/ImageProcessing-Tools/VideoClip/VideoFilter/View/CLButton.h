//
//  CLButton.h
//  tiaooo
//
//  Created by ClaudeLi on 16/1/13.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChooseButtonType) {
    BackGoOutButton, // 返回
    NextGoInButton, // 下一步
    FilterShowButton, // 滤镜按钮
    PlayOrStopButton, // 播放暂停按钮
};

@interface CLButton : UIButton

@property (nonatomic) ChooseButtonType chooseType;

@end
