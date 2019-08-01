//
//  JEVideoLapseTableViewCell.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/6/22.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEVideoLapseTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *pointImage;      //关键点图片
@property (nonatomic, strong) UIButton    *pointDeleteBtn;  //关键点删除按钮

+ (NSString *)ID;

@end

NS_ASSUME_NONNULL_END
