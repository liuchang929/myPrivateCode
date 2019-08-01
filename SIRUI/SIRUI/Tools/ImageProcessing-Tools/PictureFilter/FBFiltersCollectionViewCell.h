//
//  FBFiltersCollectionViewCell.h
//  fineix
//
//  Created by FLYang on 16/3/4.
//  Copyright © 2016年 taihuoniao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBMacro.h"

@interface FBFiltersCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView         *   filtersImageView;       //  滤镜缩略图
@property (nonatomic, strong) UILabel             *   filtersTitle;           //  滤镜名称

@end
