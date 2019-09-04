//
//  JEHitchcockSettingView.h
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/8/29.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEHitchcockSettingView : UIView

@property (nonatomic, assign) float shootTimeLength;    //拍摄时长
@property (nonatomic, assign) BOOL  shootOrientation;   //变焦方向  yes 为放大，no 为缩小

@end

NS_ASSUME_NONNULL_END
