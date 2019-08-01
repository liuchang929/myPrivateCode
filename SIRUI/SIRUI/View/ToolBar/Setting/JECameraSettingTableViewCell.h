//
//  JECameraSettingTableViewCell.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/13.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JECameraSettingTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *cellName;    //cell 左侧 label
@property (nonatomic, strong) UIView  *cellView;    //cell 右侧 view

+ (NSString *)ID;   //cellID

@end

NS_ASSUME_NONNULL_END
