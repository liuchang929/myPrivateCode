//
//  JESettingPickerView.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/18.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JESettingPickerViewDelegate <NSObject>

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

@interface JESettingPickerView : UIView

@property (nonatomic, weak) id<JESettingPickerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
