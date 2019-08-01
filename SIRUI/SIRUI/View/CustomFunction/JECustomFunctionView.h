//
//  JECustomFunctionView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/19.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JECustomFunctionViewDelegate <NSObject>

- (void)exitCustomFunctionView;

@end

@interface JECustomFunctionView : UIView

@property (nonatomic, weak) id<JECustomFunctionViewDelegate> delegate;

- (void)changePickerViewValue:(BOOL)isUp;

@end

NS_ASSUME_NONNULL_END
